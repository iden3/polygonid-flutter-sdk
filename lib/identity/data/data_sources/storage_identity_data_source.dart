import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:polygonid_flutter_sdk/common/data/data_sources/secure_identity_storage_data_source.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';

import 'package:polygonid_flutter_sdk/common/utils/encrypt_sembast_codec.dart';
import 'package:polygonid_flutter_sdk/constants.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/identity_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/exceptions/identity_exceptions.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/utils/sembast_import_export.dart';

/// [StoreRef] wrapper
/// Delegates all call to [IdentityStoreRefWrapper._store]
/// Needed for UT for mocking extension methods
@injectable
class IdentityStoreRefWrapper {
  final StoreRef<String, Map<String, Object?>> _store;

  IdentityStoreRefWrapper(@Named(identityStoreName) this._store);

  Future<Map<String, Object?>?> get(DatabaseClient database, String key) {
    return _store.record(key).get(database);
  }

  Future<List<RecordSnapshot<String, Map<String, Object?>>>> find(
      DatabaseClient databaseClient,
      {Finder? finder}) {
    return _store.find(databaseClient, finder: finder);
  }

  Future<Map<String, Object?>> put(
      DatabaseClient database, String key, Map<String, Object?> value,
      {bool? merge}) {
    return _store.record(key).put(database, value, merge: merge);
  }

  Future<String?> remove(DatabaseClient database, String did) {
    return _store.record(did).delete(database);
  }
}

class StorageIdentityDataSource extends SecureIdentityStorageDataSource {
  final Database _database;
  final IdentityStoreRefWrapper _storeRefWrapper;
  final StacktraceManager _stacktraceManager;

  StorageIdentityDataSource(
    this._database,
    this._storeRefWrapper,
    this._stacktraceManager,
  );

  //FIXME: mutualize [getIdentities] and [getIdentity]
  Future<List<IdentityEntity>> getIdentities({Filter? filter}) {
    return _storeRefWrapper
        .find(_database, finder: Finder(filter: filter))
        .then((snapshots) => snapshots
            .map((snapshot) => IdentityEntity.fromJson(snapshot.value))
            .toList());
  }

  Future<IdentityEntity> getIdentity({required String did}) {
    return _storeRefWrapper.get(_database, did).then((storedValue) {
      if (storedValue == null) {
        _stacktraceManager.addError("Identity not found");
        throw UnknownIdentityException(
          did: did,
          errorMessage: "Identity not found",
        );
      }

      return IdentityEntity.fromJson(storedValue);
    });
  }

  /// As we support only one identity at the moment, we need to maintain
  /// the stored current did up to date
  Future<void> storeIdentity({
    required String did,
    required IdentityEntity identity,
  }) {
    return _database.transaction((transaction) => storeIdentityTransact(
        transaction: transaction, did: did, identity: identity));
  }

  @visibleForTesting
  Future<void> storeIdentityTransact({
    required DatabaseClient transaction,
    required String did,
    required IdentityEntity identity,
  }) async {
    await _storeRefWrapper.put(transaction, did, identity.toJson());
  }

  Future<void> removeIdentity({required String did}) {
    //clearDatabaseCache();
    // TODO: get privateKey from param and obtain publicKey
    //  from identity and encrypt/decrypt a msg to allow removing the identity
    return _database.transaction((transaction) =>
        removeIdentityTransact(transaction: transaction, did: did));
  }

  // For UT purpose
  Future<void> removeIdentityTransact({
    required DatabaseClient transaction,
    required String did,
  }) async {
    await _storeRefWrapper.remove(transaction, did);
  }

  /// Export identity database
  Future<Map<String, Object?>> getIdentityDb({
    required String did,
    required String encryptionKey,
  }) async {
    Database db = await getDatabase(
      did: did,
      encryptionKey: encryptionKey,
    );

    Map<String, Object?> exportableDb = await exportDatabase(db);
    return exportableDb;
  }

  /// Import entire claims database
  Future<void> saveIdentityDb({
    required Map<String, Object?> exportableDb,
    required String destinationPath,
    required String encryptionKey,
  }) async {
    SembastCodec codec = getEncryptSembastCodec(encryptionKey: encryptionKey);

    await importDatabase(
      exportableDb,
      databaseFactoryIo,
      destinationPath,
      codec: codec,
    );

    //clearDatabaseCache();
  }
}
