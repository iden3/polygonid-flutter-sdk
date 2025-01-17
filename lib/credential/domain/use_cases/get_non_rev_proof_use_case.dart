import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/credential/domain/repositories/credential_repository.dart';

class GetNonRevProofUseCase
    extends FutureUseCase<ClaimEntity, Map<String, dynamic>> {
  final CredentialRepository _credentialRepository;
  final StacktraceManager _stacktraceManager;

  GetNonRevProofUseCase(
    this._credentialRepository,
    this._stacktraceManager,
  );

  @override
  Future<Map<String, dynamic>> execute({required ClaimEntity param}) {
    return _credentialRepository
        .getRevocationStatus(claim: param)
        .then((nonRevProof) {
      logger().i("[GetNonRevProofUseCase] Non rev proof: $nonRevProof");

      return nonRevProof;
    }).catchError((error) {
      logger().e("[GetNonRevProofUseCase] Error: $error");
      _stacktraceManager.addError("[GetNonRevProofUseCase] Error: $error");
      throw error;
    });
  }
}
