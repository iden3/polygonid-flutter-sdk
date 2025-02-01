import 'package:injectable/injectable.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/did_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/exceptions/identity_exceptions.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_did_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/add_new_identity_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/backup_identity_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/get_identities_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/get_identity_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/get_private_key_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/restore_identity_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/profile/add_profile_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/profile/get_profiles_use_case.dart';

import 'package:polygonid_flutter_sdk/identity/domain/entities/identity_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/private_identity_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/fetch_identity_state_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_did_identifier_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/check_identity_validity_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/remove_identity_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/sign_message_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/profile/remove_profile_use_case.dart';

abstract class PolygonIdSdkIdentity {
  /// Checks the identity validity from a secret
  ///
  /// If [secret] is omitted or null, a random one will be used to create a new identity.
  /// Throws [IdentityException] if an error occurs.
  ///
  /// Be aware [secret] is internally converted to a 32 length bytes array
  /// in order to be compatible with the SDK. The following rules will be applied:
  /// - If the byte array is not 32 length, it will be padded with 0s.
  /// - If the byte array is longer than 32, an exception will be thrown.
  Future<void> checkIdentityValidity({required String secret});

  /// Gets the identity BJJ private key from a secret
  ///
  /// Throws [IdentityException] if an error occurs.
  ///
  /// Be aware [secret] is internally converted to a 32 length bytes array
  /// in order to be compatible with the SDK. The following rules will be applied:
  /// - If the byte array is not 32 length, it will be padded with 0s.
  /// - If the byte array is longer than 32, an exception will be thrown.
  ///
  Future<String> getPrivateKey({required String secret});

  /// Creates and stores an [IdentityEntity] from a secret
  /// if it doesn't exist already in the Polygon ID Sdk.
  /// If [secret] is omitted or null, a random one will be used to create a new identity.
  /// Return an identity as a [PrivateIdentityEntity].
  /// Throws [IdentityException] if an error occurs.
  ///
  /// Be aware [secret] is internally converted to a 32 length bytes array
  /// in order to be compatible with the SDK. The following rules will be applied:
  /// - If the byte array is not 32 length, it will be padded with 0s.
  /// - If the byte array is longer than 32, an exception will be thrown.
  ///
  /// The identity will be created using the current env set with [PolygonIdSdk.setEnv]
  Future<PrivateIdentityEntity> addIdentity({String? secret});

  /// Restores an [IdentityEntity] from a privateKey and encrypted backup databases
  /// associated to the identity
  /// Return an identity as a [PrivateIdentityEntity].
  /// Throws [IdentityException] if an error occurs.
  ///
  /// The [genesisDid] is the unique id of the identity which profileNonce is 0
  ///
  /// Identity [privateKey] is the key used to access all the sensitive info from the identity
  /// and also to realize operations like generating proofs
  /// using the credentials associated to the identity
  ///
  ///  The [encryptedDb] is an encrypted Identity's Database
  Future<PrivateIdentityEntity> restoreIdentity({
    required String genesisDid,
    required String privateKey,
    String? encryptedDb,
  });

  /// Backup a previously stored [IdentityEntity] from a privateKey
  /// associated to the identity
  ///
  /// The [genesisDid] is the unique id of the identity which profileNonce is 0
  ///
  /// Identity [privateKey] is the key used to access all the sensitive info from the identity
  /// and also to realize operations like generating proofs
  /// using the claims associated to the identity
  ///
  /// Returns an encrypted Identity's Database.
  ///
  /// Throws [IdentityException] if an error occurs.
  Future<String?> backupIdentity({
    required String genesisDid,
    required String privateKey,
  });

