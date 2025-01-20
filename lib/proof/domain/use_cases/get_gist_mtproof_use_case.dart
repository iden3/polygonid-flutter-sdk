import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/chain_config_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_cases/get_selected_chain_use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_did_use_case.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/gist_mtproof_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/repositories/proof_repository.dart';

class GetGistMTProofUseCase extends FutureUseCase<String, GistMTProofEntity> {
  final ProofRepository _proofRepository;
  final IdentityRepository _identityRepository;
  final GetSelectedChainUseCase _getSelectedChainUseCase;
  final GetDidUseCase _getDidUseCase;
  final StacktraceManager _stacktraceManager;

  GetGistMTProofUseCase(
    this._proofRepository,
    this._identityRepository,
    this._getSelectedChainUseCase,
    this._getDidUseCase,
    this._stacktraceManager,
  );

  @override
  Future<GistMTProofEntity> execute({required String param}) async {
    try {
      final selectedChain = await _getSelectedChainUseCase.execute();
      final did = await _getDidUseCase.execute(param: param);
      final idAsInt =
          await _identityRepository.convertIdToBigInt(id: did.identifier);

      final proof = await _proofRepository.getGistProof(
        idAsInt: idAsInt,
        contractAddress: selectedChain.stateContractAddr,
      );

      _stacktraceManager
          .addTrace("[GetGistMTProofUseCase] Gist proof for identifier $param");
      logger()
          .i("[GetGistMTProofUseCase] Gist proof $proof for identifier $param");

      return proof;
    } catch (error) {
      _stacktraceManager.addTrace(
          "[GetGistMTProofUseCase] Error: $error for identifier $param");
      _stacktraceManager.addError(
          "[GetGistMTProofUseCase] Error: $error for identifier $param");
      logger().e("[GetGistMTProofUseCase] Error: $error");

      rethrow;
    }
  }
}
