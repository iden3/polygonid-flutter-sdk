import 'dart:convert';
import 'dart:typed_data';

import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/common/utils/uint8_list_utils.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/circuit_data_entity.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/gist_mtproof_entity.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/mtproof_dto.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/zkproof_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/repositories/proof_repository.dart';
import 'package:polygonid_flutter_sdk/proof/domain/use_cases/prove_use_case.dart';

class GenerateZKProofParam {
  final String identifier;
  final BigInt profileNonce;
  final BigInt claimSubjectProfileNonce;
  final ClaimEntity credential;
  final CircuitDataEntity circuitData;
  final List<String>? authClaim;
  final MTProofEntity? incProof;
  final MTProofEntity? nonRevProof;
  final GistMTProofEntity? gistProof;
  final Map<String, dynamic>? treeState;
  final String? challenge;
  final String? signature;
  final Map<String, dynamic> proofScopeRequest;
  final Map<String, dynamic>? config;

  final String? verifierId;
  final String? linkNonce;

  final Map<String, dynamic>? transactionData;

  GenerateZKProofParam(
    this.identifier,
    this.profileNonce,
    this.claimSubjectProfileNonce,
    this.credential,
    this.circuitData,
    this.authClaim,
    this.incProof,
    this.nonRevProof,
    this.gistProof,
    this.treeState,
    this.challenge,
    this.signature,
    this.proofScopeRequest,
    this.config,
    this.verifierId,
    this.linkNonce,
    this.transactionData,
  );
}

class GenerateZKProofUseCase
    extends FutureUseCase<GenerateZKProofParam, ZKProofEntity> {
  final ProofRepository _proofRepository;
  final ProveUseCase _proveUseCase;
  final StacktraceManager _stacktraceManager;

  GenerateZKProofUseCase(
    this._proofRepository,
    this._proveUseCase,
    this._stacktraceManager,
  );

  @override
  Future<ZKProofEntity> execute({required GenerateZKProofParam param}) async {
    // Prepare atomic query inputs
    Uint8List res = await _proofRepository
        .calculateAtomicQueryInputs(
      id: param.identifier,
      profileNonce: param.profileNonce,
      claimSubjectProfileNonce: param.claimSubjectProfileNonce,
      authClaim: param.authClaim,
      incProof: param.incProof,
      nonRevProof: param.nonRevProof,
      gistProof: param.gistProof,
      treeState: param.treeState,
      challenge: param.challenge,
      signature: param.signature,
      claim: param.credential,
      proofScopeRequest: param.proofScopeRequest,
      circuitId: param.circuitData.circuitId,
      config: param.config,
      verifierId: param.verifierId,
      linkNonce: param.linkNonce,
      scopeParams: param.proofScopeRequest.containsKey('params')
          ? param.proofScopeRequest['params']
          : null,
      transactionData: param.transactionData,
    )
        .catchError((error) {
      logger().e("[GenerateZKProofUseCase] Error: $error");
      _stacktraceManager.addTrace("[GenerateZKProofUseCase] Error: $error");
      _stacktraceManager.addError("[GenerateZKProofUseCase] Error: $error");

      throw error;
    });

    dynamic inputsJson = json.decode(Uint8ArrayUtils.uint8ListToString(res));
    final atomicQueryInputs = json.encode(inputsJson["inputs"]);

    // Prove
    return _proveUseCase
        .execute(param: ProveParam(atomicQueryInputs, param.circuitData))
        .then((proof) {
      logger().i("[GenerateZKProofUseCase] proof: $proof");
      _stacktraceManager.addTrace("[GenerateZKProofUseCase] proof");

      return proof;
    }).catchError((error) {
      _stacktraceManager.addTrace("[GenerateZKProofUseCase] Error: $error");
      _stacktraceManager.addError("[GenerateZKProofUseCase] Error: $error");
      logger().e("[GenerateZKProofUseCase] Error: $error");

      throw error;
    });
  }
}
