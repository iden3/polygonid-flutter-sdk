import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/hash_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/node_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/tree_state_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/smt_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_identity_auth_claim_use_case.dart';

/// Get the genesis state of the tree, [param] - baby jub jub public key.
class GetGenesisStateUseCase
    extends FutureUseCase<List<String>, TreeStateEntity> {
  final IdentityRepository _identityRepository;
  final SMTRepository _smtRepository;
  final GetAuthClaimUseCase _getIdentityAuthClaimUseCase;
  final StacktraceManager _stacktraceManager;

  GetGenesisStateUseCase(
    this._identityRepository,
    this._smtRepository,
    this._getIdentityAuthClaimUseCase,
    this._stacktraceManager,
  );

  @override
  Future<TreeStateEntity> execute({required List<String> param}) {
    return Future(() async {
      final authClaim = await _getIdentityAuthClaimUseCase.execute(
        param: param,
      );
      final NodeEntity node = await _identityRepository.getAuthClaimNode(
        children: authClaim,
      );
      final String hash = await _smtRepository.hashState(
        claims: node.hash.string(),
        revocation: BigInt.zero.toString(),
        roots: BigInt.zero.toString(),
      );
      final state = TreeStateEntity(
        hash,
        node.hash,
        HashEntity.zero(),
        HashEntity.zero(),
      );
      _stacktraceManager.addTrace("[GetGenesisStateUseCase] State");
      logger().d("[GetGenesisStateUseCase] State: $state");

      return state;
    }).catchError((error) {
      _stacktraceManager.addTrace("[GetGenesisStateUseCase] Error: $error");
      _stacktraceManager.addError("[GetGenesisStateUseCase] Error: $error");
      logger().e("[GetGenesisStateUseCase] Error: $error");

      throw error;
    });
  }
}
