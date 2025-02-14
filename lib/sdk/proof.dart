import 'dart:async';
import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/env_entity.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/constants.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/identity/data/data_sources/lib_pidcore_identity_data_source.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/circuits_to_download_param.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/mtproof_dto.dart';
import 'package:polygonid_flutter_sdk/proof/data/repositories/crosschain_repository.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/download_info_entity.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/gist_mtproof_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/generate_inputs_response.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/zkproof_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/use_cases/cancel_download_circuits_use_case.dart';
import 'package:polygonid_flutter_sdk/proof/domain/use_cases/circuits_files_exist_use_case.dart';
import 'package:polygonid_flutter_sdk/proof/domain/use_cases/download_circuits_use_case.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/circuit_data_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/use_cases/generate_zkproof_use_case.dart';
import 'package:polygonid_flutter_sdk/proof/gist_proof_cache.dart';
import 'package:polygonid_flutter_sdk/proof/infrastructure/proof_generation_stream_manager.dart';
import 'package:polygonid_flutter_sdk/proof/proof_from_smart_contract.dart';
import 'package:polygonid_flutter_sdk/sdk/di/injector.dart';
import 'package:web3dart/web3dart.dart';

abstract class PolygonIdSdkProof {
  Future<ZKProofEntity> prove({
    required String identifier,
    required BigInt profileNonce,
    required BigInt claimSubjectProfileNonce,
    required ClaimEntity credential,
    required CircuitDataEntity circuitData,
    required Map<String, dynamic> proofScopeRequest,
    List<String>? authClaim,
    MTProofEntity? incProof,
    MTProofEntity? nonRevProof,
    GistMTProofEntity? gistProof,
    Map<String, dynamic>? treeState,
    String? challenge,
    String? signature,
    Map<String, dynamic>? config,
  });

  Future<List<MessageWithSignature>> getCrosschainProofs({
    required String universalResolverUrl,
    required List<PublicStatesInfo> stateInfo,
  });

  Stream<DownloadInfo> initCircuitsDownloadAndGetInfoStream({
    required List<CircuitsToDownloadParam> circuitsToDownload,
  });

  Future<bool> isAlreadyDownloadedCircuitsFromServer(
      {required String circuitsFileName});

  Stream<String> proofGenerationStepsStream();

  Future<void> cancelDownloadCircuits();

  Future<String> getProofFromSmartContract({required String inputs});
}

@injectable
class Proof implements PolygonIdSdkProof {
  final GenerateZKProofUseCase generateZKProofUseCase;
  final DownloadCircuitsUseCase _downloadCircuitsUseCase;
  final CircuitsFilesExistUseCase _circuitsFilesExistUseCase;
  final ProofGenerationStepsStreamManager _proofGenerationStepsStreamManager;
  final CancelDownloadCircuitsUseCase _cancelDownloadCircuitsUseCase;
  final CrosschainRepository _crosschainRepository;
  final StacktraceManager _stacktraceManager;

  Proof(
    this.generateZKProofUseCase,
    this._downloadCircuitsUseCase,
    this._circuitsFilesExistUseCase,
    this._proofGenerationStepsStreamManager,
    this._cancelDownloadCircuitsUseCase,
    this._crosschainRepository,
    this._stacktraceManager,
  );

  @override
  Future<ZKProofEntity> prove({
    required String identifier,
    required BigInt profileNonce,
    required BigInt claimSubjectProfileNonce,
    required ClaimEntity credential,
    required CircuitDataEntity circuitData,
    required Map<String, dynamic> proofScopeRequest,
    List<String>? authClaim,
    MTProofEntity? incProof,
    MTProofEntity? nonRevProof,
    GistMTProofEntity? gistProof,
    Map<String, dynamic>? treeState,
    String? challenge,
    String? signature,
    Map<String, dynamic>? config,
    String? verifierId,
    String? linkNonce,
    Map<String, dynamic>? transactionData,
  }) {
    _stacktraceManager.clear();
    _stacktraceManager.addTrace("PolygonIdSdk.Proof.prove called");
    return generateZKProofUseCase.execute(
        param: GenerateZKProofParam(
      identifier,
      profileNonce,
      claimSubjectProfileNonce,
      credential,
      circuitData,
      authClaim,
      incProof,
      nonRevProof,
      gistProof,
      treeState,
      challenge,
      signature,
      proofScopeRequest,
      config,
      verifierId,
      linkNonce,
      transactionData,
    ));
  }

  @override
  Future<List<MessageWithSignature>> getCrosschainProofs({
    required String universalResolverUrl,
    required List<PublicStatesInfo> stateInfo,
  }) async {
    return _crosschainRepository.getCrosschainStatesWithSignatures(
      universalResolverUrl: universalResolverUrl,
      stateInfo: stateInfo,
    );
  }

  ///
  @override
  Future<bool> isAlreadyDownloadedCircuitsFromServer(
      {required String circuitsFileName}) async {
    _stacktraceManager.clear();
    _stacktraceManager.addTrace(
        "PolygonIdSdk.Proof.isAlreadyDownloadedCircuitsFromServer called");
    return _circuitsFilesExistUseCase.execute(param: circuitsFileName);
  }

  ///
  @override
  Stream<DownloadInfo> initCircuitsDownloadAndGetInfoStream({
    required List<CircuitsToDownloadParam> circuitsToDownload,
  }) {
    return _downloadCircuitsUseCase.execute(
      param: DownloadCircuitsParam(circuitsToDownload: circuitsToDownload),
    );
  }

  /// Returns a [Stream] of [String] of proof generation steps
  @override
  Stream<String> proofGenerationStepsStream() {
    return _proofGenerationStepsStreamManager.proofGenerationStepsStream;
  }

  /// Cancel the download of circuits
  @override
  Future<void> cancelDownloadCircuits() async {
    _stacktraceManager.clear();
    _stacktraceManager
        .addTrace("PolygonIdSdk.Proof.cancelDownloadCircuits called");
    return _cancelDownloadCircuitsUseCase.execute();
  }

  /// use getGistProof method to get the gist proof, inside the method it will check if the proof is already cached
  /// if not, it will download the Gist from the SC and cache it
  /// [genesisDid]: the genesis DID
  /// [env]: the environment
  Future<String?> preCacheGistProof({
    required String genesisDid,
    required EnvEntity env,
    required String stateContractAddress,
  }) async {
    try {
      List<String> splittedDid = genesisDid.split(":");
      String id = splittedDid[4];
      var libPolygonIdIdentity = getItSdk<LibPolygonIdCoreIdentityDataSource>();
      String convertedId = libPolygonIdIdentity.genesisIdToBigInt(id);
      ContractAbi contractAbi = ContractAbi.fromJson(
          jsonEncode(jsonDecode(stateAbiJson)["abi"]), 'State');
      EthereumAddress ethereumAddress =
          EthereumAddress.fromHex(stateContractAddress);
      DeployedContract contract =
          DeployedContract(contractAbi, ethereumAddress);
      String? cachedGistProof = await GistProofCache().getGistProof(
        id: convertedId,
        deployedContract: contract,
        envEntity: env,
      );
      return cachedGistProof;
    } catch (e) {
      _stacktraceManager
          .addTrace("PolygonIdSdk.Proof.preCacheGistProof error: $e");
      return null;
    }
  }

  Future<String> getProofFromSmartContract({required String inputs}) async {
    String proof = await ProofFromSmartContract()
        .getProofFromSmartContract(inputs: inputs);
    return proof;
  }
}
