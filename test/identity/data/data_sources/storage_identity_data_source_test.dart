import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/identity/data/data_sources/storage_identity_data_source.dart';
import 'package:polygonid_flutter_sdk/common/data/data_sources/storage_key_value_data_source.dart';
import 'package:polygonid_flutter_sdk/identity/data/data_sources/wallet_data_source.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/identity_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/exceptions/identity_exceptions.dart';
import 'package:sembast/sembast.dart';

import '../../../common/common_mocks.dart';
import 'storage_identity_data_source_test.mocks.dart';

// Data
final mockGet = {
  'did': CommonMocks.did,
  'publicKey': CommonMocks.publicKey,
  'profiles': {'0': "${CommonMocks.did}0", '1': "${CommonMocks.did}1"}
};
final identityDTO = IdentityEntity(
    did: CommonMocks.did,
    publicKey: CommonMocks.publicKey,
    profiles: CommonMocks.profiles);
final exception = Exception();

// Dependencies
MockDatabase database = MockDatabase();
MockIdentityStoreRefWrapper storeRefWrapper = MockIdentityStoreRefWrapper();
MockWalletDataSource walletDataSource = MockWalletDataSource();
MockStacktraceManager stacktraceManager = MockStacktraceManager();

// Tested instance
StorageIdentityDataSource dataSource = StorageIdentityDataSource(
  database,
  storeRefWrapper,
  stacktraceManager,
);

@GenerateMocks([
  Database,
  IdentityStoreRefWrapper,
  StorageKeyValueDataSource,
  WalletDataSource,
  StacktraceManager,
])
void main() {
  group("Get identity", () {
    test(
        "Given an did with an already stored identity, when I call getIdentity, then I expect an IdentityDTO to be returned",
        () async {
      // Given
      when(storeRefWrapper.get(any, any))
          .thenAnswer((realInvocation) => Future.value(mockGet));

      // When
      expect(await dataSource.getIdentity(did: CommonMocks.did), identityDTO);

      // Then
      var captured =
          verify(storeRefWrapper.get(captureAny, captureAny)).captured;
      expect(captured[0], database);
      expect(captured[1], CommonMocks.did);
    });

    test(
        "Given an did with no stored identity, when I call getIdentity, then I expect a null to be returned",
        () async {
      // Given
      when(storeRefWrapper.get(any, any))
          .thenAnswer((realInvocation) => Future.value(null));

      // When
      await dataSource
          .getIdentity(did: CommonMocks.did)
          .then((_) => expect(true, false)) // Be sure we don't succeed
          .catchError((error) {
        expect(error, isA<UnknownIdentityException>());
        expect(error.did, CommonMocks.did);
      });

      // Then
      var captured =
          verify(storeRefWrapper.get(captureAny, captureAny)).captured;
      expect(captured[0], database);
      expect(captured[1], CommonMocks.did);
    });

    test(
        "Given an did, when I call getIdentity and an error occurred, then I expect an exception to be thrown",
        () async {
      // Given
      when(storeRefWrapper.get(any, any))
          .thenAnswer((realInvocation) => Future.error(exception));

      // When
      await expectLater(
          dataSource.getIdentity(did: CommonMocks.did), throwsA(exception));

      // Then
      var captured =
          verify(storeRefWrapper.get(captureAny, captureAny)).captured;
      expect(captured[0], database);
      expect(captured[1], CommonMocks.did);
    });
  });

  group("Store identity", () {
    test(
        "Given an did and an identity, when I call storeIdentity, then I expect the process to be completed",
        () async {
      // Given
      when(storeRefWrapper.put(any, any, any))
          .thenAnswer((realInvocation) => Future.value(mockGet));

      // When
      await expectLater(
          dataSource.storeIdentityTransact(
              transaction: database,
              did: CommonMocks.did,
              identity: identityDTO),
          completes);

      // Then
      var capturedPut =
          verify(storeRefWrapper.put(captureAny, captureAny, captureAny))
              .captured;
      expect(capturedPut[0], database);
      expect(capturedPut[1], CommonMocks.did);
    });

    test(
        "Given an did and an identity, when I call storeIdentity and an error occurred, then I expect an exception to be thrown",
        () async {
      // Given
      when(storeRefWrapper.put(any, any, any))
          .thenAnswer((realInvocation) => Future.error(exception));

      // When
      await expectLater(
          dataSource.storeIdentityTransact(
              transaction: database,
              did: CommonMocks.did,
              identity: identityDTO),
          throwsA(exception));

      // Then
      var captured =
          verify(storeRefWrapper.put(captureAny, captureAny, captureAny))
              .captured;
      expect(captured[0], database);
      expect(captured[1], CommonMocks.did);
      expect(captured[2], identityDTO.toJson());
    });
  });

  group("Remove identity", () {
    test(
        "Given an did, when I call removeIdentityTransact, then I expect the process to be completed",
        () async {
      // Given
      when(storeRefWrapper.remove(any, any))
          .thenAnswer((realInvocation) => Future.value());

      // When
      await expectLater(
          dataSource.removeIdentityTransact(
              transaction: database, did: CommonMocks.did),
          completes);

      // Then
      var capturedStore =
          verify(storeRefWrapper.remove(captureAny, captureAny)).captured;
      expect(capturedStore[0], database);
      expect(capturedStore[1], CommonMocks.did);
    });

    test(
        "Given an did, when I call removeIdentity and an error occurred, then I expect an exception to be thrown",
        () async {
      // Given
      when(storeRefWrapper.remove(any, any))
          .thenAnswer((realInvocation) => Future.error(exception));

      // When
      await expectLater(
          dataSource.removeIdentityTransact(
              transaction: database, did: CommonMocks.did),
          throwsA(exception));

      // Then
      var capturedStore =
          verify(storeRefWrapper.remove(captureAny, captureAny)).captured;
      expect(capturedStore[0], database);
      expect(capturedStore[1], CommonMocks.did);
    });
  });
}
