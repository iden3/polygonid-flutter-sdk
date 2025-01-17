import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/get_identities_use_case.dart';

import '../../../../common/common_mocks.dart';
import '../../../../common/identity_mocks.dart';
import 'get_identities_use_case_test.mocks.dart';

MockIdentityRepository identityRepository = MockIdentityRepository();
MockStacktraceManager stacktraceManager = MockStacktraceManager();

GetIdentitiesUseCase useCase = GetIdentitiesUseCase(
  identityRepository,
  stacktraceManager,
);

@GenerateMocks([
  IdentityRepository,
  StacktraceManager,
])
void main() {
  setUp(() {
    reset(identityRepository);

    // Given
    when(identityRepository.getIdentities()).thenAnswer(
        (realInvocation) => Future.value(IdentityMocks.privateIdentityList));
  });

  test(
    'Given a param, when I call execute, then I expect an List of PrivateIdentityEntity to be returned',
    () async {
      // When
      expect(await useCase.execute(), IdentityMocks.privateIdentityList);
    },
  );

  test(
    'Given a param, when I call execute and an error occurred, then I expect an exception to be thrown',
    () async {
      // Given
      when(useCase.execute())
          .thenAnswer((realInvocation) => Future.error(CommonMocks.exception));

      // When
      await expectLater(useCase.execute(), throwsA(CommonMocks.exception));
    },
  );
}
