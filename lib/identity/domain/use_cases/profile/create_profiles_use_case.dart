import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_current_env_did_identifier_use_case.dart';

import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';

class CreateProfilesParam {
  final List<String> bjjPublicKey;
  final List<BigInt> profiles;

  CreateProfilesParam({
    required this.bjjPublicKey,
    this.profiles = const [],
  });
}

class CreateProfilesUseCase
    extends FutureUseCase<CreateProfilesParam, Map<BigInt, String>> {
  final GetCurrentEnvDidIdentifierUseCase _getCurrentEnvDidIdentifierUseCase;
  final StacktraceManager _stacktraceManager;

  CreateProfilesUseCase(
    this._getCurrentEnvDidIdentifierUseCase,
    this._stacktraceManager,
  );

  @override
  Future<Map<BigInt, String>> execute({
    required CreateProfilesParam param,
  }) async {
    return Future(() async {
      String didIdentifier = await _getCurrentEnvDidIdentifierUseCase.execute(
        param: GetCurrentEnvDidIdentifierParam(
          bjjPublicKey: param.bjjPublicKey,
          profileNonce: BigInt.zero,
        ),
      );
      Map<BigInt, String> profiles = {BigInt.zero: didIdentifier};

      for (BigInt profile in param.profiles) {
        String profileDid = await _getCurrentEnvDidIdentifierUseCase.execute(
          param: GetCurrentEnvDidIdentifierParam(
            bjjPublicKey: param.bjjPublicKey,
            profileNonce: profile,
          ),
        );
        profiles[profile] = profileDid;
      }

      return profiles;
    }).then((profiles) {
      _stacktraceManager.addTrace(
          "[CreateProfilesUseCase] Profiles created with values: $profiles, for param $param");
      logger().i(
          "[CreateProfilesUseCase] Profiles created with values: $profiles, for param $param");

      return profiles;
    }).catchError((error) {
      _stacktraceManager
          .addTrace("[CreateProfilesUseCase] Error: $error for param $param");
      _stacktraceManager
          .addError("[CreateProfilesUseCase] Error: $error for param $param");
      logger().e("[CreateProfilesUseCase] Error: $error for param $param");

      throw error;
    });
  }
}
