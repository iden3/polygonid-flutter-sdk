import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/credential/domain/repositories/credential_repository.dart';
import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';

/// Get the AuthClaim for a given baby jub jub public key
class GetAuthClaimUseCase extends FutureUseCase<List<String>, List<String>> {
  final CredentialRepository _credentialRepo;
  final StacktraceManager _stacktraceManager;

  GetAuthClaimUseCase(
    this._credentialRepo,
    this._stacktraceManager,
  );

  /// [param] - BJJ public keys
  @override
  Future<List<String>> execute({required List<String> param}) {
    return Future(() async {
      final authClaim = await _credentialRepo.getAuthClaim(publicKey: param);

      logger().d("[GetIdentityAuthClaimUseCase] AuthClaim is $authClaim");

      return authClaim;
    }).catchError((error) {
      _stacktraceManager
          .addTrace("[GetIdentityAuthClaimUseCase] Error: $error");
      _stacktraceManager
          .addError("[GetIdentityAuthClaimUseCase] Error: $error");
      logger().e("[GetIdentityAuthClaimUseCase] Error: $error");

      throw error;
    });
  }
}
