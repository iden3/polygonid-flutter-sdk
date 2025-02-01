import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:polygonid_flutter_sdk/constants.dart';
import 'package:polygonid_flutter_sdk/credential/data/data_sources/storage_claim_data_source.dart';
import 'package:polygonid_flutter_sdk/credential/data/dtos/claim_dto.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/dtos/credential/response/fetch_claim_response_dto.dart';
import 'package:polygonid_flutter_sdk/sdk/di/injector.dart';
import 'package:sembast/sembast.dart' as sem;

import '../../../iden3comm/data/dtos/fetch_claim_response_dto_test.dart';
import 'storage_claim_data_source_test.mocks.dart';

class FakeRecordSnapshot
    implements sem.RecordSnapshot<String, Map<String, Object?>> {
  @override
  Object? operator [](String field) {
    throw UnimplementedError();
  }

  @override
  sem.RecordSnapshot<RK, RV> cast<RK, RV>() {
    throw UnimplementedError();
  }

  @override
  String get key => throw UnimplementedError();

  @override
  sem.RecordRef<String, Map<String, Object?>> get ref =>
      throw UnimplementedError();

  @override
  Map<String, Object?> get value => mockClaims[0].toJson();
}

// Data
const privateKey = "thePrivateKey";
const issuers = ["theIssuer", "theIssuer1", "theIssuer2"];
const identifiers = ["theIdentifier", "theIdentifier1", "theIdentifier2"];
const ids = ["theId", "theId1", "theId2"];
const expirations = ["theExpiration", "theExpiration1", "theExpiration2"];
const types = ["theType", "theType1", "theType2"];
final snapshots = [
  FakeRecordSnapshot(),
  FakeRecordSnapshot(),
  FakeRecordSnapshot()
];
final sem.Filter filter =
    sem.Filter.and([sem.Filter.equals("theField", "theValue")]);

/// We assume [FetchClaimResponseDTO] has been tested
final credential =
    FetchClaimResponseDTO.fromJson(jsonDecode(mockFetchClaim)).credential;
final mockClaims = [
  ClaimDTO(
    id: credential.id,
    issuer: issuers[0],
    did: identifiers[0],
    expiration: expirations[0],
    type: types[0],
    info: credential,
    credentialRawValue: mockFetchClaim,
  ),
  ClaimDTO(
    id: credential.id,
    issuer: issuers[1],
    did: identifiers[1],
    expiration: expirations[1],
    type: types[1],
    info: credential,
    credentialRawValue: mockFetchClaim,
  ),
  ClaimDTO(
    id: credential.id,
    issuer: issuers[2],
    did: identifiers[2],
    expiration: expirations[2],
    type: types[2],
    info: credential,
    credentialRawValue: mockFetchClaim,
  )
];
final exception = Exception();

// Dependencies
MockDatabase database = MockDatabase();
MockClaimStoreRefWrapper storeRefWrapper = MockClaimStoreRefWrapper();

// Tested instance
StorageClaimDataSource dataSource = StorageClaimDataSource(storeRefWrapper);

