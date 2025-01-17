import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/credential/domain/repositories/credential_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_identity_auth_claim_use_case.dart';

import '../../../common/common_mocks.dart';
import '../../../common/credential_mocks.dart';
import 'get_identity_auth_claim_use_case_test.mocks.dart';

MockCredentialRepository credentialRepository = MockCredentialRepository();
MockStacktraceManager stacktraceManager = MockStacktraceManager();

GetAuthClaimUseCase useCase = GetAuthClaimUseCase(
  credentialRepository,
  stacktraceManager,
);

@GenerateMocks([
  CredentialRepository,
  StacktraceManager,
])
void main() {
  setUp(() {
    reset(credentialRepository);

    when(credentialRepository.getAuthClaim(publicKey: anyNamed('publicKey')))
        .thenAnswer(
            (realInvocation) => Future.value(CredentialMocks.authClaim));
  });

  test(
    'Given a param, when I call execute, then I expect an list of String to be returned',
    () async {
      // When
      expect(await useCase.execute(param: CommonMocks.publicKey),
          CredentialMocks.authClaim);

      expect(
          verify(credentialRepository.getAuthClaim(
                  publicKey: captureAnyNamed('publicKey')))
              .captured
              .first,
          CommonMocks.publicKey);
    },
  );
}
