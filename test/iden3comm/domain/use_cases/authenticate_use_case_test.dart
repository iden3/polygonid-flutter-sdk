import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_cases/get_env_use_case.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_cases/get_package_name_use_case.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_cases/get_selected_chain_use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/repositories/iden3comm_repository.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/authenticate_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/check_profile_and_did_current_env.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_auth_token_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_iden3comm_proofs_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_did_identifier_use_case.dart';
import 'package:polygonid_flutter_sdk/proof/infrastructure/proof_generation_stream_manager.dart';
import '../../../common/common_mocks.dart';
import '../../../common/iden3comm_mocks.dart';
import 'authenticate_use_case_test.mocks.dart';

MockIden3commRepository iden3commRepository = MockIden3commRepository();
MockGetIden3commProofsUseCase getIden3commProofsUseCase =
    MockGetIden3commProofsUseCase();
MockGetDidIdentifierUseCase getDidIdentifierUseCase =
    MockGetDidIdentifierUseCase();
MockGetAuthTokenUseCase getAuthTokenUseCase = MockGetAuthTokenUseCase();
MockGetEnvUseCase getEnvUseCase = MockGetEnvUseCase();
MockGetSelectedChainUseCase getSelectedChainUseCase =
    MockGetSelectedChainUseCase();
MockGetPackageNameUseCase getPackageNameUseCase = MockGetPackageNameUseCase();
MockCheckProfileAndDidCurrentEnvUseCase checkProfileAndDidCurrentEnvUseCase =
    MockCheckProfileAndDidCurrentEnvUseCase();
MockProofGenerationStepsStreamManager proofGenerationStepsStreamManager =
    MockProofGenerationStepsStreamManager();
MockStacktraceManager stacktraceStreamManager = MockStacktraceManager();

AuthenticateUseCase useCase = AuthenticateUseCase(
  iden3commRepository,
  getIden3commProofsUseCase,
  getDidIdentifierUseCase,
  getAuthTokenUseCase,
  getEnvUseCase,
  getSelectedChainUseCase,
  getPackageNameUseCase,
  checkProfileAndDidCurrentEnvUseCase,
  proofGenerationStepsStreamManager,
  stacktraceStreamManager,
);

AuthenticateParam param = AuthenticateParam(
  message: Iden3commMocks.authRequest,
  genesisDid: CommonMocks.did,
  profileNonce: CommonMocks.genesisNonce,
  pushToken: CommonMocks.token,
  privateKey: CommonMocks.privateKey,
);