@GenerateMocks([sem.Database, ClaimStoreRefWrapper])
void main() {
  setUp(() {
    if (getItSdk.isRegistered<sem.Database>(
        instanceName: identityDatabaseName)) {
      getItSdk.unregister<sem.Database>(instanceName: identityDatabaseName);
    }

    getItSdk.registerFactoryParamAsync<sem.Database, String, String>(
        (_, __) => Future.value(database),
        instanceName: identityDatabaseName);

    when(database.close()).thenAnswer((realInvocation) => Future.value(null));
  });

  group("Store claims", () {
    test(
        "Given a list of claims, when I call storeClaims, then I expect the claims to be saved in storage",
        () async {
      // Given
      when(storeRefWrapper.put(any, any, any))
          .thenAnswer((realInvocation) => Future.value({}));

      // When
      await expectLater(
          dataSource.storeClaimsTransact(
              transaction: database, claims: mockClaims),
          completes);

      // Then
      var storeVerify =
          verify(storeRefWrapper.put(captureAny, captureAny, captureAny));
      expect(storeVerify.callCount, 3);

      int j = 0;
      for (int i = 0; i < mockClaims.length; i += 3) {
        expect(storeVerify.captured[i], database);
        expect(storeVerify.captured[i + 1], mockClaims[j].id);
        expect(storeVerify.captured[i + 2], mockClaims[j].toJson());
        j++;
      }
    });

    test(
        "Given a list of claims, when I call storeClaims and an error occurred, then I expect an exception to be thrown",
        () async {
      // Given
      when(storeRefWrapper.put(any, any, any))
          .thenAnswer((realInvocation) => Future.error(exception));

      // When
      await expectLater(
          dataSource.storeClaimsTransact(
              transaction: database, claims: mockClaims),
          throwsA(exception));

      // Then
      var captured =
          verify(storeRefWrapper.put(captureAny, captureAny, captureAny))
              .captured;
      expect(captured.length, mockClaims.length);
      expect(captured[0], database);
      expect(captured[1], mockClaims[0].id);
      expect(captured[2], mockClaims[0].toJson());
    });
  });

  group("Get claims", () {
    test(
        "Given nothing, when I call getClaims, then I expect a list of claims to be returned",
        () async {
      // Given
      when(storeRefWrapper.find(any, finder: anyNamed("finder")))
          .thenAnswer((realInvocation) => Future.value(snapshots));

      // When
      expect(
          await dataSource.getClaims(
              did: identifiers[0], encryptionKey: privateKey),
          isA<List<ClaimDTO>>());

      // Then
      var storeCaptured = verify(storeRefWrapper.find(captureAny,
              finder: captureAnyNamed("finder")))
          .captured;

      expect(storeCaptured[0], database);
      expect(
          storeCaptured[1].toString(),
          sem.Finder(
            filter: null,
            sortOrders: [],
          ).toString());
    });

    test(
        "Given a Filter, when I call getClaims, then I expect a list of claims to be returned",
        () async {
      // Given
      when(storeRefWrapper.find(any, finder: anyNamed("finder")))
          .thenAnswer((realInvocation) => Future.value(snapshots));

      // When
      expect(
          await dataSource.getClaims(
              filter: filter, did: identifiers[0], encryptionKey: privateKey),
          isA<List<ClaimDTO>>());

      // Then
      var storeCaptured = verify(storeRefWrapper.find(captureAny,
              finder: captureAnyNamed("finder")))
          .captured;

      expect(storeCaptured[0], database);
      expect(
          storeCaptured[1].toString(),
          sem.Finder(
            filter: filter,
            sortOrders: [],
          ).toString());
    });

    test(
        "Given a Filter, when I call getClaims and an error occurred, then I expect an exception to be thrown",
        () async {
      // Given
      when(storeRefWrapper.find(any, finder: anyNamed("finder")))
          .thenAnswer((realInvocation) => Future.error(exception));

      // When
      await expectLater(
          dataSource.getClaims(
              filter: filter, did: identifiers[0], encryptionKey: privateKey),
          throwsA(exception));

      // Then
      var storeCaptured = verify(storeRefWrapper.find(captureAny,
              finder: captureAnyNamed("finder")))
          .captured;

      expect(storeCaptured[0], database);
      expect(
          storeCaptured[1].toString(),
          sem.Finder(
            filter: filter,
            sortOrders: [],
          ).toString());
    });
  });

  group("Remove credentials", () {
    test(
        "Given a list of ids, when I call removeClaims, then I expect the process to complete",
        () async {
      // Given
      when(storeRefWrapper.remove(any, any))
          .thenAnswer((realInvocation) => Future.value(""));

      // When
      await expectLater(
          dataSource.removeClaimsTransact(transaction: database, claimIds: ids),
          completes);

      // Then
      var storeVerify = verify(storeRefWrapper.remove(captureAny, captureAny));
      expect(storeVerify.callCount, ids.length);

      int j = 0;
      for (int i = 0; i < ids.length; i += 2) {
        expect(storeVerify.captured[i], database);
        expect(storeVerify.captured[i + 1], ids[j]);
        j++;
      }
    });

    test(
        "Given a list of ids, when I call removeClaims and an error occurred, then I expect an exception to be thrown",
        () async {
      // Given
      when(storeRefWrapper.remove(any, any))
          .thenAnswer((realInvocation) => Future.error(exception));

      // When
      await expectLater(
          dataSource.removeClaimsTransact(transaction: database, claimIds: ids),
          throwsA(exception));

      // Then
      var storeVerify = verify(storeRefWrapper.remove(captureAny, captureAny));
      expect(storeVerify.callCount, 1);
      expect(storeVerify.captured[0], database);
      expect(storeVerify.captured[1], ids[0]);
    });
  });
}