  /// Gets an [IdentityEntity] from an identifier.
  /// Returns an identity as a [PrivateIdentityEntity] or [IdentityEntity]
  /// if privateKey is omitted or invalid.
  /// Throws [IdentityException] if an error occurs.
  ///
  /// The [genesisDid] is the unique id of the identity which profileNonce is 0
  ///
  /// The Identity's [privateKey] is the key used to access all the sensitive info from the identity
  /// and also to realize operations like generating proofs
  /// using the claims associated to the identity
  ///
  /// Be aware the secret is internally converted to a 32 length bytes array
  /// in order to be compatible with the SDK. The following rules will be applied:
  /// - If the byte array is not 32 length, it will be padded with 0s.
  /// - If the byte array is longer than 32, an exception will be thrown.
  Future<IdentityEntity> getIdentity({
    required String genesisDid,
    String? privateKey,
  });

  /// Get a list of public info of [IdentityEntity] associated
  /// to the identities stored in the Polygon ID Sdk.
  ///
  /// Return an list of [IdentityEntity].
  ///
  /// Throws [IdentityException] if an error occurs.
  ///
  /// The identities returned will come from the current env set with [PolygonIdSdk.setEnv]
  Future<List<IdentityEntity>> getIdentities();

  /// Remove the previously stored identity associated with the identifier
  ///
  /// The [genesisDid] is the unique id of the identity which profileNonce is 0
  ///
  /// Identity [privateKey] is the key used to access all the sensitive info from the identity
  /// and also to realize operations like generating proofs
  /// using the claims associated to the identity
  ///
  /// Throws [IdentityException] if an error occurs.
  @override
  Future<void> removeIdentity({
    required String genesisDid,
    required String privateKey,
  });

  /// Returns the did identifier derived from a privateKey
  ///
  /// Identity [privateKey] is the key used to access all the sensitive info from the identity
  /// and also to realize operations like generating proofs
  /// using the claims associated to the identity
  ///
  /// The [blockchain] is the blockchain name where the identity
  /// is associated, e.g. Polygon
  ///
  /// The [network] is the network name of the blockchain where the identity
  /// is associated, e.g. Main
  ///
  /// The [profileNonce] is the nonce of the profile used from identity
  /// to obtain the did identifier. Value must be greater than 0 and less than 2^248
  ///
  /// Return The Identity's [did] identifier
  Future<String> getDidIdentifier({
    required String privateKey,
    required String blockchain,
    required String network,
    BigInt? profileNonce,
  });

  /// Returns the [DidEntity] from a did
  Future<DidEntity> getDidEntity({required String did});

  /// Returns the identity state from a did
  ///
  /// The [did] is the unique id of the identity
  Future<String> getState({required String did});

  /// Sign a message through a identity's private key.
  ///
  /// The [privateKey] is the key used to access all the sensitive info from the identity
  /// and also to realize operations like generating proofs
  ///
  /// The [message] is the message to sign. Returns a string representing the signature.
  Future<String> sign({required String privateKey, required String message});

  /// Adds a profile if it doesn't already exist to the identity derived from private key and stored
  /// in the Polygon ID Sdk.
  ///
  /// The [genesisDid] is the unique id of the identity which profileNonce is 0
  ///
  /// The [privateKey]  is the key used to access all the sensitive info from the identity
  /// and also to realize operations like generating proofs
  ///
  /// The [profileNonce] is the nonce of the profile used from identity
  /// to obtain the did identifier. Value must be greater than 0 and less than 2^248
  ///
  /// The [existingProfileDid] is the DID of the existing profile.
  /// If provided - new profile won't be created.
  ///
  /// The profile will be added using the current env set with [PolygonIdSdk.setEnv]
  Future<void> addProfile({
    required String genesisDid,
    required String privateKey,
    required BigInt profileNonce,
    String? existingProfileDid,
  });

  /// Removes a profile from the identity derived from private key and stored
  /// in the Polygon ID Sdk.
  ///
  /// The [genesisDid] is the unique id of the identity which profileNonce is 0
  ///
  /// The [privateKey]  is the key used to access all the sensitive info from the identity
  /// and also to realize operations like generating proofs
  ///
  /// The [profileNonce] is the nonce of the profile used from identity
  /// to obtain the did identifier. Value must be greater than 0 and less than 2^248
  ///
  /// The profile will be removed using the current env set with [PolygonIdSdk.setEnv]
  Future<void> removeProfile({
    required String genesisDid,
    required String privateKey,
    required BigInt profileNonce,
  });

