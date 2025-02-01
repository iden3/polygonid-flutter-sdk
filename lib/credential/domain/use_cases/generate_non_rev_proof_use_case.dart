import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/credential/domain/repositories/credential_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/fetch_identity_state_use_case.dart';

class GenerateNonRevProofParam {
  final ClaimEntity claim;
  final Map<String, dynamic>? nonRevProof;

  GenerateNonRevProofParam({
    required this.claim,
    this.nonRevProof,
  });
}

class GenerateNonRevProofUseCase
    extends FutureUseCase<GenerateNonRevProofParam, Map<String, dynamic>> {
  final IdentityRepository _identityRepository;
  final CredentialRepository _credentialRepository;
  final FetchIdentityStateUseCase _fetchIdentityStateUseCase;
  final StacktraceManager _stacktraceManager;

  GenerateNonRevProofUseCase(
    this._identityRepository,
    this._credentialRepository,
    this._fetchIdentityStateUseCase,
    this._stacktraceManager,
  );

  @override
  Future<Map<String, dynamic>> execute({
    required GenerateNonRevProofParam param,
  }) async {
    try {
      final issuerId =
          await _credentialRepository.getIssuerIdentifier(claim: param.claim);
      final identityState =
          await _fetchIdentityStateUseCase.execute(param: issuerId);

      final existingNonRevProof = param.nonRevProof;
      if (existingNonRevProof != null &&
          existingNonRevProof.isNotEmpty &&
          identityState == existingNonRevProof["issuer"]["state"]) {
        _stacktraceManager
            .addTrace("[GenerateNonRevProofUseCase] Non rev proof");
        return param.nonRevProof!;
      }

      final nonceAndUrl = await Future.wait<dynamic>([
        _credentialRepository.getRevocationNonce(claim: param.claim, rhs: true),
        _credentialRepository.getRevocationUrl(claim: param.claim, rhs: true),
      ]);
      final nonce = BigInt.from(nonceAndUrl[0]);
      final baseUrl = nonceAndUrl[1] as String;

      final nonRevProof = await _identityRepository.getNonRevProof(
        identityState: identityState,
        nonce: nonce,
        baseUrl: baseUrl,
        cachedNonRevProof: param.nonRevProof,
      );

      _stacktraceManager.addTrace("[GenerateNonRevProofUseCase] Non rev proof");
      logger().i("[GenerateNonRevProofUseCase] Non rev proof: $nonRevProof");

      return nonRevProof;
    } catch (error) {
      _stacktraceManager.addTrace("[GenerateNonRevProofUseCase] Error: $error");
      logger().e("[GenerateNonRevProofUseCase] Error: $error");
      _stacktraceManager.addError("[GenerateNonRevProofUseCase] Error: $error");
      rethrow;
    }
  }
}
