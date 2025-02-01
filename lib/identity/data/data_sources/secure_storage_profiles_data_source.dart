import 'package:injectable/injectable.dart';
import 'package:polygonid_flutter_sdk/common/data/data_sources/secure_identity_storage_data_source.dart';
import 'package:sembast/sembast.dart';
import 'package:polygonid_flutter_sdk/constants.dart';

@injectable
class SecureStorageProfilesStoreRefWrapper {
  final StoreRef<String, Map<String, Object?>> _store;

  SecureStorageProfilesStoreRefWrapper(@Named(profilesStoreName) this._store);

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

class SecureStorageProfilesDataSource extends SecureIdentityStorageDataSource {
  final SecureStorageProfilesStoreRefWrapper _storeRefWrapper;

  SecureStorageProfilesDataSource(this._storeRefWrapper);

  Future<void> storeProfiles({
    required Map<BigInt, String> profiles,
    required String did,
    required String encryptionKey,
  }) {
    return getDatabase(did: did, encryptionKey: encryptionKey)
        .then((database) => database
            .transaction(
              (transaction) => storeProfilesTransact(
                transaction: transaction,
                profiles: profiles,
              ),
            )
            .whenComplete(() => database.close()));
  }

  Future<void> storeProfilesTransact({
    required Transaction transaction,
    required Map<BigInt, String> profiles,
  }) {
    Map<String, Object> profilesJson =
        profiles.map((key, value) => MapEntry(key.toString(), value));
    return _storeRefWrapper.put(
      transaction,
      "profiles",
      profilesJson,
    );
  }

  Future<Map<BigInt, String>> getProfiles({
    required String did,
    required String encryptionKey,
  }) {
    return getDatabase(did: did, encryptionKey: encryptionKey)
        .then((database) => _storeRefWrapper.find(database).then((snapshots) {
              if (snapshots.isEmpty) {
                return {BigInt.zero: did};
              }
              Map<String, Object?> snapshot =
                  snapshots.map((snapshot) => snapshot.value).first;
              Map<BigInt, String> profiles = snapshot.map(
                  (key, value) => MapEntry(BigInt.parse(key), value as String));
              return profiles;
            }).whenComplete(() => database.close()));
  }
}
