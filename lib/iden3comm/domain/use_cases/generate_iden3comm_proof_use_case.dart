import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/env_config_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/error_exception.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/request/proof_scope_request.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/proof/response/iden3comm_proof_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/proof/response/iden3comm_sd_proof_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/proof/response/iden3comm_vp_proof.dart';
import 'package:polygonid_flutter_sdk/identity/data/dtos/circuit_type.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/node_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/did_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/identity_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/tree_type.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/smt_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_did_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_identity_auth_claim_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_latest_state_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/get_identity_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/sign_message_use_case.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/circuit_data_entity.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/gist_mtproof_entity.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/mtproof_dto.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/zkproof_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/exceptions/proof_generation_exceptions.dart';
import 'package:polygonid_flutter_sdk/proof/domain/repositories/proof_repository.dart';
import 'package:polygonid_flutter_sdk/proof/domain/use_cases/get_gist_mtproof_use_case.dart';
import 'package:polygonid_flutter_sdk/proof/domain/use_cases/prove_use_case.dart';

class GenerateIden3commProofParam {
  final String did;
  final BigInt profileNonce;
  final BigInt claimSubjectProfileNonce;
  final ClaimEntity credential;
  final ProofScopeRequest request;
  final CircuitDataEntity circuitData;

  /// FIXME: remove nullables
  final String? privateKey;
  final String? challenge;

  final EnvConfigEntity? config;

  final String? verifierId;
  final String? linkNonce;

  final Map<String, dynamic>? transactionData;

  GenerateIden3commProofParam({
    required this.did,
    required this.profileNonce,
    required this.claimSubjectProfileNonce,
    required this.credential,
    required this.request,
    required this.circuitData,
    this.privateKey,
    this.challenge,
    this.config,
    this.verifierId,
    this.linkNonce,
    this.transactionData,
  });
}

