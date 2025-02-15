import 'package:polygonid_flutter_sdk/common/domain/domain_constants.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/private_identity_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_current_env_did_identifier_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_public_keys_use_case.dart';

import '../../../../common/domain/domain_logger.dart';
import '../../../../common/domain/use_case.dart';

class CreateIdentityParam {
  final String privateKey;
  final List<BigInt> profiles;

  CreateIdentityParam({
    required this.privateKey,
    this.profiles = const [],
  });
}

class CreateIdentityUseCase
    extends FutureUseCase<CreateIdentityParam, PrivateIdentityEntity> {
  final GetPublicKeysUseCase _getPubKeysUseCase;
  final GetCurrentEnvDidIdentifierUseCase _getCurrentEnvDidIdentifierUseCase;
  final StacktraceManager _stacktraceManager;

  CreateIdentityUseCase(
    this._getPubKeysUseCase,
    this._getCurrentEnvDidIdentifierUseCase,
    this._stacktraceManager,
  );

  @override
  Future<PrivateIdentityEntity> execute({
    required CreateIdentityParam param,
  }) async {
    final publicKey = await _getPubKeysUseCase.execute(param: param.privateKey);
    return Future(() async {
      final didIdentifier = await _getCurrentEnvDidIdentifierUseCase.execute(
        param: GetCurrentEnvDidIdentifierParam(
          publicKey: publicKey,
          profileNonce: GENESIS_PROFILE_NONCE,
        ),
      );
      Map<BigInt, String> profiles = {GENESIS_PROFILE_NONCE: didIdentifier};

      for (BigInt profile in param.profiles) {
        String identifier = await _getCurrentEnvDidIdentifierUseCase.execute(
          param: GetCurrentEnvDidIdentifierParam(
            publicKey: publicKey,
            profileNonce: profile,
          ),
        );
        profiles[profile] = identifier;
      }

      final identity = PrivateIdentityEntity(
        did: didIdentifier,
        publicKey: publicKey,
        profiles: profiles,
        privateKey: param.privateKey,
      );

      logger().i(
          "[CreateIdentityUseCase] Identity created with did: ${identity.did}, for param $param");
      _stacktraceManager.addTrace(
          "[CreateIdentityUseCase] Identity created with did: ${identity.did}, for param $param");

      return identity;
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
