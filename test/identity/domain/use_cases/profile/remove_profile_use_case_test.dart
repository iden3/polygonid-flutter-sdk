import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/remove_all_claims_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/check_profile_and_did_current_env.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_public_keys_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/get_identity_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/update_identity_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/profile/create_profiles_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/profile/remove_profile_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/smt/remove_identity_state_use_case.dart';

import '../../../../common/common_mocks.dart';
import '../../../../common/identity_mocks.dart';
import 'remove_profile_use_case_test.mocks.dart';

MockGetIdentityUseCase getIdentityUseCase = MockGetIdentityUseCase();
MockCreateProfilesUseCase createProfilesUseCase = MockCreateProfilesUseCase();
MockRemoveIdentityStateUseCase removeIdentityStateUseCase =
    MockRemoveIdentityStateUseCase();
MockRemoveAllClaimsUseCase removeAllClaimsUseCase =
    MockRemoveAllClaimsUseCase();
MockUpdateIdentityUseCase updateIdentityUseCase = MockUpdateIdentityUseCase();
MockCheckProfileAndDidCurrentEnvUseCase checkProfileAndDidCurrentEnvUseCase =
    MockCheckProfileAndDidCurrentEnvUseCase();
MockGetPublicKeyUseCase getPublicKeyUseCase = MockGetPublicKeyUseCase();
MockStacktraceManager stacktraceManager = MockStacktraceManager();

RemoveProfileParam param = RemoveProfileParam(
  genesisDid: CommonMocks.did,
  profileNonce: CommonMocks.nonce,
  privateKey: CommonMocks.privateKey,
);

var negativeParam = RemoveProfileParam(
  genesisDid: CommonMocks.did,
  profileNonce: CommonMocks.negativeNonce,
  privateKey: CommonMocks.privateKey,
);

var genesisParam = RemoveProfileParam(
  genesisDid: CommonMocks.did,
  profileNonce: CommonMocks.genesisNonce,
  privateKey: CommonMocks.privateKey,
);

// Tested instance
RemoveProfileUseCase useCase = RemoveProfileUseCase(
  getIdentityUseCase,
  updateIdentityUseCase,
  checkProfileAndDidCurrentEnvUseCase,
  createProfilesUseCase,
  removeIdentityStateUseCase,
  removeAllClaimsUseCase,
  getPublicKeyUseCase,
  stacktraceManager,
);

@GenerateMocks([
  GetIdentityUseCase,
  CreateProfilesUseCase,
  RemoveIdentityStateUseCase,
  RemoveAllClaimsUseCase,
  UpdateIdentityUseCase,
  CheckProfileAndDidCurrentEnvUseCase,
  GetPublicKeyUseCase,
  StacktraceManager,
])
void main() {
  setUp(() {
    reset(getIdentityUseCase);
    reset(createProfilesUseCase);
    reset(removeIdentityStateUseCase);
    reset(removeAllClaimsUseCase);
    reset(updateIdentityUseCase);
    reset(getPublicKeyUseCase);

    // Given
    when(checkProfileAndDidCurrentEnvUseCase.execute(param: anyNamed('param')))
        .thenAnswer((realInvocation) => Future.value(null));
    when(getIdentityUseCase.execute(param: anyNamed('param'))).thenAnswer(
        (realInvocation) => Future.value(IdentityMocks.privateIdentity));
    when(createProfilesUseCase.execute(param: anyNamed('param')))
        .thenAnswer((realInvocation) => Future.value(CommonMocks.profiles));
    when(removeIdentityStateUseCase.execute(param: anyNamed('param')))
        .thenAnswer((realInvocation) => Future.value());
    when(removeAllClaimsUseCase.execute(param: anyNamed('param')))
        .thenAnswer((realInvocation) => Future.value());
    when(updateIdentityUseCase.execute(param: anyNamed('param'))).thenAnswer(
        (realInvocation) => Future.value(IdentityMocks.privateIdentity));
    when(getPublicKeyUseCase.execute(param: anyNamed('param'))).thenAnswer(
        (realInvocation) => Future.value(CommonMocks.publicKey));
  });

  test(
    'Given a param, when I call execute, then I expect no response to be returned',
    () async {
      // When
      expect(await useCase.execute(param: param).then((realInvocation) => null),
          null);

      // Then
      var captureCheck = verify(checkProfileAndDidCurrentEnvUseCase.execute(
              param: captureAnyNamed('param')))
          .captured
          .first;
      expect(captureCheck.did, CommonMocks.did);
      expect(captureCheck.privateKey, CommonMocks.privateKey);
      expect(captureCheck.profileNonce, CommonMocks.genesisNonce);

      var getIdentityCapture =
          verify(getIdentityUseCase.execute(param: captureAnyNamed('param')))
              .captured
              .first;
      expect(getIdentityCapture.genesisDid, CommonMocks.did);

      var capturedUpdate =
          verify(updateIdentityUseCase.execute(param: captureAnyNamed('param')))
              .captured
              .first;
      expect(capturedUpdate.privateKey, CommonMocks.privateKey);
      expect(capturedUpdate.profiles[1], CommonMocks.profiles[1]);
    },
  );

  test(
    'Given a param, when I call execute and an error occurred, then I expect an exception to be thrown',
    () async {
      // Given
      when(getIdentityUseCase.execute(param: anyNamed('param')))
          .thenAnswer((realInvocation) => Future.error(CommonMocks.exception));

      // When
      await expectLater(
          useCase.execute(param: param), throwsA(CommonMocks.exception));

      // Then
      var captureCheck = verify(checkProfileAndDidCurrentEnvUseCase.execute(
              param: captureAnyNamed('param')))
          .captured
          .first;
      expect(captureCheck.did, CommonMocks.did);
      expect(captureCheck.privateKey, CommonMocks.privateKey);
      expect(captureCheck.profileNonce, CommonMocks.genesisNonce);

      var getIdentityCapture =
          verify(getIdentityUseCase.execute(param: captureAnyNamed('param')))
              .captured
              .first;
      expect(getIdentityCapture.genesisDid, CommonMocks.did);

      verifyNever(
          updateIdentityUseCase.execute(param: captureAnyNamed('param')));
    },
  );
}
