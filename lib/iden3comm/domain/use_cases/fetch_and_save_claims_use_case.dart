import 'package:polygonid_flutter_sdk/assets/get_issuer_id_interface.g.dart';
import 'package:polygonid_flutter_sdk/assets/onchain_non_merkelized_issuer_base.g.dart';
import 'package:polygonid_flutter_sdk/common/domain/error_exception.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_cases/get_env_use_case.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_cases/get_selected_chain_use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/cache_credential_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/credential/request/base.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/credential/request/onchain_offer_iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/exceptions/iden3comm_exceptions.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/repositories/iden3comm_credential_repository.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/check_profile_and_did_current_env.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/fetch_onchain_claim_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/data/data_sources/local_contract_files_data_source.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_did_identifier_use_case.dart';

import 'package:polygonid_flutter_sdk/constants.dart';
import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/save_claims_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/credential/request/offer_iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_auth_token_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_fetch_requests_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_did_use_case.dart';
import 'package:polygonid_flutter_sdk/sdk/di/injector.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class FetchAndSaveClaimsParam {
  final CredentialOfferMessageEntity message;
  final String genesisDid;
  final BigInt profileNonce;
  final String privateKey;

  FetchAndSaveClaimsParam({
    required this.message,
    required this.genesisDid,
    required this.profileNonce,
    required this.privateKey,
  });
}

class FetchAndSaveClaimsUseCase
    extends FutureUseCase<FetchAndSaveClaimsParam, List<ClaimEntity>> {
  final Iden3commCredentialRepository _iden3commCredentialRepository;
  final FetchOnchainClaimUseCase _fetchOnchainClaimUseCase;
  final CheckProfileAndDidCurrentEnvUseCase
      _checkProfileAndDidCurrentEnvUseCase;
  final GetEnvUseCase _getEnvUseCase;
  final GetSelectedChainUseCase _getSelectedChainUseCase;
  final GetDidIdentifierUseCase _getDidIdentifierUseCase;
  final GetDidUseCase _getDidUseCase;
  final GetFetchRequestsUseCase _getFetchRequestsUseCase;
  final GetAuthTokenUseCase _getAuthTokenUseCase;
  final SaveClaimsUseCase _saveClaimsUseCase;
  final CacheCredentialUseCase _cacheCredentialUseCase;
  final LocalContractFilesDataSource _localContractFilesDataSource;
  final IdentityRepository _identityRepository;

  final StacktraceManager _stacktraceManager;

  FetchAndSaveClaimsUseCase(
    this._iden3commCredentialRepository,
    this._fetchOnchainClaimUseCase,
    this._checkProfileAndDidCurrentEnvUseCase,
    this._getEnvUseCase,
    this._getSelectedChainUseCase,
    this._getDidIdentifierUseCase,
    this._getDidUseCase,
    this._getFetchRequestsUseCase,
    this._getAuthTokenUseCase,
    this._saveClaimsUseCase,
    this._cacheCredentialUseCase,
    this._localContractFilesDataSource,
    this._identityRepository,
    this._stacktraceManager,
  );

  @override
  Future<List<ClaimEntity>> execute({
    required FetchAndSaveClaimsParam param,
  }) async {
    /// Get the corresponding fetch request from [OfferIden3MessageEntity]
    /// For each, get the auth token
    /// With the auth token, fetch the [ClaimEntity]
    /// Then save the list of [ClaimEntity]

    try {
      await _checkProfileAndDidCurrentEnvUseCase.execute(
        param: CheckProfileAndDidCurrentEnvParam.withPrivateKey(
          did: param.genesisDid,
          privateKey: param.privateKey,
          profileNonce: param.profileNonce,
        ),
      );

      final env = await _getEnvUseCase.execute();
      final chain = await _getSelectedChainUseCase.execute();

      final profileDid = await _getDidIdentifierUseCase.execute(
        param: GetDidIdentifierParam.withPrivateKey(
          bjjPrivateKey: param.privateKey,
          blockchain: chain.blockchain,
          network: chain.network,
          profileNonce: param.profileNonce,
          method: chain.method,
        ),
      );

      final List<ClaimEntity> claims;

      final message = param.message;
      if (message is OfferIden3MessageEntity) {
        claims = await _fetchClaims(message, param, profileDid);
      } else if (message is OnchainOfferIden3MessageEntity) {
        claims = await _fetchOnchainClaims(message, profileDid, param);
      } else {
        _stacktraceManager.addError(
            "[FetchAndSaveClaimsUseCase] Unknown message type: ${message.runtimeType}");
        throw Exception("Unknown message type: ${message.runtimeType}");
      }

      await _saveClaimsUseCase.execute(
        param: SaveClaimsParam(
          claims: claims,
          genesisDid: param.genesisDid,
          encryptionKey: param.privateKey,
        ),
      );

      logger()
          .i("[FetchAndSaveClaimsUseCase] All claims have been saved: $claims");
      _stacktraceManager.addTrace(
          "[FetchAndSaveClaimsUseCase] All claims have been saved: claimsLength ${claims.length}");

      final config = env.config;
      for (final claim in claims) {
        // cache claim
        try {
          await _cacheCredentialUseCase.execute(
            param: CacheCredentialParam(
              credential: claim,
              config: config,
            ),
          );
        } catch (e) {
          logger()
              .e("[FetchAndSaveClaimsUseCase] Error while caching claim: $e");
          _stacktraceManager.addTrace(
              "[FetchAndSaveClaimsUseCase] Error while caching claim: $e");
        }
      }

      return claims;
    } catch (error) {
      logger().e("[FetchAndSaveClaimsUseCase] Error: $error");
      _stacktraceManager.addTrace("[FetchAndSaveClaimsUseCase] Error: $error");
      _stacktraceManager.addError("[FetchAndSaveClaimsUseCase] Error: $error");
      rethrow;
    }
  }

  Future<List<ClaimEntity>> _fetchClaims(
    OfferIden3MessageEntity message,
    FetchAndSaveClaimsParam param,
    String profileDid,
  ) async {
    final requests = await _getFetchRequestsUseCase.execute(
      param: GetFetchRequestsParam(
        message,
        profileDid,
      ),
    );

    final claims = <ClaimEntity>[];
    for (final request in requests) {
      final authToken = await _getAuthTokenUseCase.execute(
        param: GetAuthTokenParam(
          genesisDid: param.genesisDid,
          profileNonce: param.profileNonce,
          privateKey: param.privateKey,
          message: request,
        ),
      );

      final claimEntity = await _iden3commCredentialRepository.fetchClaim(
        did: profileDid,
        authToken: authToken,
        url: message.body.url,
      );

      claims.add(claimEntity);
    }
    return claims;
  }

  Future<List<ClaimEntity>> _fetchOnchainClaims(
    OnchainOfferIden3MessageEntity message,
    String profileDid,
    FetchAndSaveClaimsParam param,
  ) async {
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
