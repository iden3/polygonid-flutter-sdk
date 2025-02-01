import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/tree_type.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/smt_repository.dart';

import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';

class RemoveIdentityStateParam {
  final String did;
  final String encryptionKey;

  RemoveIdentityStateParam({
    required this.did,
    required this.encryptionKey,
  });
}

class RemoveIdentityStateUseCase
    extends FutureUseCase<RemoveIdentityStateParam, void> {
  final SMTRepository _smtRepository;
  final StacktraceManager _stacktraceManager;

  RemoveIdentityStateUseCase(
    this._smtRepository,
    this._stacktraceManager,
  );

  @override
  Future<void> execute({required RemoveIdentityStateParam param}) {
    return Future.wait([
      _smtRepository.removeSMT(
        type: TreeType.claims,
        did: param.did,
        encryptionKey: param.encryptionKey,
      ),
      _smtRepository.removeSMT(
        type: TreeType.revocation,
        did: param.did,
        encryptionKey: param.encryptionKey,
      ),
      _smtRepository.removeSMT(
        type: TreeType.roots,
        did: param.did,
        encryptionKey: param.encryptionKey,
      ),
    ]).then((did) {
      _stacktraceManager.addTrace(
          "[RemoveIdentityStateUseCase] State has been removed for did: $did");
      logger().i(
          "[RemoveIdentityStateUseCase] State has been removed for did: $did");
    }).catchError((error) {
      _stacktraceManager.addTrace("[RemoveIdentityStateUseCase] Error: $error");
      _stacktraceManager.addError("[RemoveIdentityStateUseCase] Error: $error");
      logger().e("[RemoveIdentityStateUseCase] Error: $error");
      throw error;
    });
  }
}
