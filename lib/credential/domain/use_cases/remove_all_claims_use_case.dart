import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';

import '../../../common/domain/domain_logger.dart';
import '../../../common/domain/use_case.dart';
import '../repositories/credential_repository.dart';

class RemoveAllClaimsParam {
  final String did;
  final String encryptionKey;

  RemoveAllClaimsParam({
    required this.did,
    required this.encryptionKey,
  });
}

class RemoveAllClaimsUseCase extends FutureUseCase<RemoveAllClaimsParam, void> {
  final CredentialRepository _credentialRepository;
  final StacktraceManager _stacktraceManager;

  RemoveAllClaimsUseCase(
    this._credentialRepository,
    this._stacktraceManager,
  );

  @override
  Future<void> execute({required RemoveAllClaimsParam param}) async {
    try {
      await _credentialRepository.removeAllClaims(
        genesisDid: param.did,
        encryptionKey: param.encryptionKey,
      );
      logger().i("[RemoveAllClaimsUseCase] Claims have been removed: $param");
      _stacktraceManager.addTrace(
          "[RemoveAllClaimsUseCase] Claims have been removed: $param");
    } catch (error) {
      logger().e("[RemoveAllClaimsUseCase] Error: $error");
      _stacktraceManager.addTrace("[RemoveAllClaimsUseCase] Error: $error");
      _stacktraceManager.addError("[RemoveAllClaimsUseCase] Error: $error");
      rethrow;
    }
  }
}
