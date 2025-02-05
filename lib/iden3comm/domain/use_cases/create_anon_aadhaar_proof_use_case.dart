import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_cases/get_env_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/self_issuance/self_issued_credential_params.dart';
import 'package:polygonid_flutter_sdk/proof/data/data_sources/lib_pidcore_proof_data_source.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/atomic_query_inputs_param.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/circuit_data_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/zkproof_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/use_cases/prove_use_case.dart';

class CreateAnonAadhaarProofParam {
  final String qrData;
  final String profileDid;
  final SelfIssuedCredentialParams selfIssuedCredentialParams;
  final CircuitDataEntity? circuitData;

  CreateAnonAadhaarProofParam({
    required this.qrData,
    required this.profileDid,
    required this.selfIssuedCredentialParams,
    this.circuitData,
  });
}

class CreateAnonAadhaarProofUseCase
    extends FutureUseCase<CreateAnonAadhaarProofParam, ZKProofEntity> {
  final GetEnvUseCase _getEnvUseCase;
  final LibPolygonIdCoreWrapper _libPolygonIdCoreWrapper;
  final ProveUseCase _proveUseCase;

  CreateAnonAadhaarProofUseCase(this._getEnvUseCase,
      this._libPolygonIdCoreWrapper,
      this._proveUseCase,);

  @override
  Future<ZKProofEntity> execute({
    required CreateAnonAadhaarProofParam param,
  }) async {
    final env = await _getEnvUseCase.execute();

    final anonAadhaarInputs = AnonAadhaarInputsParam
        .fromSelfIssuedCredentialParams(
      qrData: param.qrData,
      credentialSubjectID: param.profileDid,
      params: param.selfIssuedCredentialParams,
    );



    final generateInputsResult = await _libPolygonIdCoreWrapper.getProofInputs(
      anonAadhaarInputs,
      env.config,
    );

    final atomicQueryInputs = json.encode(generateInputsResult.inputs);

    final circuitId = param.circuitData?.circuitId ?? 'anonAadhaarV1';
    final witnessCalculationData = await _tryGetWitnessCalculationData(
        circuitId: circuitId);
    final zKeyPath = await _tryGetZKeyPath(circuitId: circuitId);

    final proof = await _proveUseCase.execute(
      param: ProveParam(
        atomicQueryInputs,
        CircuitDataEntity(
          circuitId,
          witnessCalculationData,
          zKeyPath,
        ),
      ),
    );

    return proof;
  }

  Future<Uint8List> _tryGetWitnessCalculationData({
    required String circuitId,
  }) async {
    final directory = await getApplicationDocumentsDirectory();

    final wcdFile = File('${directory.path}/$circuitId.wcd');

    if (await wcdFile.exists()) {
      return await wcdFile.readAsBytes();
    } else {
      throw Exception(
          'Witness calculation data file not found for circuit $circuitId at ${wcdFile
              .path}');
    }
  }

  Future<String> _tryGetZKeyPath({required String circuitId}) async {
    final directory = await getApplicationDocumentsDirectory();

    final zkeyFile = File('${directory.path}/$circuitId.zkey');

    if (await zkeyFile.exists()) {
      return zkeyFile.path;
    } else {
      throw Exception(
          'Circuit zkey file not found for circuit $circuitId at ${zkeyFile
              .path}');
    }
  }
}
