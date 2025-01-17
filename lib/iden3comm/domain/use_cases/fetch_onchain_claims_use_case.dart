import 'package:polygonid_flutter_sdk/assets/onchain_non_merkelized_issuer_base.g.dart';
import 'package:polygonid_flutter_sdk/assets/get_issuer_id_interface.g.dart';
import 'package:polygonid_flutter_sdk/common/domain/domain_constants.dart';
import 'package:polygonid_flutter_sdk/common/domain/error_exception.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_cases/get_env_use_case.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_cases/get_selected_chain_use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/exceptions/iden3comm_exceptions.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/repositories/did_profile_info_repository.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/check_profile_and_did_current_env.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/fetch_onchain_claim_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/data/data_sources/local_contract_files_data_source.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';
import 'package:polygonid_flutter_sdk/constants.dart';
import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_did_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_public_keys_use_case.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/atomic_query_inputs_config_param.dart';
import 'package:polygonid_flutter_sdk/sdk/di/injector.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class FetchOnchainClaimsParam {
  final String contractAddress;
  final String genesisDid;
  final BigInt? profileNonce;
  final String privateKey;
  final String? chainId;

  FetchOnchainClaimsParam({
    required this.contractAddress,
    required this.genesisDid,
    this.profileNonce,
    required this.privateKey,
    this.chainId,
  });
}

class FetchOnchainClaimsUseCase
    extends FutureUseCase<FetchOnchainClaimsParam, List<ClaimEntity>> {
  final FetchOnchainClaimUseCase _fetchOnchainClaimUseCase;
  final CheckProfileAndDidCurrentEnvUseCase
      _checkProfileAndDidCurrentEnvUseCase;
  final GetEnvUseCase _getEnvUseCase;
  final GetSelectedChainUseCase _getSelectedChainUseCase;
  final GetDidUseCase _getDidUseCase;
  final GetPublicKeyUseCase _getPublicKeyUseCase;
  final LocalContractFilesDataSource _localContractFilesDataSource;
  final IdentityRepository _identityRepository;
  final DidProfileInfoRepository _didProfileInfoRepository;
  final StacktraceManager _stacktraceManager;

  FetchOnchainClaimsUseCase(
    this._fetchOnchainClaimUseCase,
    this._checkProfileAndDidCurrentEnvUseCase,
    this._getEnvUseCase,
    this._getSelectedChainUseCase,
    this._getDidUseCase,
    this._getPublicKeyUseCase,
    this._localContractFilesDataSource,
    this._identityRepository,
    this._didProfileInfoRepository,
    this._stacktraceManager,
  );

  @override
  Future<List<ClaimEntity>> execute({
    required FetchOnchainClaimsParam param,
  }) async {
    /// Get the corresponding fetch request from [OfferIden3MessageEntity]
    /// For each, get the auth token
    /// With the auth token, fetch the [ClaimEntity]
    /// Then save the list of [ClaimEntity]

    try {
      final bjjPublicKey =
          await _getPublicKeyUseCase.execute(param: param.privateKey);

      await _checkProfileAndDidCurrentEnvUseCase.execute(
        param: CheckProfileAndDidCurrentEnvParam(
          did: param.genesisDid,
          publicKey: bjjPublicKey,
          profileNonce: param.profileNonce,
        ),
      );

      final env = await _getEnvUseCase.execute();
      final chain = await _getSelectedChainUseCase.execute();

      final profileDid = await _getDidIdentifierUseCase.execute(
        param: GetDidIdentifierParam(
          bjjPublicKey: bjjPublicKey,
          blockchain: chain.blockchain,
          network: chain.network,
          profileNonce: param.profileNonce,
          method: chain.method,
        ),
      );

      final claims = await _fetchOnchainClaims(
        param.contractAddress,
        profileDid,
        bjjPublicKey,
        param,
      );

      return claims;
    } catch (error) {
      logger().e("[FetchAndSaveClaimsUseCase] Error: $error");
      _stacktraceManager.addTrace("[FetchAndSaveClaimsUseCase] Error: $error");
      _stacktraceManager.addError("[FetchAndSaveClaimsUseCase] Error: $error");
      rethrow;
    }
  }

  Future<List<ClaimEntity>> _fetchOnchainClaims(
    String contractAddress,
    String profileDid,
    List<String> bjjPublicKey,
    FetchOnchainClaimsParam param,
  ) async {
    final env = await _getEnvUseCase.execute();
    final chain = param.chainId != null
        ? env.chainConfigs[param.chainId!]
        : await _getSelectedChainUseCase.execute();

    final web3Client = getItSdk<Web3Client>(param1: chain!.rpcUrl);
    final deployedContract = await _localContractFilesDataSource
        .loadOnchainNonMerkelizedIssuerBaseContract(contractAddress);

    final issuer = Onchain_non_merkelized_issuer_base(
      address: deployedContract.address,
      client: web3Client,
    );
    final getIssuerId = Get_issuer_id_interface(
      address: deployedContract.address,
      client: web3Client,
    );

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
      throw FetchClaimException(
          errorMessage:
              "Contract at address $contractAddress does not support non-merkelized issuer interface");
    }

    final issuerIdInt = await getIssuerId.getId();
    final issuerDid = (await _identityRepository.describeId(
      id: issuerIdInt,
      config: env.config,
    ))
        .did;

    final info =
        await _didProfileInfoRepository.getDidProfileInfoByInteractedWithDid(
      interactedWithDid: issuerDid,
      genesisDid: param.genesisDid,
      encryptionKey: param.privateKey,
    );

    BigInt nonce;
    if (param.profileNonce != null) {
      nonce = param.profileNonce!;
    } else if (info.containsKey("privateProfileNonce")) {
      nonce = BigInt.parse(info["privateProfileNonce"] as String);
    } else {
      nonce = GENESIS_PROFILE_NONCE;
    }

    final did = await _getDidIdentifierUseCase.execute(
      param: GetDidIdentifierParam(
        bjjPublicKey: bjjPublicKey,
        blockchain: chain.blockchain,
        network: chain.network,
        profileNonce: nonce,
        method: chain.method,
      ),
    );

    // TODO OR

    final profileDid = _identityRepository.getPrivateProfileForGenesisDid(
      genesisDid: param.genesisDid,
      profileNonce: nonce,
    );

    final didEntity = await _getDidUseCase.execute(param: profileDid);
    final userId =
        await _identityRepository.convertIdToBigInt(id: didEntity.identifier);

    final adapterVersion = await issuer.getCredentialAdapterVersion();

    final credentialIds =
        await issuer.getUserCredentialIds(BigInt.parse(userId));

    final claims = <ClaimEntity>[];
    for (final credentialId in credentialIds) {
      try {
        final claim = await _fetchOnchainClaimUseCase.execute(
          param: FetchOnchainClaimParam(
            profileDid: profileDid,
            issuerDid: issuerDid,
            contractAddress: contractAddress,
            userId: BigInt.parse(userId),
            credentialId: credentialId,
            chainId: param.chainId,
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
          errorMessage: "Error fetching claim",
          error: e,
        );
      }
    }

    return claims;
  }
}
