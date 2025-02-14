import 'dart:async';
import 'dart:typed_data';

import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/error_exception.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_cases/get_env_use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/credential/data/dtos/claim_dto.dart';
import 'package:polygonid_flutter_sdk/credential/data/mappers/claim_mapper.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/identity/data/data_sources/local_contract_files_data_source.dart';
import 'package:polygonid_flutter_sdk/identity/data/dtos/circuit_type.dart';
import 'package:polygonid_flutter_sdk/proof/data/data_sources/circuits_download_data_source.dart';
import 'package:polygonid_flutter_sdk/proof/data/data_sources/circuits_files_data_source.dart';
import 'package:polygonid_flutter_sdk/proof/data/data_sources/gist_mtproof_data_source.dart';
import 'package:polygonid_flutter_sdk/proof/data/data_sources/lib_pidcore_proof_data_source.dart';
import 'package:polygonid_flutter_sdk/proof/data/data_sources/proof_circuit_data_source.dart';
import 'package:polygonid_flutter_sdk/proof/data/data_sources/prover_lib_data_source.dart';
import 'package:polygonid_flutter_sdk/proof/data/data_sources/witness_data_source.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/circuits_to_download_param.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/gist_mtproof_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/circuit_data_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/download_info_entity.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/mtproof_dto.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/generate_inputs_response.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/zkproof_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/exceptions/proof_generation_exceptions.dart';
import 'package:polygonid_flutter_sdk/proof/domain/repositories/proof_repository.dart';
import 'package:polygonid_flutter_sdk/proof/gist_proof_cache.dart';
import 'package:polygonid_flutter_sdk/proof/proof_from_smart_contract.dart';

class ProofRepositoryImpl extends ProofRepository {
  final WitnessDataSource _witnessDataSource;
  final ProverLibDataSource _proverLibDataSource;
  final LibPolygonIdCoreProofDataSource _libPolygonIdCoreProofDataSource;
  final GistMTProofDataSource _gistProofDataSource;
  final ProofCircuitDataSource _proofCircuitDataSource;
  final LocalContractFilesDataSource _localContractFilesDataSource;
  final CircuitsDownloadDataSource _circuitsDownloadDataSource;
  final CircuitsFilesDataSource _circuitsFilesDataSource;
  final GetEnvUseCase _getEnvUseCase;
  final StacktraceManager _stacktraceManager;

  // FIXME: those mappers shouldn't be used here as they are part of Credential
  final ClaimMapper _claimMapper;

  ProofRepositoryImpl(
    this._witnessDataSource,
    this._proverLibDataSource,
    this._libPolygonIdCoreProofDataSource,
    this._gistProofDataSource,
    this._proofCircuitDataSource,
    this._localContractFilesDataSource,
    this._circuitsDownloadDataSource,
    this._claimMapper,
    this._circuitsFilesDataSource,
    this._getEnvUseCase,
    this._stacktraceManager,
  );

  @override
  Future<CircuitDataEntity> loadCircuitFiles(String circuitId) async {
    final circuitDatFile =
        await _circuitsFilesDataSource.loadGraphFile(circuitId);
    final zkeyFilePath = await _circuitsFilesDataSource.getZkeyFilePath(
      circuitId,
    );
    final circuitDataEntity = CircuitDataEntity(
      circuitId,
      circuitDatFile,
      zkeyFilePath,
    );
    return circuitDataEntity;
  }

