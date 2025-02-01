import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/add_identity_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/add_new_identity_use_case.dart';

import '../../../../common/common_mocks.dart';
import '../../../../common/identity_mocks.dart';
import 'add_new_identity_use_case_test.mocks.dart';

// Dependencies
MockIdentityRepository identityRepository = MockIdentityRepository();
MockAddIdentityUseCase addIdentityUseCase = MockAddIdentityUseCase();
MockStacktraceManager stacktraceManager = MockStacktraceManager();

// Tested instance
AddNewIdentityUseCase useCase = AddNewIdentityUseCase(
  identityRepository,
  addIdentityUseCase,
  stacktraceManager,
);

@GenerateMocks([
  IdentityRepository,
  AddIdentityUseCase,
  StacktraceManager,
])
void main() {
  setUp(() {
    // Given
    when(identityRepository.getPrivateKey(secret: anyNamed('secret')))
        .thenAnswer((realInvocation) => Future.value(CommonMocks.privateKey));
    when(identityRepository.getPublicKeys(
            bjjPrivateKey: anyNamed('bjjPrivateKey')))
        .thenAnswer((realInvocation) => Future.value(CommonMocks.publicKey));
    when(addIdentityUseCase.execute(param: anyNamed('param'))).thenAnswer(
        (realInvocation) => Future.value(IdentityMocks.privateIdentity));
  });

  test(
      "Given a secret, when I call execute, then I expect an identity to be returned",
      () async {
    // When
    expect(await useCase.execute(param: CommonMocks.message),
        IdentityMocks.privateIdentity);

    // Then
    var configCaptured = verify(identityRepository.getPrivateKey(
      secret: captureAnyNamed('secret'),
    )).captured;
    expect(configCaptured[0], CommonMocks.message);

    var capturedCreate =
        verify(addIdentityUseCase.execute(param: captureAnyNamed('param')))
            .captured
            .first;
    expect(capturedCreate.bjjPublicKey, CommonMocks.publicKey);
  });

  test(
      "Given a private key which is null, when I call execute, then I expect an identifier to be returned",
      () async {
    // When
    expect(await useCase.execute(), IdentityMocks.privateIdentity);

    // Then
    var configCaptured = verify(identityRepository.getPrivateKey(
      secret: captureAnyNamed('secret'),
    )).captured;
    expect(configCaptured[0], null);

    var capturedCreate =
        verify(addIdentityUseCase.execute(param: captureAnyNamed('param')))
            .captured
            .first;
    expect(capturedCreate.bjjPublicKey, CommonMocks.publicKey);
  });

  test(
      "Given a param, when I call execute and an error occurred, then I expect an exception to be thrown",
      () async {
    // Given
    when(identityRepository.getPrivateKey(secret: anyNamed('secret')))
        .thenAnswer((realInvocation) => Future.error(CommonMocks.exception));

    // When
    await expectLater(useCase.execute(param: CommonMocks.message),
        throwsA(CommonMocks.exception));

    // Then
    var configCaptured = verify(identityRepository.getPrivateKey(
      secret: captureAnyNamed('secret'),
    )).captured;
    expect(configCaptured[0], CommonMocks.message);

    verifyNever(addIdentityUseCase.execute(param: captureAnyNamed('param')));
  });
}
