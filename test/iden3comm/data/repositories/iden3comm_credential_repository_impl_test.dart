import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/credential/data/mappers/claim_mapper.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/data_sources/remote_iden3comm_data_source.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/mappers/proof_request_filters_mapper.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/repositories/iden3comm_credential_repository_impl.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/exceptions/iden3comm_exceptions.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/repositories/iden3comm_credential_repository.dart';

import '../../../common/common_mocks.dart';
import '../../../common/credential_mocks.dart';
import 'iden3comm_credential_repository_impl_test.mocks.dart';

// Data

// Dependencies
MockRemoteIden3commDataSource remoteIden3commDataSource =
    MockRemoteIden3commDataSource();
MockClaimMapper claimMapper = MockClaimMapper();
MockProofRequestFiltersMapper proofRequestFiltersMapper =
    MockProofRequestFiltersMapper();
MockStacktraceManager stacktraceManager = MockStacktraceManager();

// Tested instance
Iden3commCredentialRepository repository = Iden3commCredentialRepositoryImpl(
  remoteIden3commDataSource,
  proofRequestFiltersMapper,
  claimMapper,
  stacktraceManager,
);

@GenerateMocks([
  RemoteIden3commDataSource,
  ClaimMapper,
  ProofRequestFiltersMapper,
  StacktraceManager,
])
void main() {
  group("Fetch credential", () {
    setUp(() {
      reset(remoteIden3commDataSource);

      // Given
      when(remoteIden3commDataSource.fetchSchema(url: anyNamed('url')))
          .thenAnswer((realInvocation) => Future.value(CommonMocks.aMap));
      when(remoteIden3commDataSource.fetchClaim(
              authToken: anyNamed('authToken'),
              url: anyNamed('url'),
              did: anyNamed('did')))
          .thenAnswer(
              (realInvocation) => Future.value(CredentialMocks.claimDTO));
      when(claimMapper.mapFrom(any)).thenReturn(CredentialMocks.claim);
    });

    test(
        "Given parameters, when I call fetchClaim, then I expect a ClaimEntity to be returned",
        () async {
      // When
      expect(
          await repository.fetchClaim(
              did: CommonMocks.identifier,
              authToken: CommonMocks.token,
              url: CommonMocks.url),
          CredentialMocks.claim);

      // Then
      var fetchCaptured = verify(remoteIden3commDataSource.fetchClaim(
              authToken: captureAnyNamed('authToken'),
              url: captureAnyNamed('url'),
              did: captureAnyNamed('did')))
          .captured;

      expect(fetchCaptured[0], CommonMocks.token);
      expect(fetchCaptured[1], CommonMocks.url);
      expect(fetchCaptured[2], CommonMocks.identifier);

      expect(verify(claimMapper.mapFrom(captureAny)).captured.first,
          CredentialMocks.claimDTO);
    });

    test(
        "Given parameters, when I call fetchClaim and an error occurred, then I expect a FetchClaimException to be thrown",
        () async {
      // Given
      when(remoteIden3commDataSource.fetchClaim(
              authToken: anyNamed('authToken'),
              url: anyNamed('url'),
              did: anyNamed('did')))
          .thenAnswer((realInvocation) => Future.error(CommonMocks.exception));

      // When
      await repository
          .fetchClaim(
              did: CommonMocks.identifier,
              authToken: CommonMocks.token,
              url: CommonMocks.url)
          .then((_) => expect(true, false))
          .catchError((error) {
        expect(error, isA<FetchClaimException>());
        expect(error.error, CommonMocks.exception);
      });

      // Then
      var fetchCaptured = verify(remoteIden3commDataSource.fetchClaim(
              authToken: captureAnyNamed('authToken'),
              url: captureAnyNamed('url'),
              did: captureAnyNamed('did')))
          .captured;

      expect(fetchCaptured[0], CommonMocks.token);
      expect(fetchCaptured[1], CommonMocks.url);
      expect(fetchCaptured[2], CommonMocks.identifier);

      verifyNever(claimMapper.mapFrom(captureAny));
    });
  });
}
