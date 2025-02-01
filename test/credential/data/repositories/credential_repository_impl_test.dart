import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:polygonid_flutter_sdk/common/data/data_sources/mappers/filters_mapper.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/filter_entity.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/credential/data/credential_repository_impl.dart';
import 'package:polygonid_flutter_sdk/credential/data/data_sources/cache_claim_data_source.dart';
import 'package:polygonid_flutter_sdk/credential/data/data_sources/local_claim_data_source.dart';
import 'package:polygonid_flutter_sdk/credential/data/data_sources/remote_claim_data_source.dart';
import 'package:polygonid_flutter_sdk/credential/data/data_sources/storage_claim_data_source.dart';
import 'package:polygonid_flutter_sdk/credential/data/dtos/claim_dto.dart';
import 'package:polygonid_flutter_sdk/credential/data/mappers/claim_mapper.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/credential/domain/exceptions/credential_exceptions.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/dtos/credential/response/fetch_claim_response_dto.dart';
import 'package:sembast/sembast.dart';

import '../../../common/common_mocks.dart';
import '../../../iden3comm/data/dtos/fetch_claim_response_dto_test.dart';
import 'credential_repository_impl_test.mocks.dart';

// Data®
const ids = ["theId", "theId1", "theId2"];
final exception = Exception();
final ClaimNotFoundException claimNotFoundException = ClaimNotFoundException(
  id: ids[0],
  errorMessage: "Claim not found",
);

/// We assume [FetchClaimResponseDTO] has been tested
final fetchClaimDTO =
    FetchClaimResponseDTO.fromJson(jsonDecode(mockFetchClaim));
final claimDTOs = [
  ClaimDTO(
    id: "id1",
    issuer: "",
    did: "",
    type: '',
    info: fetchClaimDTO.credential,
    credentialRawValue: mockFetchClaim,
  ),
  ClaimDTO(
    id: "id2",
    issuer: "",
    did: "",
    type: '',
    info: fetchClaimDTO.credential,
    credentialRawValue: mockFetchClaim,
  ),
];
final claimEntities = [
  ClaimEntity(
    issuer: "",
    did: "",
    expiration: "",
    info: {},
    type: "",
    state: ClaimState.active,
    id: "id1",
    credentialRawValue: mockFetchClaim,
  ),
  ClaimEntity(
    issuer: "",
    did: "",
    expiration: "",
    info: {},
    type: "",
    state: ClaimState.active,
    id: "id2",
    credentialRawValue: mockFetchClaim,
  )
];
final filters = [
  FilterEntity(name: "theName", value: "theValue"),
  FilterEntity(name: "theName1", value: "theValue1"),
  FilterEntity(name: "theName2", value: "theValue2")
];
final filter = Filter.equals("theField", "theValue");

// Dependencies
MockRemoteClaimDataSource remoteClaimDataSource = MockRemoteClaimDataSource();
MockStorageClaimDataSource storageClaimDataSource =
    MockStorageClaimDataSource();
MockLocalClaimDataSource localClaimDataSource = MockLocalClaimDataSource();
MockCacheCredentialDataSource cacheCredentialDataSource =
    MockCacheCredentialDataSource();
MockClaimMapper claimMapper = MockClaimMapper();
MockFiltersMapper filtersMapper = MockFiltersMapper();
MockStacktraceManager stacktraceManager = MockStacktraceManager();

// Tested instance
CredentialRepositoryImpl repository = CredentialRepositoryImpl(
  remoteClaimDataSource,
  storageClaimDataSource,
  localClaimDataSource,
  cacheCredentialDataSource,
  claimMapper,
  filtersMapper,
  stacktraceManager,
);

