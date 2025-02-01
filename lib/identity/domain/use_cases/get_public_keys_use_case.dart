import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';

class GetPublicKeyUseCase extends FutureUseCase<String, List<String>> {
  final IdentityRepository _identityRepository;
  final StacktraceManager _stacktraceManager;

  GetPublicKeyUseCase(
    this._identityRepository,
    this._stacktraceManager,
  );

  @override
  Future<List<String>> execute({required String param}) {
    return Future(() async {
      final publicKeys =
          await _identityRepository.getPublicKeys(bjjPrivateKey: param);

      logger()
          .i("[GetPublicKeysUseCase] Message $param publicKeys: $publicKeys");
      _stacktraceManager
          .addTrace("[GetPublicKeysUseCase] Message $param publicKeys");

      return publicKeys;
    }).catchError((error) {
      logger().e("[GetPublicKeysUseCase] Error: $error");
      _stacktraceManager.addTrace("[GetPublicKeysUseCase] Error: $error");
      _stacktraceManager.addError("[GetPublicKeysUseCase] Error: $error");

      throw error;
    });
  }
}