class GenerateIden3commProofUseCase
    extends FutureUseCase<GenerateIden3commProofParam, Iden3commProofEntity> {
  final IdentityRepository _identityRepository;
  final SMTRepository _smtRepository;
  final ProofRepository _proofRepository;
  final ProveUseCase _proveUseCase;
  final GetIdentityUseCase _getIdentityUseCase;
  final GetAuthClaimUseCase _getAuthClaimUseCase;
  final GetGistMTProofUseCase _getGistMTProofUseCase;
  final GetDidUseCase _getDidUseCase;
  final SignMessageUseCase _signMessageUseCase;
  final GetLatestStateUseCase _getLatestStateUseCase;
  final StacktraceManager _stacktraceManager;

  GenerateIden3commProofUseCase(
    this._identityRepository,
    this._smtRepository,
    this._proofRepository,
    this._proveUseCase,
    this._getIdentityUseCase,
    this._getAuthClaimUseCase,
    this._getGistMTProofUseCase,
    this._getDidUseCase,
    this._signMessageUseCase,
    this._getLatestStateUseCase,
    this._stacktraceManager,
  );

  @override
  Future<Iden3commProofEntity> execute({
    required GenerateIden3commProofParam param,
  }) async {
    final encryptionKey = param.privateKey;

    List<String>? authClaim;
    MTProofEntity? incProof;
    MTProofEntity? nonRevProof;
    GistMTProofEntity? gistProof;
    Map<String, dynamic>? treeState;
    Map<String, dynamic>? config;
    String? signature;

    logger().i("[GenerateIden3commProofUseCase] claim:");
    logger().i(param.credential.toJson());

    Stopwatch stopwatch = Stopwatch()..start();

    final circuitId = param.request.circuitId;

    // TODO (moria): remove this with v3 circuit release
    if (circuitId.startsWith(CircuitType.v3CircuitPrefix) &&
        !circuitId.endsWith(CircuitType.currentCircuitBetaPostfix)) {
      _stacktraceManager.addTrace(
          "V3 circuit beta version mismatch $circuitId is not supported, current is ${CircuitType.currentCircuitBetaPostfix}");
      _stacktraceManager.addError(
          "V3 circuit beta version mismatch $circuitId is not supported, current is ${CircuitType.currentCircuitBetaPostfix}");
      throw CircuitNotDownloadedException(
          circuit: circuitId,
          errorMessage:
              "V3 circuit beta version mismatch $circuitId is not supported, current is ${CircuitType.currentCircuitBetaPostfix}");
    }

    if (circuitId == CircuitType.mtponchain.name ||
        circuitId == CircuitType.sigonchain.name ||
        circuitId == CircuitType.circuitsV3onchain.name) {
      //on chain start
      _stacktraceManager.addTrace(
          "[GenerateIden3commProofUseCase] OnChain ${param.request.circuitId}");

      IdentityEntity identity = await _getIdentityUseCase.execute(
        param: GetIdentityParam(
          genesisDid: param.did,
          privateKey: param.privateKey,
        ),
      );
      _stacktraceManager.addTrace(
          "[GenerateIden3commProofUseCase] identity: ${identity.did}");
      logger().i(
          "GENERATION PROOF getIdentityUseCase executed in ${stopwatch.elapsed}");

      authClaim = await _getAuthClaimUseCase.execute(
        param: identity.publicKey,
      );
      logger().i(
          "GENERATION PROOF getAuthClaimUseCase executed in ${stopwatch.elapsed}");

      NodeEntity authClaimNode =
          await _identityRepository.getAuthClaimNode(children: authClaim);

      _stacktraceManager
          .addTrace("[GenerateIden3commProofUseCase] authClaimNode");
      logger().i(
          "GENERATION PROOF getAuthClaimNode executed in ${stopwatch.elapsed}");

      incProof = await _smtRepository.generateProof(
        key: authClaimNode.hash,
        type: TreeType.claims,
        did: param.did,
        encryptionKey: encryptionKey!,
      );
      _stacktraceManager.addTrace("[GenerateIden3commProofUseCase] incProof");
      logger().i("GENERATION PROOF incProof executed in ${stopwatch.elapsed}");

      nonRevProof = await _smtRepository.generateProof(
        key: authClaimNode.hash,
        type: TreeType.revocation,
        did: param.did,
        encryptionKey: encryptionKey,
      );
      _stacktraceManager
          .addTrace("[GenerateIden3commProofUseCase] nonRevProof");
      logger()
          .i("GENERATION PROOF nonRevProof executed in ${stopwatch.elapsed}");

      // hash of clatr, revtr, rootr
      treeState = await _getLatestStateUseCase.execute(
        param: GetLatestStateParam(
          did: param.did,
          encryptionKey: param.privateKey!,
        ),
      );
      _stacktraceManager.addTrace("[GenerateIden3commProofUseCase] treeState");
      logger().i("GENERATION PROOF treeState executed in ${stopwatch.elapsed}");

      gistProof = await _getGistMTProofUseCase.execute(param: param.did);
      _stacktraceManager.addTrace("[GenerateIden3commProofUseCase] gistProof");
      logger().i("GENERATION PROOF gistProof executed in ${stopwatch.elapsed}");

      signature = await _signMessageUseCase.execute(
        param: SignMessageParam(
          param.privateKey!,
          param.challenge!,
        ),
      );
      _stacktraceManager.addTrace("[GenerateIden3commProofUseCase] signature");
      //onchain end
      logger().i("GENERATION PROOF signature executed in ${stopwatch.elapsed}");
    }

    final envConfig = param.config;
    if (envConfig != null) {
      config = envConfig.toJson();
      _stacktraceManager.addTrace(
          "[GenerateIden3commProofUseCase] AtomicQueryInputsConfigParam: success");
    }

    DidEntity didEntity = await _getDidUseCase.execute(param: param.did);
    _stacktraceManager.addTrace(
        "[GenerateIden3commProofUseCase] didEntity: ${didEntity.did}");
    logger().i("GENERATION PROOF didEntity executed in ${stopwatch.elapsed}");

    // Prepare atomic query inputs
    final generateInputsResponse = await _proofRepository
        .calculateAtomicQueryInputs(
      id: didEntity.identifier,
      profileNonce: param.profileNonce,
      claimSubjectProfileNonce: param.claimSubjectProfileNonce,
      authClaim: authClaim,
      incProof: incProof,
      nonRevProof: nonRevProof,
      gistProof: gistProof,
      treeState: treeState,
      challenge: param.challenge,
      signature: signature,
      claim: param.credential,
      proofScopeRequest: param.request.toJson(),
      circuitId: param.request.circuitId,
      config: config,
      verifierId: param.verifierId,
      linkNonce: param.linkNonce,
      scopeParams: param.request.params,
      transactionData: param.transactionData,
    )
        .catchError((error) {
      _stacktraceManager
          .addTrace("[GenerateIden3commProofUseCase] Error: $error");
      logger().e("[GenerateProofUseCase] Error: $error");

      throw error;
    });
    _stacktraceManager
        .addTrace("[GenerateIden3commProofUseCase] atomicQueryInputs: success");
    logger().i(
        "GENERATION PROOF calculateAtomicQueryInputs executed in ${stopwatch.elapsed}");

    final inputs = json.encode(generateInputsResponse.inputs);

    if (kDebugMode) {
      //just for debug
      logger().i('[GenerateIden3commProofUseCase] inputs: $inputs');
    }

    Iden3commVPProof? vpProof;
    final verifiablePresentation =
        generateInputsResponse.verifiablePresentation;
    if (verifiablePresentation != null) {
      vpProof = Iden3commVPProof.fromJson(verifiablePresentation);
    }

    logger().i('[GenerateIden3commProofUseCase] verifiablePresentation:');
    logger().i(vpProof ?? generateInputsResponse.verifiablePresentation);

    logger().i(
        "GENERATION PROOF atomicQueryInputs executed in ${stopwatch.elapsed}");

    try {
      ZKProofEntity proof = await _proveUseCase.execute(
        param: ProveParam(inputs, param.circuitData),
      );
      if (vpProof != null) {
        return Iden3commSDProofEntity(
          id: param.request.id,
          circuitId: param.circuitData.circuitId,
          proof: proof.proof,
          pubSignals: proof.pubSignals,
          publicStatesInfo: generateInputsResponse.publicStatesInfo,
          vp: vpProof,
        );
      } else {
        return Iden3commProofEntity(
          id: param.request.id,
          circuitId: param.circuitData.circuitId,
          proof: proof.proof,
          pubSignals: proof.pubSignals,
          publicStatesInfo: generateInputsResponse.publicStatesInfo,
        );
      }
    } on PolygonIdSDKException catch (_) {
      rethrow;
    } catch (error) {
      _stacktraceManager.addTrace(
          "[GenerateIden3commProofUseCase] proveUseCase Error: $error");
      logger().e("[GenerateProofUseCase] Error: $error");
      _stacktraceManager.addError(
          "[GenerateIden3commProofUseCase] proveUseCase Error: $error");
      throw ProofGenerationException(
        errorMessage: "Error while generating proof with error: $error",
        error: error,
      );
    }
  }
}
