import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/exceptions/identity_exceptions.dart';

class CheckProfileValidityParam {
  final BigInt profileNonce;

  CheckProfileValidityParam({required this.profileNonce});
}

class CheckProfileValidityUseCase
    extends FutureUseCase<CheckProfileValidityParam, void> {
  @override
  Future<void> execute({required CheckProfileValidityParam param}) async {
    BigInt base = BigInt.parse('2');
    int exponent = 248;
    final maxVal = base.pow(exponent) - BigInt.one;

    try {
      if (param.profileNonce.isNegative || (param.profileNonce >= maxVal)) {
        throw InvalidProfileException(
          profileNonce: param.profileNonce,
          errorMessage: "Profile nonce is invalid",
        );
      }
      logger().i("[CheckProfileValidityUseCase] Profile is valid");
    } catch (error) {
      logger().e("[CheckValidProfileUseCase] Error: $error");
      rethrow;
    }
  }
}
