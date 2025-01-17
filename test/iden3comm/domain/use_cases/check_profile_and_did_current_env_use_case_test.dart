import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_cases/get_selected_chain_use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/exceptions/iden3comm_exceptions.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/check_profile_and_did_current_env.dart';
import 'package:polygonid_flutter_sdk/identity/domain/exceptions/identity_exceptions.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_did_identifier_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_public_keys_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/profile/check_profile_validity_use_case.dart';

import '../../../common/common_mocks.dart';
import 'check_profile_and_did_current_env_use_case_test.mocks.dart';

var checkProfileValidityException =
    CheckProfileValidityException(errorMessage: "Error");

// Dependencies
MockCheckProfileValidityUseCase checkProfileValidityUseCase =
    MockCheckProfileValidityUseCase();
MockGetSelectedChainUseCase getSelectedChainUseCase =
    MockGetSelectedChainUseCase();
MockGetDidIdentifierUseCase getDidIdentifierUseCase =
    MockGetDidIdentifierUseCase();
MockGetPublicKeyUseCase getPublicKeyUseCase = MockGetPublicKeyUseCase();
MockStacktraceManager stacktraceStreamManager = MockStacktraceManager();

// Tested instance
CheckProfileAndDidCurrentEnvUseCase useCase =
    CheckProfileAndDidCurrentEnvUseCase(
  checkProfileValidityUseCase,
  getSelectedChainUseCase,
  getDidIdentifierUseCase,
  getPublicKeyUseCase,
  stacktraceStreamManager,
);

@GenerateMocks([
  CheckProfileValidityUseCase,
  GetSelectedChainUseCase,
  GetDidIdentifierUseCase,
  GetPublicKeyUseCase,
  StacktraceManager,
])
void main() {
  setUp(() {
    when(checkProfileValidityUseCase.execute(param: anyNamed('param')))
        .thenAnswer((realInvocation) => Future.value(null));
    when(getSelectedChainUseCase.execute(param: anyNamed('param')))
        .thenAnswer((realInvocation) => Future.value(CommonMocks.chain));
    when(getDidIdentifierUseCase.execute(param: anyNamed('param')))
        .thenAnswer((realInvocation) => Future.value(CommonMocks.did));
  });

  test("Given param, when I call execute, I expect the process to complete",
      () async {
    // When
    await expectLater(
        useCase.execute(
            param: CheckProfileAndDidCurrentEnvParam(
                did: CommonMocks.did,
                publicKey: CommonMocks.publicKey,
                profileNonce: CommonMocks.nonce)),
        completes);

    // Then
    expect(
        verify(checkProfileValidityUseCase.execute(
                param: captureAnyNamed('param')))
            .captured
            .first
            .profileNonce,
        CommonMocks.nonce);
    verify(getSelectedChainUseCase.execute(param: anyNamed('param')));

    var captureDidIdentifier =
        verify(getDidIdentifierUseCase.execute(param: captureAnyNamed('param')))
            .captured
            .first;
    expect(captureDidIdentifier.bjjPublicKey, CommonMocks.publicKey);
    expect(captureDidIdentifier.blockchain, CommonMocks.name);
    expect(captureDidIdentifier.network, CommonMocks.network);
  });

  test(
      "Given param, when I call execute with a did from another env, I expect a DidNotMatchCurrentEnvException to be thrown",
      () async {
    // Given
    when(getDidIdentifierUseCase.execute(param: anyNamed('param')))
        .thenAnswer((realInvocation) => Future.value(CommonMocks.id));

    // When
    await useCase
        .execute(
            param: CheckProfileAndDidCurrentEnvParam(
                did: CommonMocks.did,
                publicKey: CommonMocks.publicKey,
                profileNonce: CommonMocks.nonce))
        .then((_) => expect(true, false))
        .catchError((error) {
      expect(error, isA<DidNotMatchCurrentEnvException>());
      expect(error.did, CommonMocks.did);
      expect(error.rightDid, CommonMocks.id);
    });

    // Then
    expect(
        verify(checkProfileValidityUseCase.execute(
                param: captureAnyNamed('param')))
            .captured
            .first
            .profileNonce,
        CommonMocks.nonce);
    verify(getSelectedChainUseCase.execute(param: anyNamed('param')));

    var captureDidIdentifier =
        verify(getDidIdentifierUseCase.execute(param: captureAnyNamed('param')))
            .captured
            .first;
    expect(captureDidIdentifier.bjjPublicKey, CommonMocks.publicKey);
    expect(captureDidIdentifier.blockchain, CommonMocks.name);
    expect(captureDidIdentifier.network, CommonMocks.network);
  });

  test(
      "Given param, when I call execute and an error occurred, I expect an exception to be thrown",
      () async {
    // Given
    when(getSelectedChainUseCase.execute(param: anyNamed('param'))).thenAnswer(
        (realInvocation) => Future.error(checkProfileValidityException));

    // When
    await expectLater(
        useCase.execute(
            param: CheckProfileAndDidCurrentEnvParam(
                did: CommonMocks.did,
                publicKey: CommonMocks.publicKey,
                profileNonce: CommonMocks.nonce)),
        throwsA(checkProfileValidityException));

    // Then
    expect(
        verify(checkProfileValidityUseCase.execute(
                param: captureAnyNamed('param')))
            .captured
            .first
            .profileNonce,
        CommonMocks.nonce);
    verify(getSelectedChainUseCase.execute(param: anyNamed('param')));
    verifyNever(
        getDidIdentifierUseCase.execute(param: captureAnyNamed('param')));
  });
}
