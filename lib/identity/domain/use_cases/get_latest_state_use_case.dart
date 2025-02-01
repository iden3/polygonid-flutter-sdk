import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/tree_state_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/tree_type.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/smt_repository.dart';

class GetLatestStateParam {
  final String did;
  final String encryptionKey;

  GetLatestStateParam({
    required this.did,
    required this.encryptionKey,
  });
}

class GetLatestStateUseCase
    extends FutureUseCase<GetLatestStateParam, Map<String, dynamic>> {
  final SMTRepository _smtRepository;
  final StacktraceManager _stacktraceManager;

  GetLatestStateUseCase(
    this._smtRepository,
    this._stacktraceManager,
  );

  @override
  Future<Map<String, dynamic>> execute({required GetLatestStateParam param}) {
    return Future.wait(
      [
        _smtRepository.getRoot(
          type: TreeType.claims,
          did: param.did,
          encryptionKey: param.encryptionKey,
        ),
        _smtRepository.getRoot(
          type: TreeType.revocation,
          did: param.did,
          encryptionKey: param.encryptionKey,
        ),
        _smtRepository.getRoot(
          type: TreeType.roots,
          did: param.did,
          encryptionKey: param.encryptionKey,
        ),
      ],
      eagerError: true,
    ).then((trees) async {
      final hash = await _smtRepository.hashState(
        claims: trees[0].string(),
        revocation: trees[1].string(),
        roots: trees[2].string(),
      );
      final state = TreeStateEntity(hash, trees[0], trees[1], trees[2]);
      final convertedState = await _smtRepository.convertState(state: state);

      _stacktraceManager
          .addTrace("[GetLatestStateUseCase] State: $convertedState");
      logger().i("[GetLatestStateUseCase] State: $convertedState");

      return convertedState;
    }).catchError((error) {
      _stacktraceManager.addTrace("[GetLatestStateUseCase] Error: $error");
      _stacktraceManager.addError("[GetLatestStateUseCase] Error: $error");
      logger().e("[GetLatestStateUseCase] Error: $error");

      throw error;
    });
  }
}