  @override
  Future<GenerateInputsResponse> calculateAtomicQueryInputs({
    required String id,
    required BigInt profileNonce,
    required BigInt claimSubjectProfileNonce,
    required ClaimEntity claim,
    required Map<String, dynamic> proofScopeRequest,
    required String circuitId,
    MTProofEntity? incProof,
    MTProofEntity? nonRevProof,
    GistMTProofEntity? gistProof,
    List<String>? authClaim,
    Map<String, dynamic>? treeState,
    Map<String, dynamic>? config,
    String? challenge,
    String? signature,
    String? verifierId,
    String? linkNonce,
    Map<String, dynamic>? scopeParams,
    Map<String, dynamic>? transactionData,
  }) async {
    ClaimDTO credentialDto = _claimMapper.mapTo(claim);

    final gistProofMap = gistProof?.toJson();
    final incProofMap = incProof?.toJson();
    final nonRevProofMap = nonRevProof?.toJson();

    _stacktraceManager.addTrace("getProofInputs id: $id");
    _stacktraceManager.addTrace("getProofInputs profileNonce: $profileNonce");
    _stacktraceManager.addTrace(
        "getProofInputs claimSubjectProfileNonce: $claimSubjectProfileNonce");
    _stacktraceManager.addTrace("getProofInputs authClaim: $authClaim");
    _stacktraceManager.addTrace("getProofInputs incProof: $incProofMap");
    _stacktraceManager.addTrace("getProofInputs nonRevProof: $nonRevProofMap");
    _stacktraceManager.addTrace("getProofInputs gistProof: $gistProofMap");
    _stacktraceManager.addTrace("getProofInputs treeState: $treeState");
    _stacktraceManager.addTrace("getProofInputs challenge: $challenge");
    _stacktraceManager.addTrace("getProofInputs signature: $signature");
    _stacktraceManager
        .addTrace("getProofInputs credential: ${credentialDto.info}");
    _stacktraceManager.addTrace("getProofInputs request: $proofScopeRequest");
    _stacktraceManager.addTrace("getProofInputs circuitId: $circuitId");

    GenerateInputsResponse? res;
    try {
      res = await _libPolygonIdCoreProofDataSource.getProofInputs(
        id: id,
        profileNonce: profileNonce,
        claimSubjectProfileNonce: claimSubjectProfileNonce,
        authClaim: authClaim,
        incProof: incProofMap,
        nonRevProof: nonRevProofMap,
        gistProof: gistProofMap,
        treeState: treeState,
        challenge: challenge,
        signature: signature,
        credential: credentialDto.info,
        request: proofScopeRequest,
        circuitId: circuitId,
        config: config,
        verifierId: verifierId,
        linkNonce: linkNonce,
        scopeParams: scopeParams,
        transactionData: transactionData,
      );
    } on PolygonIdSDKException catch (error) {
      _stacktraceManager.addTrace(
          "[calculateAtomicQueryInputs/libPolygonIdCoreProof] exception ${error.errorMessage}");
      rethrow;
    } catch (e) {
      throw NullAtomicQueryInputsException(
        id: id,
        errorMessage: "Error in getProofInputs: $e",
        error: e,
      );
    }

    if (res.inputs.isEmpty) {
      _stacktraceManager.addTrace(
          "[calculateAtomicQueryInputs/libPolygonIdCoreProof] NullAtomicQueryInputsException");
      throw NullAtomicQueryInputsException(
        id: id,
        errorMessage: "Empty inputs result",
      );
    }

    _stacktraceManager.addTrace("atomicQueryInputs result: success");
    return res;
  }

  @override
  Future<Uint8List> calculateWitness({
    required CircuitDataEntity circuitData,
    required String atomicQueryInputs,
  }) async {
    _stacktraceManager.addTrace(
        "[calculateWitness] circuitData.circuitId ${circuitData.circuitId}");
    final circuitType = CircuitType.fromString(circuitData.circuitId);
    try {
      Uint8List? witness = await _witnessDataSource.computeWitness(
        inputsJson: atomicQueryInputs,
        circuitGraphFile: circuitData.witnessCalculationData,
      );
      if (witness == null) {
        throw NullWitnessException(
          circuit: circuitType.name,
          errorMessage: "Empty witness result for circuit ${circuitType.name}",
        );
      } else {
        return witness;
      }
    } on PolygonIdSDKException catch (_) {
      rethrow;
    } catch (error) {
      _stacktraceManager.addTrace("[calculateWitness] NullWitnessException");
      throw NullWitnessException(
        circuit: circuitData.circuitId,
        errorMessage:
            "Empty witness result for circuit ${circuitData.circuitId} with error: $error",
        error: error,
      );
    }
  }

  @override
  Future<ZKProofEntity> prove({
    required CircuitDataEntity circuitData,
    required Uint8List wtnsBytes,
  }) async {
    try {
      Stopwatch stopwatch = Stopwatch()..start();

      final Map<String, dynamic>? proof = await _proverLibDataSource.prove(
        circuitData.zKeyPath,
        wtnsBytes,
      );

      _stacktraceManager.addTrace(
          "[ProveUseCase][MainFlow] proof generated in ${stopwatch.elapsedMilliseconds} ms");
      logger().i(
          "[ProveUseCase][MainFlow] proof generated in ${stopwatch.elapsedMilliseconds} ms");
      logger().i("[ProveUseCase] proof: $proof");

      if (proof == null || proof.isEmpty) {
        _stacktraceManager
            .addTrace("[prove] NullProofException, proof is null");
        throw NullProofException(
          circuit: circuitData.circuitId,
          errorMessage: "Empty proof result",
        );
      }

      final ZKProofEntity zkProof = ZKProofEntity.fromJson(proof);
      return zkProof;
    } on PolygonIdSDKException catch (_) {
      rethrow;
    } catch (error) {
      throw NullProofException(
        circuit: circuitData.circuitId,
        errorMessage: "Error in _computeProve: $error",
        error: error,
      );
    }
  }