@GenerateMocks([
  RemoteClaimDataSource,
  StorageClaimDataSource,
  LocalClaimDataSource,
  CacheCredentialDataSource,
  ClaimMapper,
  FiltersMapper,
  StacktraceManager,
])
void main() {
  group("Save claims", () {
    setUp(() {
      // Given
      when(storageClaimDataSource.storeClaims(
              did: anyNamed('did'),
              encryptionKey: anyNamed('encryptionKey'),
              claims: anyNamed('claims')))
          .thenAnswer((realInvocation) => Future.value());
      when(claimMapper.mapTo(any)).thenReturn(claimDTOs[0]);
    });

    test(
        "Given a list of ClaimEntity, when I call saveClaims, then I expect the process to complete",
        () async {
      // When
      await expectLater(
          repository.saveClaims(
              genesisDid: CommonMocks.identifier,
              encryptionKey: CommonMocks.encryptionKey,
              claims: claimEntities),
          completes);

      // Then
      var captureStore = verify(storageClaimDataSource.storeClaims(
              did: captureAnyNamed('did'),
              encryptionKey: captureAnyNamed('encryptionKey'),
              claims: captureAnyNamed('claims')))
          .captured;
      expect(captureStore[0], CommonMocks.identifier);
      expect(captureStore[1], CommonMocks.encryptionKey);
      expect(captureStore[2], [claimDTOs[0], claimDTOs[0]]);

      var mapperVerify = verify(claimMapper.mapTo(captureAny));
      expect(mapperVerify.callCount, claimEntities.length);
      for (int i = 0; i < claimEntities.length; i++) {
        expect(mapperVerify.captured[i], claimEntities[i]);
      }
    });

    test(
        "Given a list of ClaimEntity, when I call saveClaims and an error occurred, then I expect a SaveClaimException to be thrown",
        () async {
      // Given
      when(storageClaimDataSource.storeClaims(
              did: anyNamed('did'),
              encryptionKey: anyNamed('encryptionKey'),
              claims: anyNamed('claims')))
          .thenAnswer((realInvocation) => Future.error(exception));

      // When
      await repository
          .saveClaims(
              genesisDid: CommonMocks.identifier,
              encryptionKey: CommonMocks.encryptionKey,
              claims: claimEntities)
          .then((_) => expect(true, false))
          .catchError((error) {
        expect(error, isA<SaveClaimException>());
        expect(error.error, exception);
      });

      // Then
      var captureStore = verify(storageClaimDataSource.storeClaims(
              did: captureAnyNamed('did'),
              encryptionKey: captureAnyNamed('encryptionKey'),
              claims: captureAnyNamed('claims')))
          .captured;
      expect(captureStore[0], CommonMocks.identifier);
      expect(captureStore[1], CommonMocks.encryptionKey);
      expect(captureStore[2], [claimDTOs[0], claimDTOs[0]]);

      verify(claimMapper.mapTo(captureAny));
    });
  });

  group("Get claims", () {
    setUp(() {
      // Given
      when(storageClaimDataSource.getClaims(
              did: anyNamed('did'),
              encryptionKey: anyNamed('encryptionKey'),
              filter: anyNamed('filter')))
          .thenAnswer((realInvocation) => Future.value(claimDTOs));
      when(claimMapper.mapFrom(any)).thenReturn(claimEntities[0]);
      when(filtersMapper.mapTo(any)).thenReturn(filter);
    });

    test(
        "Given nothing, when I call getClaims, then I expect a list of ClaimEntity to be returned",
        () async {
      // When
      expect(
          await repository.getClaims(
            genesisDid: CommonMocks.identifier,
            encryptionKey: CommonMocks.encryptionKey,
          ),
          [claimEntities[0], claimEntities[0]]);

      // Then
      var captureGet = verify(storageClaimDataSource.getClaims(
              did: captureAnyNamed('did'),
              encryptionKey: captureAnyNamed('encryptionKey')))
          .captured;
      expect(captureGet[0], CommonMocks.identifier);
      expect(captureGet[1], CommonMocks.encryptionKey);

      verifyNever(filtersMapper.mapTo(captureAny));

      var mapperVerify = verify(claimMapper.mapFrom(captureAny));
      expect(mapperVerify.callCount, claimDTOs.length);
      for (int i = 0; i < claimDTOs.length; i++) {
        expect(mapperVerify.captured[i], claimDTOs[i]);
      }
    });

    test(
        "Given a list of FilterEntity, when I call getClaims, then I expect a list of ClaimEntity to be returned",
        () async {
      // When
      expect(
          await repository.getClaims(
              genesisDid: CommonMocks.identifier,
              encryptionKey: CommonMocks.encryptionKey,
              filters: filters),
          [claimEntities[0], claimEntities[0]]);

      // Then
      var captureGet = verify(storageClaimDataSource.getClaims(
              did: captureAnyNamed('did'),
              encryptionKey: captureAnyNamed('encryptionKey'),
              filter: captureAnyNamed('filter')))
          .captured;
      expect(captureGet[0], CommonMocks.identifier);
      expect(captureGet[1], CommonMocks.encryptionKey);
      expect(captureGet[2], filter);

      expect(verify(filtersMapper.mapTo(captureAny)).captured.first, filters);

      var mapperVerify = verify(claimMapper.mapFrom(captureAny));
      expect(mapperVerify.callCount, claimDTOs.length);
      for (int i = 0; i < claimDTOs.length; i++) {
        expect(mapperVerify.captured[i], claimDTOs[i]);
      }
    });

    test(
        "Given a list of FilterEntity, when I call getClaims and an error occurred, then I expect an exception to be thrown",
        () async {
      // Given
      when(storageClaimDataSource.getClaims(
              did: anyNamed('did'),
              encryptionKey: anyNamed('encryptionKey'),
              filter: anyNamed('filter')))
          .thenAnswer((realInvocation) => Future.error(exception));

      // When
      await repository
          .getClaims(
              genesisDid: CommonMocks.identifier,
              encryptionKey: CommonMocks.encryptionKey,
              filters: filters)
          .then((_) => expect(true, false))
          .catchError((error) {
        expect(error, isA<GetClaimsException>());
        expect(error.error, exception);
      });

      // Then
      var captureGet = verify(storageClaimDataSource.getClaims(
              did: captureAnyNamed('did'),
              encryptionKey: captureAnyNamed('encryptionKey'),
              filter: captureAnyNamed('filter')))
          .captured;
      expect(captureGet[0], CommonMocks.identifier);
      expect(captureGet[1], CommonMocks.encryptionKey);
      expect(captureGet[2], filter);

      expect(verify(filtersMapper.mapTo(captureAny)).captured.first, filters);

      verifyNever(claimMapper.mapFrom(captureAny));
    });
  });

  group("Get credential", () {
    setUp(() {
      // Given
      when(storageClaimDataSource.getClaims(
              did: anyNamed('did'),
              encryptionKey: anyNamed('encryptionKey'),
              filter: anyNamed('filter')))
          .thenAnswer((realInvocation) => Future.value([claimDTOs[0]]));
      when(
        storageClaimDataSource.getClaim(
          credentialId: anyNamed('credentialId'),
          did: anyNamed('did'),
          encryptionKey: CommonMocks.encryptionKey,
        ),
      ).thenAnswer((realInvocation) => Future.value(claimDTOs[0]));

      when(filtersMapper.mapTo(any)).thenReturn(filter);
      when(claimMapper.mapFrom(any)).thenReturn(claimEntities[0]);
    });

    test(
        "Given an id, when I call getClaim, then I expect a ClaimEntity to be returned",
        () async {
      // When
      expect(
        await repository.getClaim(
          genesisDid: CommonMocks.identifier,
          encryptionKey: CommonMocks.encryptionKey,
          claimId: ids[0],
        ),
        claimEntities[0],
      );

      var captureGet = verify(
        storageClaimDataSource.getClaim(
          credentialId: captureAnyNamed('credentialId'),
          did: captureAnyNamed('did'),
          encryptionKey: captureAnyNamed('encryptionKey'),
        ),
      ).captured;

      expect(captureGet[0], CommonMocks.id);
      expect(captureGet[1], CommonMocks.identifier);
      expect(captureGet[2], CommonMocks.encryptionKey);

      expect(
          verify(claimMapper.mapFrom(captureAny)).captured.first, claimDTOs[0]);
    });

    test(
        "Given an id, when I call getClaim and no claim are found, then I expect a ClaimNotFoundException to be thrown",
        () async {
      // Given
      when(
        storageClaimDataSource.getClaim(
          credentialId: anyNamed('credentialId'),
          did: anyNamed('did'),
          encryptionKey: anyNamed('encryptionKey'),
        ),
      ).thenAnswer((realInvocation) => Future.error(ClaimNotFoundException(
            id: ids[0],
            errorMessage: "Claim not found",
          )));
      // When
      await repository
          .getClaim(
            genesisDid: CommonMocks.identifier,
            encryptionKey: CommonMocks.encryptionKey,
            claimId: ids[0],
          )
          .then((value) => expect(true, false))
          .catchError((error) {
        expect(error, isA<ClaimNotFoundException>());
        expect(error.id, ids[0]);
      });

      var captureGet = verify(
        storageClaimDataSource.getClaim(
          did: captureAnyNamed('did'),
          encryptionKey: captureAnyNamed('encryptionKey'),
          credentialId: captureAnyNamed('credentialId'),
        ),
      ).captured;

      expect(captureGet[0], CommonMocks.identifier);
      expect(captureGet[1], CommonMocks.encryptionKey);
      expect(captureGet[2], CommonMocks.id);

      verifyNever(claimMapper.mapFrom(captureAny));
    });

    test(
        "Given an id, when I call getClaim and an error occurred, then I expect an exception to be thrown",
        () async {
      // Given
      when(
        storageClaimDataSource.getClaim(
          did: anyNamed('did'),
          encryptionKey: anyNamed('encryptionKey'),
          credentialId: anyNamed('credentialId'),
        ),
      ).thenAnswer(
        (realInvocation) => Future.error(claimNotFoundException),
      );

      await expectLater(
        repository.getClaim(
          genesisDid: CommonMocks.identifier,
          claimId: ids[0],
          encryptionKey: CommonMocks.encryptionKey,
        ),
        throwsA(claimNotFoundException),
      );

      // Then
      final captureGet = verify(
        storageClaimDataSource.getClaim(
          did: captureAnyNamed('did'),
          encryptionKey: captureAnyNamed('encryptionKey'),
          credentialId: captureAnyNamed('credentialId'),
        ),
      ).captured;

      expect(captureGet[0], CommonMocks.identifier);
      expect(captureGet[1], CommonMocks.encryptionKey);
      expect(captureGet[2], CommonMocks.id);

      verifyNever(claimMapper.mapFrom(captureAny));
    });
  });

  group("Remove all claims", () {
    setUp(() {
      // Given
      when(storageClaimDataSource.removeAllClaims(
              did: anyNamed('did'), encryptionKey: anyNamed('encryptionKey')))
          .thenAnswer((realInvocation) => Future.value());
    });

    test("When I call removeAllClaims, then I expect the process to completes",
        () async {
      // When
      await expectLater(
          repository.removeAllClaims(
              genesisDid: CommonMocks.identifier,
              encryptionKey: CommonMocks.encryptionKey),
          completes);

      // Then
      var captureRemove = verify(storageClaimDataSource.removeAllClaims(
              did: captureAnyNamed('did'),
              encryptionKey: captureAnyNamed('encryptionKey')))
          .captured;
      expect(captureRemove[0], CommonMocks.identifier);
      expect(captureRemove[1], CommonMocks.encryptionKey);
    });

    test(
        "When I call removeAllClaims and an error occurred, then I expect a RemoveClaimsException exception to be thrown",
        () async {
      // Given
      when(storageClaimDataSource.removeAllClaims(
              did: anyNamed('did'), encryptionKey: anyNamed('encryptionKey')))
          .thenAnswer((realInvocation) => Future.error(exception));

      // When
      await repository
          .removeAllClaims(
              genesisDid: CommonMocks.identifier,
              encryptionKey: CommonMocks.encryptionKey)
          .then((_) => expect(true, false))
          .catchError((error) {
        expect(error, isA<RemoveClaimsException>());
        expect(error.error, exception);
      });

      // Then
      var captureRemove = verify(storageClaimDataSource.removeAllClaims(
              did: captureAnyNamed('did'),
              encryptionKey: captureAnyNamed('encryptionKey')))
          .captured;
      expect(captureRemove[0], CommonMocks.identifier);
      expect(captureRemove[1], CommonMocks.encryptionKey);
    });
  });

  group("Remove credentials", () {
    setUp(() {
      // Given
      when(storageClaimDataSource.removeClaims(
              did: anyNamed('did'),
              encryptionKey: anyNamed('encryptionKey'),
              claimIds: anyNamed('claimIds')))
          .thenAnswer((realInvocation) => Future.value());
    });

    test(
        "Given a list of ids, when I call removeClaims, then I expect the process to completes",
        () async {
      // When
      await expectLater(
          repository.removeClaims(
              genesisDid: CommonMocks.identifier,
              encryptionKey: CommonMocks.encryptionKey,
              claimIds: ids),
          completes);

      // Then
      var captureRemove = verify(storageClaimDataSource.removeClaims(
              did: captureAnyNamed('did'),
              encryptionKey: captureAnyNamed('encryptionKey'),
              claimIds: captureAnyNamed('claimIds')))
          .captured;
      expect(captureRemove[0], CommonMocks.identifier);
      expect(captureRemove[1], CommonMocks.encryptionKey);
      expect(captureRemove[2], ids);
    });

    test(
        "Given a list of ids, when I call removeClaims and an error occurred, then I expect a RemoveClaimsException exception to be thrown",
        () async {
      // Given
      when(storageClaimDataSource.removeClaims(
              did: anyNamed('did'),
              encryptionKey: anyNamed('encryptionKey'),
              claimIds: anyNamed('claimIds')))
          .thenAnswer((realInvocation) => Future.error(exception));

      // When
      await repository
          .removeClaims(
              genesisDid: CommonMocks.identifier,
              encryptionKey: CommonMocks.encryptionKey,
              claimIds: ids)
          .then((_) => expect(true, false))
          .catchError((error) {
        expect(error, isA<RemoveClaimsException>());
        expect(error.error, exception);
      });

      // Then
      var captureRemove = verify(storageClaimDataSource.removeClaims(
              did: captureAnyNamed('did'),
              encryptionKey: captureAnyNamed('encryptionKey'),
              claimIds: captureAnyNamed('claimIds')))
          .captured;
      expect(captureRemove[0], CommonMocks.identifier);
      expect(captureRemove[1], CommonMocks.encryptionKey);
      expect(captureRemove[2], ids);
    });
  });
}
