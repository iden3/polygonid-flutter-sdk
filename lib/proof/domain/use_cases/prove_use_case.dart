import 'dart:typed_data';
import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/circuit_data_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/zkproof_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/repositories/proof_repository.dart';

class ProveParam {
  final String inputs;
  final CircuitDataEntity circuitData;

  ProveParam(this.inputs, this.circuitData);
}

class ProveUseCase extends FutureUseCase<ProveParam, ZKProofEntity> {
  final ProofRepository _proofRepository;
  final StacktraceManager _stacktraceManager;

  ProveUseCase(
    this._proofRepository,
    this._stacktraceManager,
  );

  @override
  Future<ZKProofEntity> execute({required ProveParam param}) async {
    Stopwatch stopwatch = Stopwatch()..start();
    try {
      logger().i('ProveUseCase: input: ${param.inputs}');
      // Calculate witness
      Uint8List wtnsBytes = await _proofRepository.calculateWitness(
        circuitData: param.circuitData,
        atomicQueryInputs: param.inputs,
      );
      logger().i(
          'ProveUseCase: calculateWitness: ${stopwatch.elapsedMilliseconds} ms');

      // Generate proof
      ZKProofEntity zkProofEntity = await _proofRepository.prove(
        circuitData: param.circuitData,
        wtnsBytes: wtnsBytes,
      );

      return zkProofEntity;
    } catch (error) {
      _stacktraceManager.addTrace("[ProveUseCase] Error: $error");
      _stacktraceManager.addError("[ProveUseCase] Error: $error");
      logger().e("[ProveUseCase] Error: $error");
      rethrow;
    }
  }
}