  /// Gets a map of profile nonce as key and profile did as value associated
  /// to the identity derived from private key and stored in the Polygon ID Sdk.
  ///
  /// The [genesisDid] is the unique id of the identity which profileNonce is 0
  ///
  /// The [privateKey] is the key used to access all the sensitive info from the identity
  /// and also to realize operations like generating proofs
  ///
  /// Returns a map of <BigInt, String>.
  ///
  /// The returned profiles will come from the current env set with [PolygonIdSdk.setEnv]
  Future<Map<BigInt, String>> getProfiles({
    required String genesisDid,
    required String privateKey,
  });
}

@injectable
class Identity implements PolygonIdSdkIdentity {
  final CheckIdentityValidityUseCase _checkIdentityValidityUseCase;
  final GetPrivateKeyUseCase _getPrivateKeyUseCase;
  final AddNewIdentityUseCase _addNewIdentityUseCase;
  final RestoreIdentityUseCase _restoreIdentityUseCase;
  final BackupIdentityUseCase _backupIdentityUseCase;
  final GetIdentityUseCase _getIdentityUseCase;
  final GetIdentitiesUseCase _getIdentitiesUseCase;
  final RemoveIdentityUseCase _removeIdentityUseCase;
  final GetDidIdentifierUseCase _getDidIdentifierUseCase;
  final SignMessageUseCase _signMessageUseCase;

  final FetchIdentityStateUseCase _fetchIdentityStateUseCase;

  final AddProfileUseCase _addProfileUseCase;
  final GetProfilesUseCase _getProfilesUseCase;
  final RemoveProfileUseCase _removeProfileUseCase;

  final GetDidUseCase _getDidUseCase;

  final StacktraceManager _stacktraceManager;

  Identity(
    this._checkIdentityValidityUseCase,
    this._getPrivateKeyUseCase,
    this._addNewIdentityUseCase,
    this._restoreIdentityUseCase,
    this._backupIdentityUseCase,
    this._getIdentityUseCase,
    this._getIdentitiesUseCase,
    this._removeIdentityUseCase,
    this._getDidIdentifierUseCase,
    this._signMessageUseCase,
    this._fetchIdentityStateUseCase,
    this._addProfileUseCase,
    this._getProfilesUseCase,
    this._removeProfileUseCase,
    this._getDidUseCase,
    this._stacktraceManager,
  );

  @override
  Future<void> checkIdentityValidity({required String secret}) async {
    _stacktraceManager.clear();
    _stacktraceManager
        .addTrace("PolygonIdSdk.Identity.checkIdentityValidity called");
    return _checkIdentityValidityUseCase.execute(param: secret);
  }

  @override
  Future<String> getPrivateKey({required String secret}) {
    _stacktraceManager.clear();
    _stacktraceManager.addTrace("PolygonIdSdk.Identity.getPrivateKey called");
    return _getPrivateKeyUseCase.execute(param: secret);
  }

  @override
  Future<PrivateIdentityEntity> addIdentity({String? secret}) async {
    _stacktraceManager.clear();
    _stacktraceManager.addTrace("PolygonIdSdk.Identity.addIdentity called");
    return _addNewIdentityUseCase.execute(param: secret);
  }

  @override
  Future<PrivateIdentityEntity> restoreIdentity({
    required String genesisDid,
    required String privateKey,
    String? encryptedDb,
  }) {
    _stacktraceManager.clear();
    _stacktraceManager.addTrace("PolygonIdSdk.Identity.restoreIdentity called");
    return _restoreIdentityUseCase.execute(
      param: RestoreIdentityParam(
        genesisDid: genesisDid,
        privateKey: privateKey,
        encryptedDb: encryptedDb,
      ),
    );
  }

  Future<String> backupIdentity({
    required String genesisDid,
    required String privateKey,
  }) {
    _stacktraceManager.clear();
    _stacktraceManager.addTrace("PolygonIdSdk.Identity.backupIdentity called");
    return _backupIdentityUseCase.execute(
      param: BackupIdentityParam(
        genesisDid: genesisDid,
        encryptionKey: privateKey,
      ),
    );
  }

