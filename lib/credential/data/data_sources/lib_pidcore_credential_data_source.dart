import 'dart:convert';

import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/self_issuance/self_issued_credential_params.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/atomic_query_inputs_param.dart';

import '../../libs/polygonidcore/pidcore_credential.dart';

class LibPolygonIdCoreCredentialDataSource {
  final PolygonIdCoreCredential _polygonIdCoreCredential;

  LibPolygonIdCoreCredentialDataSource(
    this._polygonIdCoreCredential,
  );

  /// - schema - schema hash hex string
  /// - nonce - nonce as big int string
  String issueClaim({
    required String schema,
    required String nonce,
    required List<String> publicKey,
    Map<String, dynamic> additionalInputParam = const {},
  }) {
    Map<String, dynamic> inputParam = {
      "schema": schema,
      "nonce": nonce,
      "indexSlotA": publicKey[0],
      "indexSlotB": publicKey[1],
    };

    //merge additionInputParam with inputParam removing duplicates
    Map<String, dynamic> inputMerged = {...inputParam, ...additionalInputParam};

    String input = jsonEncode(inputMerged);

    String output = _polygonIdCoreCredential.createClaim(input);

    logger().d("issueAuthClaim: $output");
    return output;
  }

  bool cacheCredentials(String input, String? config) {
    return _polygonIdCoreCredential.cacheCredentials(input, config);
  }

  String w3cCredentialsFromOnchainHex({
    required String issuerDID,
    required String hexdata,
    required String version,
    String? config,
  }) {
    return _polygonIdCoreCredential.w3cCredentialsFromOnchainHex(
      jsonEncode({
        "issuerDID": issuerDID,
        "hexdata": hexdata,
        "version": version,
      }),
      config,
    );
  }

  String credentialFromAnonAadhaar({
    required String qrData,
    required String did,
    required SelfIssuedCredentialParams selfIssuedCredentialParams,
    String? config,
  }) {
    // This method accepts same inputs as the proof gen inputs calc
    final param = AnonAadhaarInputsParam.fromSelfIssuedCredentialParams(
      qrData: qrData,
      credentialSubjectID: did,
      params: selfIssuedCredentialParams,
    );

    return _polygonIdCoreCredential.createCredentialFromAnonAadhaarInputs(
      jsonEncode(param.toJson()),
      config,
    );
  }
}
