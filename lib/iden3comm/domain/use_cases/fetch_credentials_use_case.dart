import 'package:polygonid_flutter_sdk/assets/get_issuer_id_interface.g.dart';
import 'package:polygonid_flutter_sdk/assets/onchain_non_merkelized_issuer_base.g.dart';
import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/chain_config_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/error_exception.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_cases/get_env_use_case.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_cases/get_selected_chain_use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/constants.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/credential/request/base.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/credential/request/offer_iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/credential/request/onchain_offer_iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/exceptions/iden3comm_exceptions.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/repositories/iden3comm_credential_repository.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/fetch_onchain_claim_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_auth_token_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_fetch_requests_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/data/data_sources/local_contract_files_data_source.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_did_identifier_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_did_use_case.dart';
import 'package:polygonid_flutter_sdk/sdk/di/injector.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class FetchCredentialsUseCase {
  final GetSelectedChainUseCase _getSelectedChainUseCase;
  final GetDidIdentifierUseCase _getDidIdentifierUseCase;
  final GetAuthTokenUseCase _getAuthTokenUseCase;
  final GetFetchRequestsUseCase _getFetchRequestsUseCase;
  final Iden3commCredentialRepository _iden3commCredentialRepository;
  final StacktraceManager _stacktraceManager;
  final IdentityRepository _identityRepository;
  final LocalContractFilesDataSource _localContractFilesDataSource;
  final GetDidUseCase _getDidUseCase;
  final FetchOnchainClaimUseCase _fetchOnchainClaimUseCase;
  final GetEnvUseCase _getEnvUseCase;

  FetchCredentialsUseCase(
    this._getSelectedChainUseCase,
    this._getDidIdentifierUseCase,
    this._getAuthTokenUseCase,
    this._getFetchRequestsUseCase,
    this._iden3commCredentialRepository,
    this._stacktraceManager,
    this._identityRepository,
    this._localContractFilesDataSource,
    this._getDidUseCase,
    this._fetchOnchainClaimUseCase,
    this._getEnvUseCase,
  );

  Future<List<ClaimEntity>> fetchCredentials({
    required CredentialOfferMessageEntity credentialOfferMessage,
    required String privateKey,
    required String genesisDid,
    required BigInt profileNonce,
    String? blockchain,
    String? network,
    String? method,
  }) async {
    try {
      // we check the type of the credential offer message
      if (credentialOfferMessage is! OfferIden3MessageEntity &&
          credentialOfferMessage is! OnchainOfferIden3MessageEntity) {
        throw FetchClaimException(
          errorMessage: "Invalid credential offer message type",
        );
      }

      // we get the current network chain selected
      if (network == null || blockchain == null) {
        final ChainConfigEntity chain =
            await _getSelectedChainUseCase.execute();
        network = chain.network;
        blockchain = chain.blockchain;
        method = chain.method;
      }

      // we get the profile identifier
      // (it could be also the public one if nonce is 0)
      final String profileDid = await _getDidIdentifierUseCase.execute(
        param: GetDidIdentifierParam.withPrivateKey(
          bjjPrivateKey: privateKey,
          blockchain: blockchain,
          network: network,
          profileNonce: profileNonce,
          method: method,
        ),
      );

      final List<ClaimEntity> credentials;
      if (credentialOfferMessage is OfferIden3MessageEntity) {
        credentials = await _fetchOffChainCredentials(
          credentialOfferMessage: credentialOfferMessage,
          privateKey: privateKey,
          genesisDid: genesisDid,
          profileNonce: profileNonce,
          profileDid: profileDid,
        );
        return credentials;
      }

      if (credentialOfferMessage is OnchainOfferIden3MessageEntity) {
        credentials = await _fetchOnchainCredentials(
          message: credentialOfferMessage,
          profileDid: profileDid,
        );
        return credentials;
      }

      throw FetchClaimException(
        errorMessage: "Invalid credential offer message type",
      );
    } on PolygonIdSDKException catch (_) {
      rethrow;
    }
  }

  Future<List<ClaimEntity>> _fetchOffChainCredentials({
    required OfferIden3MessageEntity credentialOfferMessage,
    required String privateKey,
    required String genesisDid,
    required BigInt profileNonce,
    required String profileDid,
  }) async {
    // we get all the requests of the credential offer
    final List<String> requests = await _getFetchRequestsUseCase.execute(
      param: GetFetchRequestsParam(
        credentialOfferMessage,
        profileDid,
      ),
    );

    final List<ClaimEntity> credentials = [];
    for (final request in requests) {
      //for each request we get the authToken
      final String authToken = await _getAuthTokenUseCase.execute(
        param: GetAuthTokenParam(
          privateKey: privateKey,
          message: request,
          genesisDid: genesisDid,
          profileNonce: profileNonce,
        ),
      );

      // we get the credential from the issuer using the authToken
      // and the url of the credential
      final ClaimEntity credential =
          await _iden3commCredentialRepository.fetchClaim(
        did: profileDid,
        authToken: authToken,
        url: credentialOfferMessage.body.url,
      );

      credentials.add(credential);
    }
    return credentials;
  }

  Future<List<ClaimEntity>> _fetchOnchainCredentials({
    required OnchainOfferIden3MessageEntity message,
    required String profileDid,
  }) async {
    final env = await _getEnvUseCase.execute();
    final chainId = message.body.transactionData.chainId?.toString();
    final chain = chainId != null
        ? env.chainConfigs[chainId]
        : await _getSelectedChainUseCase.execute();

    /// FIXME: inject web3Client through constructor
    final web3Client = getItSdk<Web3Client>(param1: chain!.rpcUrl);

    final address = message.body.transactionData.contractAddress;
    final deployedContract = await _localContractFilesDataSource
        .loadOnchainNonMerkelizedIssuerBaseContract(address);

    final issuer = Onchain_non_merkelized_issuer_base(
      address: deployedContract.address,
      client: web3Client,
    );
    final getIssuerId = Get_issuer_id_interface(
      address: deployedContract.address,
      client: web3Client,
    );

    // TODO (moria): Maybe refactor this to a separate use case
    final supportsInterfaceCheck = await issuer.supportsInterface(
      hexToBytes(interfaceCheckInterface),
    );
    final supportsNonMerklizedIssuerInterface = await issuer.supportsInterface(
      hexToBytes(nonMerklizedIssuerInterface),
    );

    final supportsGetIssuerIdInterface = await issuer.supportsInterface(
      hexToBytes(getIssuerIdInterface),
    );

    if (!supportsInterfaceCheck ||
        !supportsNonMerklizedIssuerInterface ||
        !supportsGetIssuerIdInterface) {
      _stacktraceManager.addError(
          "Contract at address $address does not support non-merkelized issuer interface");
      throw FetchClaimException(
          errorMessage:
              "Contract at address $address does not support non-merkelized issuer interface");
    }
    final issuerIdInt = await getIssuerId.getId();
    final issuerDid = (await _identityRepository.describeId(
      id: issuerIdInt,
      config: env.config,
    ))
        .did;

    final didEntity = await _getDidUseCase.execute(param: profileDid);
    final userId =
        await _identityRepository.convertIdToBigInt(id: didEntity.identifier);

    final adapterVersion = await issuer.getCredentialAdapterVersion();

    final claims = <ClaimEntity>[];
    for (final credential in message.body.credentials) {
      final credentialId = BigInt.parse(credential.id);

      try {
        final claim = await _fetchOnchainClaimUseCase.execute(
          param: FetchOnchainClaimParam(
            profileDid: profileDid,
            issuerDid: issuerDid,
            contractAddress: address,
            userId: BigInt.parse(userId),
            credentialId: credentialId,
            chainId: chainId,
            adapterVersion: adapterVersion,
            skipInterfaceSupportCheck: true,
          ),
        );

        claims.add(claim);
      } on PolygonIdSDKException catch (_) {
        rethrow;
      } catch (e) {
        logger().e(
            "[FetchAndSaveClaimsUseCase] Error while fetching onchain claim: $e");
        _stacktraceManager.addTrace(
            "[FetchAndSaveClaimsUseCase] Error while fetching onchain claim: $e");
        _stacktraceManager.addError(
            "[FetchAndSaveClaimsUseCase] Error while fetching onchain claim: $e");
        throw FetchClaimException(
          errorMessage: "Error while fetching onchain claim",
          error: e,
        );
      }
    }

    return claims;
  }
}