  @override
  Future<IdentityEntity> getIdentity({
    required String genesisDid,
    String? privateKey,
  }) async {
    _stacktraceManager.clear();
    _stacktraceManager.addTrace("PolygonIdSdk.Identity.getIdentity called");
    return _getIdentityUseCase.execute(
      param: GetIdentityParam(
        genesisDid: genesisDid,
        privateKey: privateKey,
      ),
    );
  }

  @override
  Future<List<IdentityEntity>> getIdentities() {
    _stacktraceManager.clear();
    _stacktraceManager.addTrace("PolygonIdSdk.Identity.getIdentities called");
    return _getIdentitiesUseCase.execute();
  }

  @override
  Future<void> removeIdentity({
    required String genesisDid,
    required String privateKey,
  }) {
    _stacktraceManager.clear();
    _stacktraceManager.addTrace("PolygonIdSdk.Identity.removeIdentity called");
    return _removeIdentityUseCase.execute(
      param: RemoveIdentityParam(
        genesisDid: genesisDid,
        privateKey: privateKey,
      ),
    );
  }

  @override
  Future<String> sign(
      {required String privateKey, required String message}) async {
    _stacktraceManager.clear();
    _stacktraceManager.addTrace("PolygonIdSdk.Identity.sign called");
    return _signMessageUseCase.execute(
        param: SignMessageParam(privateKey, message));
  }

  @override
  Future<String> getDidIdentifier({
    required String privateKey,
    required String blockchain,
    required String network,
    BigInt? profileNonce,
    String? method,
  }) {
    _stacktraceManager.clear();
    _stacktraceManager
        .addTrace("PolygonIdSdk.Identity.getDidIdentifier called");
    return _getDidIdentifierUseCase.execute(
      param: GetDidIdentifierParam.withPrivateKey(
        bjjPrivateKey: privateKey,
        blockchain: blockchain,
        network: network,
        profileNonce: profileNonce ?? BigInt.zero,
        method: method,
      ),
    );
  }

  @override
  Future<DidEntity> getDidEntity({required String did}) {
    _stacktraceManager.clear();
    _stacktraceManager.addTrace("PolygonIdSdk.Identity.getDidEntity called");
    return _getDidUseCase.execute(param: did);
  }

  @override
  Future<String> getState({required String did}) {
    _stacktraceManager.clear();
    _stacktraceManager.addTrace("PolygonIdSdk.Identity.getState called");
    return _fetchIdentityStateUseCase.execute(param: did);
  }

  @override
  Future<void> addProfile({
    required String genesisDid,
    required BigInt profileNonce,
    required String privateKey,
    String? existingProfileDid,
  }) {
    _stacktraceManager.clear();
    _stacktraceManager.addTrace("PolygonIdSdk.Identity.addProfile called");
    return _addProfileUseCase.execute(
      param: AddProfileParam(
        genesisDid: genesisDid,
        profileNonce: profileNonce,
        privateKey: privateKey,
        existingProfileDid: existingProfileDid,
      ),
    );
  }

  @override
  Future<void> removeProfile({
    required String genesisDid,
    required String privateKey,
    required BigInt profileNonce,
  }) {
    _stacktraceManager.clear();
    _stacktraceManager.addTrace("PolygonIdSdk.Identity.removeProfile called");
    return _removeProfileUseCase.execute(
      param: RemoveProfileParam(
        genesisDid: genesisDid,
        profileNonce: profileNonce,
        privateKey: privateKey,
      ),
    );
  }

  @override
  Future<Map<BigInt, String>> getProfiles({
    required String genesisDid,
    required String privateKey,
  }) {
    _stacktraceManager.clear();
    _stacktraceManager.addTrace("PolygonIdSdk.Identity.getProfiles called");
    return _getProfilesUseCase.execute(
      param: GetProfilesParam(
        genesisDid: genesisDid,
        privateKey: privateKey,
      ),
    );
  }
}
