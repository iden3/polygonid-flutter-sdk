import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/exceptions/iden3comm_exceptions.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_auth_inputs_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_auth_token_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_auth_challenge_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_jwz_use_case.dart';
import 'package:polygonid_flutter_sdk/proof/domain/use_cases/load_circuit_use_case.dart';
import 'package:polygonid_flutter_sdk/proof/domain/use_cases/prove_use_case.dart';

import '../../../common/common_mocks.dart';
import '../../../common/iden3comm_mocks.dart';
import '../../../common/proof_mocks.dart';
import 'get_auth_token_use_case_test.mocks.dart';

// Data
final param = GetAuthTokenParam(
    genesisDid: CommonMocks.did,
    profileNonce: CommonMocks.genesisNonce,
    privateKey: CommonMocks.privateKey,
    message: CommonMocks.message);
const result = "token";
var exception = Exception();
var getAuthTokenException = GetAuthTokenException(errorMessage: "Error");

// Dependencies
MockLoadCircuitUseCase loadCircuitUseCase = MockLoadCircuitUseCase();
MockGetJWZUseCase getJWZUseCase = MockGetJWZUseCase();
MockGetAuthChallengeUseCase getAuthChallengeUseCase =
    MockGetAuthChallengeUseCase();
MockGetAuthInputsUseCase getAuthInputsUseCase = MockGetAuthInputsUseCase();
MockProveUseCase proveUseCase = MockProveUseCase();
MockStacktraceManager stacktraceManager = MockStacktraceManager();

// Tested instance
GetAuthTokenUseCase useCase = GetAuthTokenUseCase(
  loadCircuitUseCase,
  getJWZUseCase,
  getAuthChallengeUseCase,
  getAuthInputsUseCase,
  proveUseCase,
  stacktraceManager,
);

@GenerateMocks([
  LoadCircuitUseCase,
  GetJWZUseCase,
  GetAuthChallengeUseCase,
  GetAuthInputsUseCase,
  ProveUseCase,
  StacktraceManager,
])
void main() {
  setUp(() {
    // Given
    when(getJWZUseCase.execute(param: anyNamed('param'))).thenAnswer(
        (realInvocation) => Future.value(Iden3commMocks.encodedJWZ));
    when(getAuthChallengeUseCase.execute(param: anyNamed('param')))
        .thenAnswer((realInvocation) => Future.value(CommonMocks.challenge));
    when(getAuthInputsUseCase.execute(param: anyNamed('param')))
        .thenAnswer((realInvocation) => Future.value(CommonMocks.generateInputsResponse));
    when(loadCircuitUseCase.execute(param: anyNamed('param')))
        .thenAnswer((realInvocation) => Future.value(ProofMocks.circuitData));
    when(proveUseCase.execute(param: anyNamed('param')))
        .thenAnswer((realInvocation) => Future.value(ProofMocks.zkProof));
  });

  test(
      "Given a GetAuthTokenParam, when I call execute, then I expect a token String to be returned",
      () async {
    // When
    expect(await useCase.execute(param: param), Iden3commMocks.encodedJWZ);

    // Then
    var verifyGetJWZ =
        verify(getJWZUseCase.execute(param: captureAnyNamed('param')));
    expect(verifyGetJWZ.callCount, 2);
    expect(verifyGetJWZ.captured[0].message, param.message);
    expect(verifyGetJWZ.captured[0].proof, null);
    expect(verifyGetJWZ.captured[1].message, param.message);
    expect(verifyGetJWZ.captured[1].proof, ProofMocks.zkProof);

    expect(
        verify(getAuthChallengeUseCase.execute(param: captureAnyNamed('param')))
            .captured
            .first,
        Iden3commMocks.encodedJWZ);

    var captureAuthInputs =
        verify(getAuthInputsUseCase.execute(param: captureAnyNamed('param')))
            .captured
            .first;
    expect(captureAuthInputs.genesisDid, CommonMocks.did);
    expect(captureAuthInputs.privateKey, CommonMocks.privateKey);

    expect(
        verify(loadCircuitUseCase.execute(param: captureAnyNamed('param')))
            .captured
            .first,
        "authV2");

    var captureProve =
        verify(proveUseCase.execute(param: captureAnyNamed('param')))
            .captured
            .first;
    expect(captureProve.inputs, CommonMocks.inputs);
    expect(captureProve.circuitData, ProofMocks.circuitData);
  });

  test(
      "Given a GetAuthTokenParam, when I call execute and an error occurred, then I expect an exception to be thrown",
      () async {
    // Given
    when(proveUseCase.execute(param: anyNamed('param')))
        .thenAnswer((realInvocation) => Future.error(getAuthTokenException));

    // When
    await expectLater(
        useCase.execute(param: param), throwsA(getAuthTokenException));

    // Then
    var verifyGetJWZ =
        verify(getJWZUseCase.execute(param: captureAnyNamed('param')));
    expect(verifyGetJWZ.callCount, 1);
    expect(verifyGetJWZ.captured[0].message, param.message);
    expect(verifyGetJWZ.captured[0].proof, null);

    expect(
        verify(getAuthChallengeUseCase.execute(param: captureAnyNamed('param')))
            .captured
            .first,
        Iden3commMocks.encodedJWZ);

    var captureAuthInputs =
        verify(getAuthInputsUseCase.execute(param: captureAnyNamed('param')))
            .captured
            .first;
    expect(captureAuthInputs.genesisDid, CommonMocks.did);
    expect(captureAuthInputs.privateKey, CommonMocks.privateKey);

    expect(
        verify(loadCircuitUseCase.execute(param: captureAnyNamed('param')))
            .captured
            .first,
        "authV2");

    var captureProve =
        verify(proveUseCase.execute(param: captureAnyNamed('param')))
            .captured
            .first;
    expect(captureProve.inputs, CommonMocks.inputs);
    expect(captureProve.circuitData, ProofMocks.circuitData);
  });
}
