import 'package:polygonid_flutter_sdk/common/domain/domain_constants.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/identity_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_current_env_did_identifier_use_case.dart';

import '../../../../common/domain/domain_logger.dart';
import '../../../../common/domain/use_case.dart';

class CreateIdentityParam {
  final List<String> bjjPublicKey;
  final List<BigInt> profiles;

  CreateIdentityParam({
    required this.bjjPublicKey,
    this.profiles = const [],
  });
}

class CreateIdentityUseCase
    extends FutureUseCase<CreateIdentityParam, IdentityEntity> {
  final GetCurrentEnvDidIdentifierUseCase _getCurrentEnvDidIdentifierUseCase;
  final StacktraceManager _stacktraceManager;

  CreateIdentityUseCase(
    this._getCurrentEnvDidIdentifierUseCase,
    this._stacktraceManager,
  );

  @override
  Future<IdentityEntity> execute({
    required CreateIdentityParam param,
  }) async {
    return Future(() async {
      final didIdentifier = await _getCurrentEnvDidIdentifierUseCase.execute(
        param: GetCurrentEnvDidIdentifierParam(
          bjjPublicKey: param.bjjPublicKey,
          profileNonce: GENESIS_PROFILE_NONCE,
        ),
      );
      Map<BigInt, String> profiles = {GENESIS_PROFILE_NONCE: didIdentifier};

      for (BigInt profile in param.profiles) {
        String identifier = await _getCurrentEnvDidIdentifierUseCase.execute(
          param: GetCurrentEnvDidIdentifierParam(
            bjjPublicKey: param.bjjPublicKey,
            profileNonce: profile,
          ),
        );
        profiles[profile] = identifier;
      }

      logger().i(
          "[CreateIdentityUseCase] Identity created with did: $didIdentifier, for param $param");
      _stacktraceManager.addTrace(
          "[CreateIdentityUseCase] Identity created with did: $didIdentifier, for param $param");

      return IdentityEntity(
        did: didIdentifier,
        publicKey: param.bjjPublicKey,
        profiles: profiles,
      );
    }).catchError((error) {
      logger().e("[CreateIdentityUseCase] Error: $error for param $param");
      _stacktraceManager
          .addTrace("[CreateIdentityUseCase] Error: $error for param $param");
      _stacktraceManager
          .addError("[CreateIdentityUseCase] Error: $error for param $param");

      throw error;
    });
  }
}
