import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:polygonid_flutter_sdk/common/data/data_sources/secure_identity_storage_data_source.dart';
import 'package:polygonid_flutter_sdk/constants.dart';
import 'package:sembast/sembast.dart';

/// [StoreRef] wrapper
/// Delegates all call to [SecureInteractionStoreRefWrapper._store]
/// Needed for UT for mocking extension methods
@injectable
class SecureInteractionStoreRefWrapper {
  final StoreRef<String, Map<String, Object?>> _store;

  SecureInteractionStoreRefWrapper(@Named(interactionStoreName) this._store);

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

class SecureStorageInteractionDataSource
    extends SecureIdentityStorageDataSource {
  final SecureInteractionStoreRefWrapper _storeRefWrapper;

  SecureStorageInteractionDataSource(this._storeRefWrapper);

  /// Store all interactions in a single transaction
  /// If one storing fails, they will all be reverted
  ///
  /// Return the stored interactions
  Future<List<Map<String, dynamic>>> storeInteractions({
    required List<Map<String, dynamic>> interactions,
    required String did,
    required String encryptionKey,
  }) {
    return getDatabase(did: did, encryptionKey: encryptionKey).then(
        (database) => database
            .transaction((transaction) => storeInteractionsTransact(
                transaction: transaction, interactions: interactions))
            .whenComplete(() => database.close()));
  }

  @visibleForTesting
  Future<List<Map<String, dynamic>>> storeInteractionsTransact({
    required DatabaseClient transaction,
    required List<Map<String, dynamic>> interactions,
  }) async {
    List<Map<String, dynamic>> storedInteractions = [];

    for (Map<String, dynamic> interaction in interactions) {
      /// Id is null when the interaction is not stored yet
      await (interaction['id'] == null
              ? _storeRefWrapper.add(transaction, interaction).then((id) {
                  interaction['id'] = id;

                  return interaction;
                })

              /// Id is not null, we update the interaction
              : _storeRefWrapper
                  .put(transaction, interaction['id'], interaction)
                  .then((_) => interaction))
          .then(
              (storedInteraction) => storedInteractions.add(storedInteraction));
    }

    return storedInteractions;
  }

  /// Remove all interactions in a single transaction
  /// If one removing fails, they will all be reverted
  Future<void> removeInteractions({
    required List<String> ids,
    required String did,
    required String encryptionKey,
  }) {
    return getDatabase(did: did, encryptionKey: encryptionKey).then(
        (database) => database
            .transaction((transaction) =>
                removeInteractionsTransact(transaction: transaction, ids: ids))
            .whenComplete(() => database.close()));
  }

  @visibleForTesting
  Future<void> removeInteractionsTransact({
    required DatabaseClient transaction,
    required List<String> ids,
  }) async {
    for (String interactionId in ids) {
      await _storeRefWrapper.remove(transaction, interactionId);
    }
  }

  /// Remove all interactions in a single transaction
  /// If one removing fails, they will all be reverted
  Future<void> removeAllInteractions({
    required String did,
    required String encryptionKey,
  }) {
    return getDatabase(did: did, encryptionKey: encryptionKey).then(
        (database) => database
            .transaction((transaction) =>
                removeAllInteractionsTransact(transaction: transaction))
            .whenComplete(() => database.close()));
  }

  @visibleForTesting
  Future<void> removeAllInteractionsTransact({
    required DatabaseClient transaction,
  }) async {
    await _storeRefWrapper.removeAll(transaction);
  }

  Future<List<Map<String, dynamic>>> getInteractions({
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