  @override
  Future<bool> isCircuitSupported({required String circuitId}) async {
    final circuitType = CircuitType.fromString(circuitId);
    return _proofCircuitDataSource.isCircuitSupported(circuit: circuitType);
  }

  @override
  Future<GistMTProofEntity> getGistProof({
    required String idAsInt,
    required String contractAddress,
  }) async {
    try {
      final envEntity = await _getEnvUseCase.execute();
      final contract = await _localContractFilesDataSource.loadStateContract(
        contractAddress,
      );

      String gistProof = await GistProofCache().getGistProof(
        id: idAsInt,
        deployedContract: contract,
        envEntity: envEntity,
      );

      return _gistProofDataSource.getGistMTProof(gistProof);
    } on PolygonIdSDKException catch (_) {
      rethrow;
    } catch (error) {
      throw FetchGistProofException(
        errorMessage: "Error in getGistProof: $error",
        error: error,
      );
    }
  }

  @override
  Stream<DownloadInfo> circuitsDownloadInfoStream(
      {required List<CircuitsToDownloadParam> circuitsToDownload}) async* {
    await for (final downloadResponse
        in _circuitsDownloadDataSource.downloadStream) {
      int progress = downloadResponse.progress;
      int total = downloadResponse.total;

      if (downloadResponse.errorOccurred) {
        yield DownloadInfo.onError(
          errorMessage: downloadResponse.errorMessage,
        );
      }

      if (downloadResponse.done) {
        final int downloadSize = _circuitsDownloadDataSource.downloadSize;

        int totalZipFileSize = 0;

        for (CircuitsToDownloadParam param in circuitsToDownload) {
          if (param.downloadPath == null) {
            continue;
          }
          String pathForZipFileTemp = param.downloadPath!;
          String pathForZipFile = await _circuitsFilesDataSource
              .getPathToCircuitZipFile(circuitsFileName: param.circuitsName);
          String pathForCircuits = await _circuitsFilesDataSource.getPath();

          // we get the size of the temp zip file
          int zipFileSize = _circuitsFilesDataSource.zipFileSize(
              pathToFile: pathForZipFileTemp);

          totalZipFileSize += zipFileSize;

          await _completeWritingFile(
            pathForCircuits: pathForCircuits,
            pathForZipFile: pathForZipFile,
            pathForZipFileTemp: pathForZipFileTemp,
          );
        }

        if (downloadSize != 0 && totalZipFileSize != downloadSize) {
          try {
            // if error we delete the temp file
            for (CircuitsToDownloadParam param in circuitsToDownload) {
              if (param.downloadPath == null) {
                continue;
              }
              String pathForZipFileTemp = param.downloadPath!;
              _circuitsFilesDataSource.deleteFile(pathForZipFileTemp);
            }
          } catch (_) {}

          yield DownloadInfo.onError(
              errorMessage: "Downloaded files incorrect");
        }

        yield DownloadInfo.onDone(
          contentLength: downloadSize,
          downloaded: totalZipFileSize,
        );
      }

      yield DownloadInfo.onProgress(
        contentLength: total,
        downloaded: progress,
      );
    }
  }

  ///
  @override
  Future<void> initCircuitsDownloadFromServer({
    required List<CircuitsToDownloadParam> circuitsToDownload,
  }) async {
    for (int i = 0; i < circuitsToDownload.length; i++) {
      CircuitsToDownloadParam param = circuitsToDownload[i];
      String path = await _circuitsFilesDataSource.getPathToCircuitZipFileTemp(
          circuitsFileName: param.circuitsName);
      // we delete the file if it exists
      await _circuitsFilesDataSource.deleteFile(path);
      circuitsToDownload[i].downloadPath = path;
    }
    return _circuitsDownloadDataSource.initStreamedResponseFromServer(
      circuitsToDownload: circuitsToDownload,
    );
  }

  ///
  @override
  Future<bool> circuitsFilesExist({required String circuitsFileName}) {
    return _circuitsFilesDataSource.circuitsFilesExist(
        circuitsFileName: circuitsFileName);
  }

  ///
  Future<void> _completeWritingFile({
    required String pathForZipFileTemp,
    required String pathForZipFile,
    required String pathForCircuits,
  }) async {
    _circuitsFilesDataSource.renameFile(pathForZipFileTemp, pathForZipFile);
    await _circuitsFilesDataSource.writeCircuitsFileFromZip(
      zipPath: pathForZipFile,
      path: pathForCircuits,
    );
  }

  @override
  Future<void> cancelDownloadCircuits() async {
    return _circuitsDownloadDataSource.cancelDownload();
  }

  @override
  Future<String> getProofFromSmartContract({required String inputs}) async {
    String proof = await ProofFromSmartContract()
        .getProofFromSmartContract(inputs: inputs);
    return proof;
  }
}
