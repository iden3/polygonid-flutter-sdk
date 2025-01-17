import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/check_profile_and_did_current_env.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/get_identity_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/profile/get_profiles_use_case.dart';

import '../../../../common/common_mocks.dart';
import '../../../../common/identity_mocks.dart';
import 'get_profiles_use_case_test.mocks.dart';

MockGetIdentityUseCase getIdentityUseCase = MockGetIdentityUseCase();
MockCheckProfileAndDidCurrentEnvUseCase checkProfileAndDidCurrentEnvUseCase =
    MockCheckProfileAndDidCurrentEnvUseCase();
MockStacktraceManager stacktraceManager = MockStacktraceManager();

// Data
GetProfilesParam param = GetProfilesParam(
    genesisDid: CommonMocks.did, privateKey: CommonMocks.privateKey);

GetProfilesUseCase useCase = GetProfilesUseCase(
  getIdentityUseCase,
  checkProfileAndDidCurrentEnvUseCase,
  stacktraceManager,
);

@GenerateMocks([
  GetIdentityUseCase,
  CheckProfileAndDidCurrentEnvUseCase,
  StacktraceManager,
])
void main() {
  setUp(() {
    reset(getIdentityUseCase);

    // Given
    when(getIdentityUseCase.execute(param: anyNamed('param')))
        .thenAnswer((realInvocation) => Future.value(IdentityMocks.identity));
    when(checkProfileAndDidCurrentEnvUseCase.execute(param: anyNamed('param')))
        .thenAnswer((realInvocation) => Future.value(null));
  });

  test(
    'Given a param, when I call execute, then I expect an Map<int, String> to be returned',
    () async {
      // When
      expect(await useCase.execute(param: param), CommonMocks.profiles);

      // Then
      var getIdentityCapture =
          verify(getIdentityUseCase.execute(param: captureAnyNamed('param')))
              .captured;
      expect(getIdentityCapture.first.genesisDid, CommonMocks.did);
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
      var getIdentityCapture =
          verify(getIdentityUseCase.execute(param: captureAnyNamed('param')))
              .captured;
      expect(getIdentityCapture.first.genesisDid, CommonMocks.did);
    },
  );
}