@GenerateMocks([
  Iden3commRepository,
  GetIden3commProofsUseCase,
  GetDidIdentifierUseCase,
  GetAuthTokenUseCase,
  GetEnvUseCase,
  GetSelectedChainUseCase,
  GetPackageNameUseCase,
  CheckProfileAndDidCurrentEnvUseCase,
  ProofGenerationStepsStreamManager,
  StacktraceManager,
])
void main() {
  group(
    "Authenticate",
    () {
      setUp(() {
        // Given
        reset(iden3commRepository);

        when(getIden3commProofsUseCase.execute(param: anyNamed('param')))
            .thenAnswer((realInvocation) => Future.value([]));

        when(getDidIdentifierUseCase.execute(param: anyNamed('param')))
            .thenAnswer((realInvocation) => Future.value(CommonMocks.did));

        when(getEnvUseCase.execute(param: anyNamed('param')))
            .thenAnswer((realInvocation) => Future.value(CommonMocks.env));

        when(getSelectedChainUseCase.execute(param: anyNamed('param')))
            .thenAnswer((realInvocation) => Future.value(CommonMocks.chain));

        when(checkProfileAndDidCurrentEnvUseCase.execute(
                param: anyNamed('param')))
            .thenAnswer((realInvocation) => Future.value(null));

        when(getPackageNameUseCase.execute(param: anyNamed('param')))
            .thenAnswer((realInvocation) => Future.value(CommonMocks.config));

        when(iden3commRepository.getAuthResponse(
                did: anyNamed('did'),
                request: anyNamed('request'),
                scope: anyNamed('scope'),
                pushUrl: anyNamed('pushUrl'),
                pushToken: anyNamed('pushToken'),
                packageName: anyNamed('packageName')))
            .thenAnswer((realInvocation) => Future.value(CommonMocks.message));

        when(getAuthTokenUseCase.execute(param: anyNamed('param')))
            .thenAnswer((realInvocation) => Future.value(CommonMocks.id));

        when(iden3commRepository.authenticate(
          request: anyNamed('request'),
          authToken: anyNamed('authToken'),
        )).thenAnswer((realInvocation) => Future.value());
      });

      test(
        'Given a good param, when I call execute, then I expect that the flow completes without exception',
        () async {
          // When
          await expectLater(useCase.execute(param: param), completes);

          // Then
          var capturedProofs = verify(getIden3commProofsUseCase.execute(
                  param: captureAnyNamed('param')))
              .captured
              .first;
          expect(capturedProofs.message, Iden3commMocks.authRequest);
          expect(capturedProofs.genesisDid, CommonMocks.did);
          expect(capturedProofs.privateKey, CommonMocks.privateKey);

          var captureDidIdentifier = verify(getDidIdentifierUseCase.execute(
                  param: captureAnyNamed('param')))
              .captured
              .first;
          expect(captureDidIdentifier.bjjPrivateKey, CommonMocks.privateKey);
          expect(captureDidIdentifier.blockchain, CommonMocks.name);
          expect(captureDidIdentifier.network, CommonMocks.network);

          var verifyConfig =
              verify(getEnvUseCase.execute(param: captureAnyNamed('param')));
          expect(verifyConfig.callCount, 1);
          var capturedConfig = verifyConfig.captured;
          expect(capturedConfig[0], null);

          var captureCheck = verify(checkProfileAndDidCurrentEnvUseCase.execute(
                  param: captureAnyNamed('param')))
              .captured
              .first;
          expect(captureCheck.did, CommonMocks.did);
          expect(captureCheck.privateKey, CommonMocks.privateKey);
          expect(captureCheck.profileNonce, CommonMocks.genesisNonce);

          verify(getPackageNameUseCase.execute());

          var capturedAuthResponse = verify(iden3commRepository.getAuthResponse(
                  did: captureAnyNamed('did'),
                  request: captureAnyNamed('request'),
                  scope: captureAnyNamed('scope'),
                  pushUrl: captureAnyNamed('pushUrl'),
                  pushToken: captureAnyNamed('pushToken'),
                  packageName: captureAnyNamed('packageName')))
              .captured;
          expect(capturedAuthResponse[0], CommonMocks.did);
          expect(capturedAuthResponse[1], Iden3commMocks.authRequest);
          expect(capturedAuthResponse[2], []);
          expect(capturedAuthResponse[3], CommonMocks.url);
          expect(capturedAuthResponse[4], CommonMocks.token);
          expect(capturedAuthResponse[5], CommonMocks.config);

          var capturedAuthToken = verify(
                  getAuthTokenUseCase.execute(param: captureAnyNamed('param')))
              .captured
              .first;
          expect(capturedAuthToken.genesisDid, CommonMocks.did);
          expect(capturedAuthToken.privateKey, CommonMocks.privateKey);
          expect(capturedAuthToken.message, CommonMocks.message);

          var capturedAuthenticate = verify(iden3commRepository.authenticate(
            request: captureAnyNamed('request'),
            authToken: captureAnyNamed('authToken'),
          )).captured;
          expect(capturedAuthenticate[0], Iden3commMocks.authRequest);
          expect(capturedAuthenticate[1], CommonMocks.id);
        },
      );

      test(
        'Given a param, when I call execute and an error occured, then I expect an exception to be thrown',
        () async {
          // Given
          when(iden3commRepository.getAuthResponse(
                  did: anyNamed('did'),
                  request: anyNamed('request'),
                  scope: anyNamed('scope'),
                  pushUrl: anyNamed('pushUrl'),
                  pushToken: anyNamed('pushToken'),
                  packageName: anyNamed('packageName')))
              .thenAnswer(
                  (realInvocation) => Future.error(CommonMocks.exception));

          // When
          await expectLater(
              useCase.execute(param: param), throwsA(CommonMocks.exception));

          // Then
          var capturedProofs = verify(getIden3commProofsUseCase.execute(
                  param: captureAnyNamed('param')))
              .captured
              .first;
          expect(capturedProofs.message, Iden3commMocks.authRequest);
          expect(capturedProofs.genesisDid, CommonMocks.did);
          expect(capturedProofs.privateKey, CommonMocks.privateKey);

          var verifyConfig =
              verify(getEnvUseCase.execute(param: captureAnyNamed('param')));
          expect(verifyConfig.callCount, 1);
          var capturedConfig = verifyConfig.captured;
          expect(capturedConfig[0], null);

          var captureCheck = verify(checkProfileAndDidCurrentEnvUseCase.execute(
                  param: captureAnyNamed('param')))
              .captured
              .first;
          expect(captureCheck.did, CommonMocks.did);
          expect(captureCheck.privateKey, CommonMocks.privateKey);
          expect(captureCheck.profileNonce, CommonMocks.genesisNonce);

          verify(getPackageNameUseCase.execute());

          var capturedAuthResponse = verify(iden3commRepository.getAuthResponse(
                  did: captureAnyNamed('did'),
                  request: captureAnyNamed('request'),
                  scope: captureAnyNamed('scope'),
                  pushUrl: captureAnyNamed('pushUrl'),
                  pushToken: captureAnyNamed('pushToken'),
                  packageName: captureAnyNamed('packageName')))
              .captured;
          expect(capturedAuthResponse[0], CommonMocks.did);
          expect(capturedAuthResponse[1], Iden3commMocks.authRequest);
          expect(capturedAuthResponse[2], []);
          expect(capturedAuthResponse[3], CommonMocks.url);
          expect(capturedAuthResponse[4], CommonMocks.token);
          expect(capturedAuthResponse[5], CommonMocks.config);

          verifyNever(
              getAuthTokenUseCase.execute(param: captureAnyNamed('param')));

          verifyNever(iden3commRepository.authenticate(
            request: captureAnyNamed('request'),
            authToken: captureAnyNamed('authToken'),
          ));
        },
      );
    },
  );
}
