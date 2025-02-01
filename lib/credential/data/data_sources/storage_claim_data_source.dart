import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:polygonid_flutter_sdk/common/data/data_sources/secure_identity_storage_data_source.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/common/utils/credential_sort_order.dart';
import 'package:polygonid_flutter_sdk/constants.dart';
import 'package:polygonid_flutter_sdk/credential/domain/exceptions/credential_exceptions.dart';
import 'package:polygonid_flutter_sdk/sdk/di/injector.dart';
import 'package:sembast/sembast.dart';

import '../dtos/claim_dto.dart';

/// [StoreRef] wrapper
/// Delegates all call to [ClaimStoreRefWrapper._store]
/// Needed for UT for mocking extension methods
@injectable
class ClaimStoreRefWrapper {
  final StoreRef<String, Map<String, Object?>> _store;

  ClaimStoreRefWrapper(@Named(claimStoreName) this._store);

  Future<List<RecordSnapshot<String, Map<String, Object?>>>> find(
      DatabaseClient databaseClient,
      {Finder? finder}) {
    return _store.find(databaseClient, finder: finder);
  }

  Future<Map<String, Object?>?> get(DatabaseClient database, String key) {
    return _store.record(key).get(database);
  }

  Future<Map<String, Object?>> put(
      DatabaseClient database, String key, Map<String, Object?> value,
      {bool? merge}) {
    return _store.record(key).put(database, value, merge: merge);
  }

  Future<String?> remove(DatabaseClient database, String identifier) {
    return _store.record(identifier).delete(database);
  }

  Future<int> removeAll(DatabaseClient database) {
    return _store.delete(database);
  }
}

class StorageClaimDataSource extends SecureIdentityStorageDataSource {
  final ClaimStoreRefWrapper _storeRefWrapper;

  StorageClaimDataSource(this._storeRefWrapper);

  /// Store all claims in a single transaction
  /// If one storing fails, they will all be reverted
  Future<void> storeClaims({
    required List<ClaimDTO> claims,
    required String did,
    required String encryptionKey,
  }) async {
    // TODO check if identifiers inside each claim are from privateKey
    Database? database;
    try {
      database = await getDatabase(did: did, encryptionKey: encryptionKey);
      await database.transaction(
        (t) => storeClaimsTransact(transaction: t, claims: claims),
      );
    } finally {
      database?.close();
    }
  }

  // For UT purpose
  @visibleForTesting
  Future<void> storeClaimsTransact({
    required DatabaseClient transaction,
    required List<ClaimDTO> claims,
  }) async {
    for (ClaimDTO claim in claims) {
      await _storeRefWrapper.put(transaction, claim.id, claim.toJson());
    }
  }

  /// Remove all claims in a single transaction
  /// If one removing fails, they will all be reverted
  Future<void> removeClaims({
    required List<String> claimIds,
    required String did,
    required String encryptionKey,
  }) async {
    Database? database;
    try {
      database = await getDatabase(did: did, encryptionKey: encryptionKey);
      await database.transaction(
        (t) => removeClaimsTransact(transaction: t, claimIds: claimIds),
      );
    } finally {
      await database?.close();
    }
  }

  // For UT purpose
  @visibleForTesting
  Future<void> removeClaimsTransact({
    required DatabaseClient transaction,
    required List<String> claimIds,
  }) async {
    for (String claimId in claimIds) {
      // TODO check if identifiers inside each claim are from privateKey
      await _storeRefWrapper.remove(transaction, claimId);
    }
  }

  /// Remove all claims in a single transaction
  /// If one removing fails, they will all be reverted
  Future<void> removeAllClaims({
    required String did,
    required String encryptionKey,
  }) async {
    Database? database;
    try {
      database = await getDatabase(did: did, encryptionKey: encryptionKey);
      await database.transaction(
        (t) => removeAllClaimsTransact(transaction: t),
      );
    } finally {
      database?.close();
    }
  }

  // For UT purpose
  Future<void> removeAllClaimsTransact({
    required DatabaseClient transaction,
  }) async {
    await _storeRefWrapper.removeAll(transaction);
  }

  Future<List<ClaimDTO>> getClaims({
    Filter? filter,
    required String did,
    required String encryptionKey,
    List<CredentialSortOrder> credentialSortOrderList = const [],
  }) async {
    Database database =
        await getDatabase(did: did, encryptionKey: encryptionKey);

    List<SortOrder> sortOrders = [];

    for (var element in credentialSortOrderList) {
      switch (element) {
        case CredentialSortOrder.ExpirationAscending:
          sortOrders.add(SortOrder('expiration', true));
          break;
        case CredentialSortOrder.ExpirationDescending:
          sortOrders.add(SortOrder('expiration', false));
          break;
        case CredentialSortOrder.IssuanceDateAscending:
          sortOrders.add(SortOrder('credential.issuanceDate', true));
          break;
        case CredentialSortOrder.IssuanceDateDescending:
          sortOrders.add(SortOrder('credential.issuanceDate', false));
          break;
      }
    }

    List<RecordSnapshot<String, Map<String, Object?>>> snapshots =
        await _storeRefWrapper.find(
      database,
      finder: Finder(
        filter: filter,
        sortOrders: sortOrders,
      ),
    );

    List<ClaimDTO> claims = snapshots.map((snapshot) {
      ClaimDTO claimDTO = ClaimDTO.fromJson(snapshot.value);
      return claimDTO;
    }).toList();

    database.close();
    return claims;
  }

  Future<List<ClaimDTO>> getCredentialByPartialId({
    required String did,
    required String partialId,
    required String encryptionKey,
  }) async {
    final database = await getDatabase(did: did, encryptionKey: encryptionKey);

    try {
      final partialIdFiler = Filter.custom((record) =>
          (record.value as Map<String, Object?>)['id']
              ?.toString()
              .contains(partialId) ??
          false);

      final snapshots = await _storeRefWrapper.find(
        database,
        finder: Finder(filter: partialIdFiler),
      );

      return snapshots.map((snapshot) {
        return ClaimDTO.fromJson(snapshot.value);
      }).toList();
    } finally {
      database.close();
    }
  }

  /// Get a [ClaimDTO] filtered by id associated to the identity previously stored
  Future<ClaimDTO> getClaim({
    required String credentialId,
    required String did,
    required String encryptionKey,
  }) async {
    Database db = await getDatabase(did: did, encryptionKey: encryptionKey);

    Map<String, Object?>? credential =
        await _storeRefWrapper.get(db, credentialId);
    if (credential == null) {
      StacktraceManager stacktraceManager = getItSdk<StacktraceManager>();
      stacktraceManager.addError('Credential not found by id');
      throw ClaimNotFoundException(
        id: credentialId,
        errorMessage: 'Credential not found by id',
      );
    }

    ClaimDTO claimDTO = ClaimDTO.fromJson(credential);
    db.close();
    return claimDTO;
  }
}
