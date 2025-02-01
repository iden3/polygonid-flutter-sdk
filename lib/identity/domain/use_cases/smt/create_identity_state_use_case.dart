import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/node_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/tree_type.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/smt_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_identity_auth_claim_use_case.dart';

import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';

class CreateIdentityStateParam {
  final String did;
  final List<String> bjjPublicKey;
  final String encryptionKey;

  CreateIdentityStateParam({
    required this.did,
    required this.bjjPublicKey,
    required this.encryptionKey,
  });
}

class CreateIdentityStateUseCase
    extends FutureUseCase<CreateIdentityStateParam, void> {
  final IdentityRepository _identityRepository;
  final SMTRepository _smtRepository;
  final GetAuthClaimUseCase _getAuthClaimUseCase;
  final StacktraceManager _stacktraceManager;

  CreateIdentityStateUseCase(
    this._identityRepository,
    this._smtRepository,
    this._getAuthClaimUseCase,
    this._stacktraceManager,
  );

  @override
  Future<void> execute({required CreateIdentityStateParam param}) async {
    try {
      await _smtRepository.createSMT(
        maxLevels: 40,
        type: TreeType.claims,
        did: param.did,
        encryptionKey: param.encryptionKey,
      );
      await _smtRepository.createSMT(
        maxLevels: 40,
        type: TreeType.revocation,
        did: param.did,
        encryptionKey: param.encryptionKey,
      );
      await _smtRepository.createSMT(
        maxLevels: 40,
        type: TreeType.roots,
        did: param.did,
        encryptionKey: param.encryptionKey,
      );

      final authClaim = await _getAuthClaimUseCase.execute(
        param: param.bjjPublicKey,
      );
      NodeEntity authClaimNode =
          await _identityRepository.getAuthClaimNode(children: authClaim);
      await _smtRepository.addLeaf(
        leaf: authClaimNode,
        type: TreeType.claims,
        did: param.did,
        encryptionKey: param.encryptionKey,
      );
      _stacktraceManager.addTrace("[CreateIdentityStateUseCase] State created");
      logger().i("[CreateIdentityStateUseCase] State created with: $param");

      return;
    } catch (error) {
      _stacktraceManager.addTrace("[CreateIdentityStateUseCase] Error: $error");
      _stacktraceManager.addError("[CreateIdentityStateUseCase] Error: $error");
      logger().e("[CreateIdentityStateUseCase] Error: $error");
      rethrow;
    }
  }
}
