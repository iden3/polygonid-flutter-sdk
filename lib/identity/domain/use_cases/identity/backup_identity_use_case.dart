import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/private_identity_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/get_identity_use_case.dart';

class BackupIdentityParam {
  final String genesisDid;
  final String encryptionKey;

  BackupIdentityParam({
    required this.genesisDid,
    required this.encryptionKey,
  });
}

class BackupIdentityUseCase extends FutureUseCase<BackupIdentityParam, String> {
  final GetIdentityUseCase _getIdentityUseCase;
  final IdentityRepository _identityRepository;
  final StacktraceManager _stacktraceManager;

  BackupIdentityUseCase(
    this._getIdentityUseCase,
    this._identityRepository,
    this._stacktraceManager,
  );

  @override
  Future<String> execute({required BackupIdentityParam param}) async {
    final identity = await _getIdentityUseCase.execute(
      param: GetIdentityParam(
        genesisDid: param.genesisDid,
      ),
    );

    try {
      final export = await _identityRepository.exportIdentity(
        did: identity.did,
        encryptionKey: param.encryptionKey,
      );
      logger().i(
          "[BackupIdentityUseCase] Identity backed up with did: ${identity.did}, for key $param");
      _stacktraceManager.addTrace(
          "[BackupIdentityUseCase] Identity backed up with did: ${identity.did}, for key $param");
      return export;
    } catch (error) {
      logger().e("[BackupIdentityUseCase] Error: $error");
      _stacktraceManager.addTrace("[BackupIdentityUseCase] Error: $error");
      _stacktraceManager.addError("[BackupIdentityUseCase] Error: $error");
      rethrow;
    }
  }
}
