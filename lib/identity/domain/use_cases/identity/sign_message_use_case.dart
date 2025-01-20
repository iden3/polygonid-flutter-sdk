import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';

class SignMessageParam {
  final String privateKey;
  final String message;

  SignMessageParam(this.privateKey, this.message);
}

class SignMessageUseCase extends FutureUseCase<SignMessageParam, String> {
  final IdentityRepository _identityRepository;

  SignMessageUseCase(this._identityRepository);

  @override
  Future<String> execute({required SignMessageParam param}) async {
    try {
      final signature = await _identityRepository.signMessage(
        privateKey: param.privateKey,
        message: param.message,
      );
      logger().i(
          "[SignMessageUseCase] message ${param.message} with privateKey ${param.privateKey} signed successfully: $signature");

      return signature;
    } catch (error) {
      logger().e("[SignMessageUseCase] Error: $error");

      rethrow;
    }
  }
}
