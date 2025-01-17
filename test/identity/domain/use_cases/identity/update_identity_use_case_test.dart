import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/identity_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/exceptions/identity_exceptions.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/create_identity_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/get_identity_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/update_identity_use_case.dart';

import '../../../../common/common_mocks.dart';
import '../../../../common/identity_mocks.dart';
import 'update_identity_use_case_test.mocks.dart';

// Data
var exception = Exception();
var param = UpdateIdentityParam(
  encryptionKey: CommonMocks.encryptionKey,
  genesisDid: CommonMocks.did,
  profiles: CommonMocks.profiles,
);

// Dependencies
MockIdentityRepository identityRepository = MockIdentityRepository();
MockCreateIdentityUseCase createIdentityUseCase = MockCreateIdentityUseCase();
MockGetIdentityUseCase getIdentityUseCase = MockGetIdentityUseCase();

// Tested instance
UpdateIdentityUseCase useCase = UpdateIdentityUseCase(
  identityRepository,
  getIdentityUseCase,
);

@GenerateMocks([
  IdentityRepository,
  CreateIdentityUseCase,
  GetIdentityUseCase,
])
void main() {
  setUp(() {
    reset(identityRepository);
    reset(createIdentityUseCase);
    reset(getIdentityUseCase);

    // Given
    when(getIdentityUseCase.execute(param: anyNamed('param'))).thenAnswer(
        (realInvocation) => Future.value(IdentityMocks.privateIdentity));
    when(identityRepository.storeIdentity(identity: anyNamed('identity')))
        .thenAnswer((realInvocation) => Future.value());
  });

  test(
      "Given a param with a valid private key, when I call execute, then I expect an updated PrivateIdentityEntity to be returned",
      () async {
    // When
    IdentityEntity result = await useCase.execute(param: param);

    // Then
    expect(result, IdentityMocks.privateIdentity);

    var capturedGet =
        verify(getIdentityUseCase.execute(param: captureAnyNamed('param')))
            .captured
            .first;
    expect(capturedGet.encryptionKey, param.encryptionKey);
    expect(capturedGet.genesisDid, param.genesisDid);

    var capturedStore = verify(identityRepository.storeIdentity(
            identity: captureAnyNamed('identity')))
        .captured;
    expect(capturedStore[0], IdentityMocks.privateIdentity);
  });

  test(
      "Given a param with an invalid private key, when I call execute, then I expect an InvalidPrivateKeyException to be thrown",
      () async {
    // Given
    when(getIdentityUseCase.execute(param: anyNamed('param')))
        .thenAnswer((realInvocation) => Future.value(IdentityMocks.identity));

    // When
    await useCase.execute(param: param).then((_) => null).catchError((error) {
      expect(error, isA<InvalidPrivateKeyException>());
      expect(error.encryptionKey, param.encryptionKey);
    });

    // Then
    var capturedGet =
        verify(getIdentityUseCase.execute(param: captureAnyNamed('param')))
            .captured
            .first;
    expect(capturedGet.encryptionKey, param.encryptionKey);
    expect(capturedGet.genesisDid, param.genesisDid);

    verifyNever(identityRepository.storeIdentity(
        identity: captureAnyNamed('identity')));
  });

  test(
      "Given a param, when I call execute and an error occurred, then I expect an exception to be thrown",
      () async {
    // Given
    when(getIdentityUseCase.execute(param: anyNamed('param')))
        .thenAnswer((realInvocation) => Future.error(exception));

    // When
    await expectLater(useCase.execute(param: param), throwsA(exception));

    // Then
    var capturedGet =
        verify(getIdentityUseCase.execute(param: captureAnyNamed('param')))
            .captured
            .first;
    expect(capturedGet.encryptionKey, param.encryptionKey);
    expect(capturedGet.genesisDid, param.genesisDid);

    verifyNever(identityRepository.storeIdentity(
        identity: captureAnyNamed('identity')));
  });
}
