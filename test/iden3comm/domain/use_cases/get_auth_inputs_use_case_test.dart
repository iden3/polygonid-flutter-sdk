import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/credential/domain/repositories/credential_repository.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/exceptions/iden3comm_exceptions.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/repositories/iden3comm_repository.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_auth_inputs_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/smt_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_latest_state_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/get_identity_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/sign_message_use_case.dart';
import 'package:polygonid_flutter_sdk/proof/domain/use_cases/get_gist_mtproof_use_case.dart';

import '../../../common/common_mocks.dart';
import '../../../common/identity_mocks.dart';
import '../../../common/proof_mocks.dart';
import 'get_auth_inputs_use_case_test.mocks.dart';

MockGetIdentityUseCase getIdentityUseCase = MockGetIdentityUseCase();
MockCredentialRepository credentialRepository = MockCredentialRepository();
MockSignMessageUseCase signMessageUseCase = MockSignMessageUseCase();
MockGetGistMTProofUseCase getGistProofUseCase = MockGetGistMTProofUseCase();
MockGetLatestStateUseCase getLatestStateUseCase = MockGetLatestStateUseCase();
MockIden3commRepository iden3commRepository = MockIden3commRepository();
MockIdentityRepository identityRepository = MockIdentityRepository();
MockSMTRepository smtRepository = MockSMTRepository();
MockStacktraceManager stacktraceManager = MockStacktraceManager();

// Data
GetAuthInputsParam param = GetAuthInputsParam(CommonMocks.challenge,
    CommonMocks.did, CommonMocks.nonce, CommonMocks.privateKey);
var claims = [CommonMocks.authClaim, CommonMocks.authClaim];
var getAuthInputsException = GetAuthInputsException(errorMessage: "error");

// Tested instance
GetAuthInputsUseCase useCase = GetAuthInputsUseCase(
  getIdentityUseCase,
  credentialRepository,
  signMessageUseCase,
  getGistProofUseCase,
  getLatestStateUseCase,
  iden3commRepository,
  identityRepository,
  smtRepository,
  stacktraceManager,
);

@GenerateMocks([
  GetIdentityUseCase,
  CredentialRepository,
  SignMessageUseCase,
  GetGistMTProofUseCase,
  GetLatestStateUseCase,
  Iden3commRepository,
  IdentityRepository,
  SMTRepository,
  StacktraceManager,
])
void main() {
  setUp(() {
    when(getIdentityUseCase.execute(param: anyNamed("param")))
        .thenAnswer((realInvocation) => Future.value(IdentityMocks.identity));
    when(signMessageUseCase.execute(param: anyNamed("param")))
        .thenAnswer((realInvocation) => Future.value(CommonMocks.signature));
    when(credentialRepository.getAuthClaim(publicKey: anyNamed("publicKey")))
        .thenAnswer((realInvocation) => Future.value(claims));
    when(iden3commRepository.getAuthInputs(
            genesisDid: anyNamed('genesisDid'),
            profileNonce: anyNamed('profileNonce'),
            challenge: anyNamed("challenge"),
            authClaim: anyNamed("authClaim"),
            identity: anyNamed("identity"),
            signature: anyNamed("signature"),
            incProof: anyNamed('incProof'),
            nonRevProof: anyNamed('nonRevProof'),
            gistProof: anyNamed('gistProof'),
            treeState: anyNamed('treeState')))
        .thenAnswer((realInvocation) =>
            Future.value(CommonMocks.generateInputsResponse));
    when(identityRepository.getAuthClaimNode(children: anyNamed('children')))
        .thenAnswer((realInvocation) => Future.value(IdentityMocks.node));
    when(smtRepository.generateProof(
            key: anyNamed('key'),
            type: anyNamed('type'),
            did: anyNamed('did'),
            privateKey: anyNamed('privateKey')))
        .thenAnswer((realInvocation) => Future.value(ProofMocks.mtProof));
    when(getLatestStateUseCase.execute(param: anyNamed('param')))
        .thenAnswer((realInvocation) => Future.value(CommonMocks.aMap));
    when(getGistProofUseCase.execute(param: anyNamed('param')))
        .thenAnswer((realInvocation) => Future.value(ProofMocks.gistMTProof));
  });

  test(
    'Given a param, when I call execute, then I expect a bytes list to be returned',
    () async {
      // When
      expect(await useCase.execute(param: param),
          CommonMocks.generateInputsResponse);

      // Then
      var capturedIdentity =
          verify(getIdentityUseCase.execute(param: captureAnyNamed("param")))
              .captured
              .first;
      expect(capturedIdentity.genesisDid, param.genesisDid);
      expect(capturedIdentity.privateKey, param.privateKey);

      var capturedSign =
          verify(signMessageUseCase.execute(param: captureAnyNamed("param")))
              .captured
              .first;
      expect(capturedSign.privateKey, param.privateKey);
      expect(capturedSign.message, CommonMocks.challenge);

      var capturedAuthInputs = verify(iden3commRepository.getAuthInputs(
              genesisDid: captureAnyNamed('genesisDid'),
              profileNonce: captureAnyNamed('profileNonce'),
              challenge: captureAnyNamed("challenge"),
              authClaim: captureAnyNamed("authClaim"),
              identity: captureAnyNamed("identity"),
              signature: captureAnyNamed("signature"),
              incProof: captureAnyNamed('incProof'),
              nonRevProof: captureAnyNamed('nonRevProof'),
              gistProof: captureAnyNamed('gistProof'),
              treeState: captureAnyNamed('treeState')))
          .captured;
      expect(capturedAuthInputs[0], CommonMocks.did);
      expect(capturedAuthInputs[1], CommonMocks.nonce);
      expect(capturedAuthInputs[2], CommonMocks.challenge);
      expect(capturedAuthInputs[3], claims);
      expect(capturedAuthInputs[4], IdentityMocks.identity);
      expect(capturedAuthInputs[5], CommonMocks.signature);
      expect(capturedAuthInputs[6], ProofMocks.mtProof);
      expect(capturedAuthInputs[7], ProofMocks.mtProof);
      expect(capturedAuthInputs[8], ProofMocks.gistMTProof);
      expect(capturedAuthInputs[9], CommonMocks.aMap);
    },
  );

  test(
    'Given a param, when I call execute and an error occurred, then I expect an exception to be thrown',
    () async {
      // Given
      when(getLatestStateUseCase.execute(param: anyNamed('param')))
          .thenAnswer((realInvocation) => Future.error(getAuthInputsException));

      // When
      await expectLater(
          useCase.execute(param: param), throwsA(getAuthInputsException));

      // Then
      var capturedIdentity =
          verify(getIdentityUseCase.execute(param: captureAnyNamed("param")))
              .captured
              .first;
      expect(capturedIdentity.genesisDid, param.genesisDid);
      expect(capturedIdentity.privateKey, param.privateKey);

      verifyNever(signMessageUseCase.execute(param: captureAnyNamed("param")));

      verifyNever(iden3commRepository.getAuthInputs(
          genesisDid: captureAnyNamed('genesisDid'),
          profileNonce: captureAnyNamed('profileNonce'),
          challenge: captureAnyNamed("challenge"),
          authClaim: captureAnyNamed("authClaim"),
          identity: captureAnyNamed("identity"),
          signature: captureAnyNamed("signature"),
          incProof: captureAnyNamed('incProof'),
          nonRevProof: captureAnyNamed('nonRevProof'),
          gistProof: captureAnyNamed('gistProof'),
          treeState: captureAnyNamed('treeState')));
    },
  );
}
