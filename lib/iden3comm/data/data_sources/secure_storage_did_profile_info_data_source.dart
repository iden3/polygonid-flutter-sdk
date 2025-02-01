import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:polygonid_flutter_sdk/common/data/data_sources/secure_identity_storage_data_source.dart';
import 'package:sembast/sembast.dart';
import 'package:polygonid_flutter_sdk/constants.dart';

@injectable
class SecureDidProfileInfoStoreRefWrapper {
  final StoreRef<String, Map<String, Object?>> _store;

  SecureDidProfileInfoStoreRefWrapper(
      @Named(didProfileInfoStoreName) this._store);

  Future<List<RecordSnapshot<String, Map<String, Object?>>>> find(
      DatabaseClient databaseClient,
      {Finder? finder}) {
    return _store.find(databaseClient, finder: finder);
  }

  Future<String> add(DatabaseClient database, Map<String, Object?> value) {
    return _store.add(database, value);
  }

  Future<Map<String, Object?>?> get(DatabaseClient database, String key) {
    return _store.record(key).get(database);
  }

  Future<Map<String, Object?>> put(
      DatabaseClient database, String key, Map<String, Object?> value,
      {bool? merge}) {
    return _store.record(key).put(database, value, merge: merge);
  }

  Future<String?> remove(DatabaseClient database, String id) {
    return _store.record(id).delete(database);
  }

  Future<int> removeAll(DatabaseClient database) {
    return _store.delete(database);
  }
}

class SecureStorageDidProfileInfoDataSource
    extends SecureIdentityStorageDataSource {
  final SecureDidProfileInfoStoreRefWrapper _storeRefWrapper;

  SecureStorageDidProfileInfoDataSource(this._storeRefWrapper);

  Future<void> storeDidProfileInfo({
    required Map<String, dynamic> didProfileInfo,
    required String interactedDid,
    required String did,
    required String encryptionKey,
  }) {
    return getDatabase(did: did, encryptionKey: encryptionKey)
        .then((database) => database
            .transaction(
              (transaction) => storeDidProfileInfoTransact(
                transaction: transaction,
                didProfileInfo: didProfileInfo,
                interactedDid: interactedDid,
              ),
            )
            .whenComplete(() => database.close()));
  }

  @visibleForTesting
  Future<void> storeDidProfileInfoTransact({
    required DatabaseClient transaction,
    required Map<String, dynamic> didProfileInfo,
    required String interactedDid,
  }) async {
    await _storeRefWrapper.put(transaction, interactedDid, didProfileInfo);
  }

  Future<void> removeDidProfileInfo({
    required String interactedDid,
    required String did,
    required String encryptionKey,
  }) {
    return getDatabase(did: did, encryptionKey: encryptionKey).then(
        (database) =>
            database.transaction((transaction) => removeDidProfileInfoTransact(
                  transaction: transaction,
                  interactedDid: interactedDid,
                )));
  }

  @visibleForTesting
  Future<void> removeDidProfileInfoTransact({
    required DatabaseClient transaction,
    required String interactedDid,
  }) async {
    await _storeRefWrapper.remove(transaction, interactedDid);
  }

  Future<void> removeAllDidProfileInfo({
    required String did,
    required String encryptionKey,
  }) {
    return getDatabase(did: did, encryptionKey: encryptionKey).then(
      (database) => database.transaction(
        (transaction) =>
            removeAllDidProfileInfoTransact(transaction: transaction),
      ),
    );
  }

  @visibleForTesting
  Future<void> removeAllDidProfileInfoTransact({
    required DatabaseClient transaction,
  }) async {
    await _storeRefWrapper.removeAll(transaction);
  }

  Future<Map<String, dynamic>> getDidProfileInfosByInteractedWithDid({
    required String did,
    required String interactedWithDid,
    required String encryptionKey,
  }) {
    return getDatabase(did: did, encryptionKey: encryptionKey).then(
        (database) => _storeRefWrapper
            .get(database, interactedWithDid)
            .then((value) => value ?? {}));
    //.whenComplete(() => database.close()));
  }

  Future<List<Map<String, dynamic>>> getDidProfileInfos({
    Filter? filter,
    required String did,
    required String encryptionKey,
  }) {
    return getDatabase(did: did, encryptionKey: encryptionKey).then(
        (database) => _storeRefWrapper
            .find(database, finder: Finder(filter: filter))
            .then((snapshots) =>
                snapshots.map((snapshot) => snapshot.value).toList())
            .whenComplete(() => database.close()));
  }
}
