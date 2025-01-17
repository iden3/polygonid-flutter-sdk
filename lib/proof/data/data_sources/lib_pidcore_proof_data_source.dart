import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/env_config_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/error_exception.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/credential/data/dtos/claim_info_dto.dart';
import 'package:polygonid_flutter_sdk/identity/data/dtos/circuit_type.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/atomic_query_inputs_param.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/generate_inputs_response.dart';
import 'package:polygonid_flutter_sdk/proof/domain/exceptions/proof_generation_exceptions.dart';
import 'package:polygonid_flutter_sdk/proof/libs/polygonidcore/pidcore_proof.dart';

class LibPolygonIdCoreProofDataSource {
  final LibPolygonIdCoreWrapper _libPolygonIdCoreWrapper;
  final StacktraceManager _stacktraceManager;

  LibPolygonIdCoreProofDataSource(
    this._libPolygonIdCoreWrapper,
    this._stacktraceManager,
  );

  String proofFromSC(String input) {
    /*{
      "root":
          "17039823904837071705763545555283546217751326723169195059364451777353741017328",
      "siblings": [
        "14989532119404983961115670288381063073891118401716735992353404523801340288158",
        "15817549995119513546413395894800310537308858548528902759332598606866792105384",
        "20955911300871905860419417343337237575819647673394656670247178513070221579793",
        "7345857457589225232320640926291449425076936633178262764678572453063445218154",
        "13941064550735375985967548290421702932981128763694428458881182266843384273940",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0",
        "0"
      ],
      "oldKey": "10",
      "oldValue": "20",
      "isOld0": false,
      "key":
          "13625694351531357880063798347796487002182037278253017013343168668336623401886",
      "value": "0",
      "fnc": "1"
    }*/

    String output = _libPolygonIdCoreWrapper.proofFromSmartContract(input);
    logger().d("proofFromSmartContract: $output");
    //{"root":"17039823904837071705763545555283546217751326723169195059364451777353741017328","proof":{"existence":false,"siblings":["14989532119404983961115670288381063073891118401716735992353404523801340288158","15817549995119513546413395894800310537308858548528902759332598606866792105384","20955911300871905860419417343337237575819647673394656670247178513070221579793","7345857457589225232320640926291449425076936633178262764678572453063445218154","13941064550735375985967548290421702932981128763694428458881182266843384273940","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0"],"node_aux":{"key":"10","value":"20"}}}
    return output;
  }

  Future<GenerateInputsResponse> getAuthInputs({
    required String genesisDid,
    required BigInt profileNonce,
    required List<String> authClaim,
    required Map<String, dynamic> incProof,
    required Map<String, dynamic> nonRevProof,
    required Map<String, dynamic> gistProof,
    required Map<String, dynamic> treeState,
    required String challenge,
    required String signature,
    Map<String, dynamic>? config,
  }) async {
    final input = AuthAtomicQueryInputsParam(
      genesisDid: genesisDid,
      profileNonce: profileNonce,
      authClaim: authClaim,
      incProof: incProof,
      nonRevProof: nonRevProof,
      treeState: treeState,
      gistProof: gistProof,
      signature: signature,
      challenge: challenge,
    );

    EnvConfigEntity? configParam;
    if (config != null) {
      configParam = EnvConfigEntity.fromJson(config);

      logger().i(
          "[LibPolygonIdCoreProofDataSource][MainFlow]getProofInputs config param: ${jsonEncode(configParam.toJson())}");
      _stacktraceManager.addTrace(
          "[LibPolygonIdCoreProofDataSource][MainFlow]getProofInputs config param: ${jsonEncode(configParam.toJson())}");
    }

    final result =
        await _libPolygonIdCoreWrapper.getProofInputs(input, configParam);

    return result;
  }

  Future<GenerateInputsResponse> getProofInputs({
    required String id,
    required BigInt profileNonce,
    required BigInt claimSubjectProfileNonce,
    List<String>? authClaim,
    Map<String, dynamic>? incProof,
    Map<String, dynamic>? nonRevProof,
    Map<String, dynamic>? treeState,
    Map<String, dynamic>? gistProof,
    String? challenge,
    String? signature,
    required ClaimInfoDTO credential,
    required Map<String, dynamic> request,
    required String circuitId,
    Map<String, dynamic>? config,
    String? verifierId,
    String? linkNonce,
    Map<String, dynamic>? scopeParams,
    Map<String, dynamic>? transactionData,
  }) async {
    if (request.isEmpty || request.containsKey("circuitId")) {
      request["circuitId"] = circuitId;
    }

    final inputParam = GenericAtomicQueryInputsParam(
      type: CircuitType.fromString(circuitId),
      id: id,
      profileNonce: profileNonce,
      claimSubjectProfileNonce: claimSubjectProfileNonce,
      authClaim: authClaim,
      incProof: incProof,
      nonRevProof: nonRevProof,
      treeState: treeState,
      gistProof: gistProof,
      challenge: challenge,
      signature: signature,
      credential: credential,
      request: request,
      verifierId: verifierId,
      linkNonce: linkNonce,
      params: scopeParams,
      transactionData: transactionData,
    );

    logger().i(
        "[LibPolygonIdCoreProofDataSource][MainFlow]getProofInputs input param: ${jsonEncode(inputParam.toJson())}");
    _stacktraceManager.addTrace(
        "[LibPolygonIdCoreProofDataSource][MainFlow]getProofInputs input param: ${jsonEncode(inputParam.toJson())}");

    EnvConfigEntity? configParam;
    if (config != null) {
      configParam = EnvConfigEntity.fromJson(config);

      logger().i(
          "[LibPolygonIdCoreProofDataSource][MainFlow]getProofInputs config param: ${jsonEncode(configParam.toJson())}");
      _stacktraceManager.addTrace(
          "[LibPolygonIdCoreProofDataSource][MainFlow]getProofInputs config param: ${jsonEncode(configParam.toJson())}");
    }

    final result =
        await _libPolygonIdCoreWrapper.getProofInputs(inputParam, configParam);

    return result;
  }
}

@injectable
class LibPolygonIdCoreWrapper {
  final PolygonIdCoreProof _polygonIdCoreProof;

  LibPolygonIdCoreWrapper(
    this._polygonIdCoreProof,
  );

  Future<GenerateInputsResponse> getProofInputs(
    AtomicQueryInputsParam atomicQueryInputsParam,
    EnvConfigEntity? atomicQueryInputsConfigParam,
  ) async {
    try {
      final result = await compute(
        _computeAtomicQueryInputs,
        {
          "id": atomicQueryInputsParam.id,
          "param": atomicQueryInputsParam.toJson(),
          "config": atomicQueryInputsConfigParam?.toJson(),
        },
      );

      return GenerateInputsResponse.fromJson(result);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _computeAtomicQueryInputs(
    Map<String, dynamic> parameters,
  ) {
    try {
      final config = parameters["config"];

      final result = _polygonIdCoreProof.generateInputs(
        jsonEncode(parameters["param"]),
        config != null ? jsonEncode(parameters["config"]) : null,
      );

      return Future.value(result.toJson());
    } on PolygonIdSDKException catch (_) {
      rethrow;
    } catch (error) {
      throw NullAtomicQueryInputsException(
        id: parameters["id"],
        errorMessage: "Error in _computeAtomicQueryInputs: $error",
      );
    }
  }

  String proofFromSmartContract(String input) {
    return _polygonIdCoreProof.proofFromSmartContract(input);
  }
}
