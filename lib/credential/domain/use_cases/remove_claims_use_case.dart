import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';

import '../../../common/domain/domain_logger.dart';
import '../../../common/domain/use_case.dart';
import '../repositories/credential_repository.dart';

class RemoveClaimsParam {
  final List<String> claimIds;
  final String genesisDid;
  final String encryptionKey;

  RemoveClaimsParam({
    required this.claimIds,
    required this.genesisDid,
    required this.encryptionKey,
  });
}

class RemoveClaimsUseCase extends FutureUseCase<RemoveClaimsParam, void> {
  final CredentialRepository _credentialRepository;
  final StacktraceManager _stacktraceManager;

  RemoveClaimsUseCase(
    this._credentialRepository,
    this._stacktraceManager,
  );

  @override
  Future<void> execute({required RemoveClaimsParam param}) async {
    try {
      await _credentialRepository.removeClaims(
        claimIds: param.claimIds,
        genesisDid: param.genesisDid,
        encryptionKey: param.encryptionKey,
      );
      logger().i(
          "[RemoveClaimsUseCase] Claims with those ids have been removed: $param");
      _stacktraceManager.addTrace(
          "[RemoveClaimsUseCase] Claims with those ids have been removed: $param");
    } catch (error) {
      logger().e("[RemoveClaimsUseCase] Error: $error");
      _stacktraceManager.addTrace("[RemoveClaimsUseCase] Error: $error");
      _stacktraceManager.addError("[RemoveClaimsUseCase] Error: $error");
      rethrow;
    }
  }
}
