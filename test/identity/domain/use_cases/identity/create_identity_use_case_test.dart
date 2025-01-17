import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/identity_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/private_identity_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/create_identity_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_current_env_did_identifier_use_case.dart';

import '../../../../common/common_mocks.dart';
import 'create_identity_use_case_test.mocks.dart';

// Data
var exception = Exception();
var param = CreateIdentityParam(
  bjjPublicKey: CommonMocks.publicKey,
  profiles: CommonMocks.bigIntValues,
);
var paramNoProfiles = CreateIdentityParam(
  bjjPublicKey: CommonMocks.publicKey,
);
var noProfiles = {BigInt.zero: CommonMocks.did};
var profiles = {BigInt.zero: CommonMocks.did};

IdentityEntity expected = IdentityEntity(
  did: CommonMocks.did,
  publicKey: CommonMocks.publicKey,
  profiles: profiles,
);

IdentityEntity expectedNoProfiles = IdentityEntity(
  did: CommonMocks.did,
  publicKey: CommonMocks.publicKey,
  profiles: noProfiles,
);

// Dependencies
MockGetCurrentEnvDidIdentifierUseCase getCurrentEnvDidIdentifierUseCase =
    MockGetCurrentEnvDidIdentifierUseCase();
MockStacktraceManager stacktraceManager = MockStacktraceManager();

// Tested instance
CreateIdentityUseCase useCase = CreateIdentityUseCase(
  getCurrentEnvDidIdentifierUseCase,
  stacktraceManager,
);

@GenerateMocks([
  GetCurrentEnvDidIdentifierUseCase,
  StacktraceManager,
])
void main() {
  setUp(() {
    reset(getCurrentEnvDidIdentifierUseCase);

    for (BigInt id in CommonMocks.bigIntValues) {
      profiles[id] = CommonMocks.did;
    }

    // Given
    when(getCurrentEnvDidIdentifierUseCase.execute(param: anyNamed('param')))
        .thenAnswer((realInvocation) => Future.value(CommonMocks.did));
  });

  test(
      "Given a param, when I call execute, then I expect an identity to be returned",
      () async {
    // When
    expect(await useCase.execute(param: param), expected);

    var capturedGetDid = verify(getCurrentEnvDidIdentifierUseCase.execute(
            param: captureAnyNamed('param')))
        .captured;
    expect(capturedGetDid.length, CommonMocks.intValues.length + 1);
    expect(capturedGetDid.first.bjjPublicKey, CommonMocks.publicKey);
    expect(capturedGetDid.first.profileNonce, CommonMocks.genesisNonce);

    for (int i = 1; i < CommonMocks.bigIntValues.length + 1; i++) {
      expect(capturedGetDid[i].bjjPublicKey, CommonMocks.publicKey);
      expect(capturedGetDid[i].profileNonce, CommonMocks.bigIntValues[i - 1]);
    }
  });

  test(
      "Given a param without profiles, when I call execute, then I expect an identity to be returned",
      () async {
    // When
    expect(await useCase.execute(param: paramNoProfiles), expectedNoProfiles);

    var capturedGetDid = verify(getCurrentEnvDidIdentifierUseCase.execute(
            param: captureAnyNamed('param')))
        .captured;
    expect(capturedGetDid.length, 1);
    expect(capturedGetDid.first.bjjPublicKey, CommonMocks.publicKey);
    expect(capturedGetDid.first.profileNonce, CommonMocks.genesisNonce);
  });

  test(
      "Given a param, when I call execute and an error occurred, then I expect an exception to be thrown",
      () async {
    // Given
    when(getCurrentEnvDidIdentifierUseCase.execute(param: anyNamed('param')))
        .thenAnswer((realInvocation) => Future.error(CommonMocks.exception));

    // When
    await expectLater(
        useCase.execute(param: param), throwsA(CommonMocks.exception));

    var capturedGetDid = verify(getCurrentEnvDidIdentifierUseCase.execute(
            param: captureAnyNamed('param')))
        .captured;
    expect(capturedGetDid.length, 1);
    expect(capturedGetDid.first.bjjPublicKey, CommonMocks.publicKey);
    expect(capturedGetDid.first.profileNonce, CommonMocks.genesisNonce);
  });
}
