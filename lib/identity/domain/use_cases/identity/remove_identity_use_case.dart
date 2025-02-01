import 'package:polygonid_flutter_sdk/common/domain/domain_constants.dart';
import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/remove_all_claims_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/check_profile_and_did_current_env.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/profile/get_profiles_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/profile/remove_profile_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/smt/remove_identity_state_use_case.dart';

class RemoveIdentityParam {
  final String genesisDid;
  final String privateKey;

  RemoveIdentityParam({
    required this.genesisDid,
    required this.privateKey,
  });
}

class RemoveIdentityUseCase extends FutureUseCase<RemoveIdentityParam, void> {
  final IdentityRepository _identityRepository;
  final GetProfilesUseCase _getProfilesUseCase;
  final RemoveProfileUseCase _removeProfileUseCase;
  final RemoveIdentityStateUseCase _removeIdentityStateUseCase;
  final RemoveAllClaimsUseCase _removeAllClaimsUseCase;
  final CheckProfileAndDidCurrentEnvUseCase
      _checkProfileAndDidCurrentEnvUseCase;
  final StacktraceManager _stacktraceManager;

  RemoveIdentityUseCase(
    this._identityRepository,
    this._getProfilesUseCase,
    this._removeProfileUseCase,
    this._removeIdentityStateUseCase,
    this._removeAllClaimsUseCase,
    this._checkProfileAndDidCurrentEnvUseCase,
    this._stacktraceManager,
  );

  @override
  Future<void> execute({required RemoveIdentityParam param}) async {
    final encryptionKey = param.privateKey;
    try {
      await _checkProfileAndDidCurrentEnvUseCase.execute(
        param: CheckProfileAndDidCurrentEnvParam.withPrivateKey(
          did: param.genesisDid,
          privateKey: param.privateKey,
          profileNonce: GENESIS_PROFILE_NONCE,
        ),
      );

      Map<BigInt, String> profilesMap = await _getProfilesUseCase.execute(
        param: GetProfilesParam(
          genesisDid: param.genesisDid,
          privateKey: param.privateKey,
        ),
      );

      // remove identity state and claims for each profile did
      if (profilesMap.isNotEmpty) {
        for (BigInt profileNonce in profilesMap.keys) {
          if (profileNonce > GENESIS_PROFILE_NONCE) {
            await _removeProfileUseCase.execute(
              param: RemoveProfileParam(
                genesisDid: param.genesisDid,
                profileNonce: profileNonce,
                privateKey: param.privateKey,
              ),
            );
          }
        }
      }
      // Remove genesisId identity state and claims
      await _removeIdentityStateUseCase.execute(
        param: RemoveIdentityStateParam(
          did: param.genesisDid,
          encryptionKey: encryptionKey,
        ),
      );

      await _removeAllClaimsUseCase.execute(
        param: RemoveAllClaimsParam(
          did: param.genesisDid,
          encryptionKey: encryptionKey,
        ),
      );

      // Remove the identity
      await _identityRepository.removeIdentity(genesisDid: param.genesisDid);
      _stacktraceManager.addTrace("[RemoveIdentityUseCase] Identity removed");
    } catch (error) {
      logger().e("[RemoveIdentityUseCase] Error: $error");
      _stacktraceManager.addTrace("[RemoveIdentityUseCase] Error: $error");
      _stacktraceManager.addError("[RemoveIdentityUseCase] Error: $error");

      rethrow;
    }
  }
}
