import 'package:polygonid_flutter_sdk/common/domain/domain_constants.dart';
import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/identity_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/private_identity_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/exceptions/identity_exceptions.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_current_env_did_identifier_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/add_identity_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/get_identity_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/profile/restore_profiles_use_case.dart';

class RestoreIdentityParam {
  final String genesisDid;
  final String privateKey;
  final String? encryptedDb;

  RestoreIdentityParam({
    required this.genesisDid,
    required this.privateKey,
    this.encryptedDb,
  });
}

class RestoreIdentityUseCase
    extends FutureUseCase<RestoreIdentityParam, IdentityEntity> {
  final AddIdentityUseCase _addIdentityUseCase;
  final GetIdentityUseCase _getIdentityUseCase;
  final IdentityRepository _identityRepository;
  final GetCurrentEnvDidIdentifierUseCase _getCurrentEnvDidIdentifierUseCase;
  final RestoreProfilesUseCase _restoreProfilesUseCase;

  RestoreIdentityUseCase(
    this._addIdentityUseCase,
    this._getIdentityUseCase,
    this._identityRepository,
    this._getCurrentEnvDidIdentifierUseCase,
    this._restoreProfilesUseCase,
  );

  @override
  Future<PrivateIdentityEntity> execute({
    required RestoreIdentityParam param,
  }) async {
    late IdentityEntity identity;
    final encryptionKey = param.privateKey;
    final publicKey = await _identityRepository.getPublicKeys(
      bjjPrivateKey: param.privateKey,
    );

    try {
      String genesisDid = await _getCurrentEnvDidIdentifierUseCase.execute(
        param: GetCurrentEnvDidIdentifierParam(
          bjjPublicKey: publicKey,
          profileNonce: GENESIS_PROFILE_NONCE,
        ),
      );
      identity = await _getIdentityUseCase.execute(
        param: GetIdentityParam(
          genesisDid: genesisDid,
          publicKey: publicKey,
        ),
      );
    } on UnknownIdentityException {
      identity = await _addIdentityUseCase.execute(
        param: AddIdentityParam(
          bjjPublicKey: publicKey,
          encryptionKey: encryptionKey,
        ),
      );
    } catch (error) {
      logger().e("[RestoreIdentityUseCase] Error: $error");

      rethrow;
    }

    try {
      if (param.encryptedDb != null) {
        await _identityRepository.importIdentity(
          did: identity.did,
          encryptedDb: param.encryptedDb!,
          encryptionKey: encryptionKey,
        );
        await _restoreProfilesUseCase.execute(
          param: RestoreProfilesParam(
            genesisDid: identity.did,
            encryptionKey: encryptionKey,
          ),
        );
      }

      logger().i(
          "[RestoreIdentityUseCase] Identity restored with did: ${identity.did}, for key $param");

      return PrivateIdentityEntity(
        did: identity.did,
        publicKey: identity.publicKey,
        profiles: identity.profiles,
        privateKey: param.privateKey,
      );
    } catch (error) {
      logger().e("[RestoreIdentityUseCase] Error: $error");

      rethrow;
    }
  }
}
