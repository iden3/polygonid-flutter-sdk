import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/tree_type.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/smt_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_latest_state_use_case.dart';

import '../../../common/common_mocks.dart';
import '../../../common/identity_mocks.dart';
import 'get_latest_state_use_case_test.mocks.dart';

MockSMTRepository smtRepository = MockSMTRepository();
MockStacktraceManager stacktraceManager = MockStacktraceManager();

GetLatestStateUseCase useCase = GetLatestStateUseCase(
  smtRepository,
  stacktraceManager,
);

// Data
GetLatestStateParam param = GetLatestStateParam(
  did: CommonMocks.did,
  encryptionKey: CommonMocks.privateKey,
);

@GenerateMocks([SMTRepository, StacktraceManager])
void main() {
  group(
    "Get latest state",
    () {
      setUp(() {
        // Given
        reset(smtRepository);

        when(smtRepository.getRoot(
                type: anyNamed('type'),
                did: anyNamed('did'),
                encryptionKey: anyNamed('encryptionKey')))
            .thenAnswer((realInvocation) => Future.value(IdentityMocks.hash));

        when(smtRepository.hashState(
          claims: anyNamed('claims'),
          revocation: anyNamed('revocation'),
          roots: anyNamed('roots'),
        )).thenAnswer((realInvocation) => Future.value(CommonMocks.hash));

        when(smtRepository.convertState(state: anyNamed('state')))
            .thenAnswer((realInvocation) => Future.value(CommonMocks.aMap));
      });

      test(
        'Given a param, when I call execute, then I expect a map to be returned',
        () async {
          // When
          expect(await useCase.execute(param: param), CommonMocks.aMap);

          // Then
          var verifyRoot = verify(smtRepository.getRoot(
              type: captureAnyNamed('type'),
              did: captureAnyNamed('did'),
              encryptionKey: captureAnyNamed('encryptionKey')));
          expect(verifyRoot.callCount, 3);
          expect(verifyRoot.captured[0], TreeType.claims);
          expect(verifyRoot.captured[1], CommonMocks.did);
          expect(verifyRoot.captured[2], CommonMocks.privateKey);
          expect(verifyRoot.captured[3], TreeType.revocation);
          expect(verifyRoot.captured[4], CommonMocks.did);
          expect(verifyRoot.captured[5], CommonMocks.privateKey);
          expect(verifyRoot.captured[6], TreeType.roots);
          expect(verifyRoot.captured[7], CommonMocks.did);
          expect(verifyRoot.captured[8], CommonMocks.privateKey);

          var captureHash = verify(smtRepository.hashState(
            claims: captureAnyNamed('claims'),
            revocation: captureAnyNamed('revocation'),
            roots: captureAnyNamed('roots'),
          )).captured;
          expect(captureHash[0], IdentityMocks.hash.string());
          expect(captureHash[1], IdentityMocks.hash.string());
          expect(captureHash[2], IdentityMocks.hash.string());

          expect(
              verify(smtRepository.convertState(
                      state: captureAnyNamed('state')))
                  .captured
                  .first,
              IdentityMocks.treeState);
        },
      );

      test(
        'Given a param, when I call execute and an error occurred, then I expect an exception to be thrown',
        () async {
          // Given
          when(smtRepository.getRoot(
                  type: anyNamed('type'),
                  did: anyNamed('did'),
                  encryptionKey: anyNamed('encryptionKey')))
              .thenAnswer(
                  (realInvocation) => Future.error(CommonMocks.exception));

          // When
          await expectLater(
              useCase.execute(param: param), throwsA(CommonMocks.exception));

          // Then
          var verifyRoot = verify(smtRepository.getRoot(
              type: captureAnyNamed('type'),
              did: captureAnyNamed('did'),
              encryptionKey: captureAnyNamed('encryptionKey')));
          expect(verifyRoot.callCount, 3);
          expect(verifyRoot.captured[0], TreeType.claims);
          expect(verifyRoot.captured[1], CommonMocks.did);
          expect(verifyRoot.captured[2], CommonMocks.privateKey);
          expect(verifyRoot.captured[3], TreeType.revocation);
          expect(verifyRoot.captured[4], CommonMocks.did);
          expect(verifyRoot.captured[5], CommonMocks.privateKey);
          expect(verifyRoot.captured[6], TreeType.roots);
          expect(verifyRoot.captured[7], CommonMocks.did);
          expect(verifyRoot.captured[8], CommonMocks.privateKey);

          verifyNever(smtRepository.hashState(
            claims: captureAnyNamed('claims'),
            revocation: captureAnyNamed('revocation'),
            roots: captureAnyNamed('roots'),
          ));

          verifyNever(
              smtRepository.convertState(state: captureAnyNamed('state')));
        },
      );
    },
  );
}
