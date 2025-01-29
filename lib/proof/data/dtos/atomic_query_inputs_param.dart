import 'package:polygonid_flutter_sdk/common/utils/format_utils.dart';
import 'package:polygonid_flutter_sdk/credential/data/dtos/claim_info_dto.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/self_issuance/self_issued_credential_params.dart';
import 'package:polygonid_flutter_sdk/identity/data/dtos/circuit_type.dart';

abstract class AtomicQueryInputsParam {
  String get id;

  Map<String, dynamic> toJson();
}

class AuthAtomicQueryInputsParam extends AtomicQueryInputsParam {
  final String genesisDid;
  final BigInt profileNonce;
  final List<String> authClaim;
  final Map<String, dynamic> incProof;
  final Map<String, dynamic> nonRevProof;
  final Map<String, dynamic> gistProof;
  final Map<String, dynamic> treeState;
  final String challenge;
  final String signature;
  final String circuitId;

  AuthAtomicQueryInputsParam({
    required this.genesisDid,
    required this.profileNonce,
    required this.authClaim,
    required this.incProof,
    required this.nonRevProof,
    required this.gistProof,
    required this.treeState,
    required this.challenge,
    required this.signature,
    this.circuitId = "authV2",
  });

  @override
  String get id => genesisDid;

  @override
  Map<String, dynamic> toJson() {
    return {
      "genesisDID": genesisDid,
      "profileNonce": profileNonce.toString(),
      "authClaim": authClaim,
      "authClaimIncMtp": incProof,
      "authClaimNonRevMtp": nonRevProof,
      "treeState": treeState,
      "gistProof": gistProof,
      "signature": signature,
      "challenge": challenge,
      "request": {
        "circuitId": circuitId,
      },
    };
  }
}

class GenericAtomicQueryInputsParam extends AtomicQueryInputsParam {
  final CircuitType type;
  final String id;
  final BigInt profileNonce;
  final BigInt claimSubjectProfileNonce;
  final List<String>? authClaim;
  final Map<String, dynamic>? incProof;
  final Map<String, dynamic>? nonRevProof;
  final Map<String, dynamic>? gistProof;
  final Map<String, dynamic>? treeState;
  final String? challenge;
  final String? signature;
  final ClaimInfoDTO credential;
  final Map<String, dynamic> request;

  final String? verifierId;
  final String? linkNonce;

  final Map<String, dynamic>? params;

  final Map<String, dynamic>? transactionData;

  GenericAtomicQueryInputsParam({
    required this.type,
    required this.id,
    required this.profileNonce,
    required this.claimSubjectProfileNonce,
    this.authClaim,
    this.incProof,
    this.nonRevProof,
    this.treeState,
    this.gistProof,
    this.challenge,
    this.signature,
    required this.credential,
    required this.request,
    this.verifierId,
    this.linkNonce,
    this.params,
    this.transactionData,
  });

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> inputs = {
      "id": id,
      "profileNonce": profileNonce.toString(),
      "claimSubjectProfileNonce": claimSubjectProfileNonce.toString(),
      "authClaim": authClaim,
      "authClaimIncMtp": incProof,
      "authClaimNonRevMtp": nonRevProof,
      "gistProof": gistProof,
      "treeState": treeState,
      "challenge": challenge,
      "signature": signature,
      "verifiableCredentials": credential.toJson(),
      "request": request,
      "verifierId": verifierId,
      "linkNonce": linkNonce,
      "params": params,
    }..removeWhere((dynamic key, dynamic value) => value == null);

    if (transactionData?.isNotEmpty ?? false) {
      inputs['transactionData'] =
          FormatUtils.convertSnakeCaseToCamelCase(transactionData!);
    }

    if (verifierId?.isEmpty ?? true) {
      inputs.remove('verifierId');
    }

    return inputs;
  }
}

class AnonAadhaarInputsParam extends AtomicQueryInputsParam {
  final String qrData;
  final String credentialSubjectID;
  final int revocationNonce;
  final String credentialStatusID;
  final String issuerDid;
  final String publicKey;
  final int nullifierSeed;
  final int signalHash;

  AnonAadhaarInputsParam({
    required this.qrData,
    required this.credentialSubjectID,
    required this.revocationNonce,
    required this.credentialStatusID,
    required this.issuerDid,
    required this.publicKey,
    required this.nullifierSeed,
    required this.signalHash,
  });

  AnonAadhaarInputsParam.fromSelfIssuedCredentialParams({
    required this.qrData,
    required this.credentialSubjectID,
    required SelfIssuedCredentialParams params,
  })  : revocationNonce = params.revocationNonce,
        credentialStatusID = params.credentialStatusID,
        issuerDid = params.issuerDid,
        publicKey = params.publicKey,
        nullifierSeed = params.nullifierSeed,
        signalHash = params.signalHash;

  @override
  String get id => credentialSubjectID;

  @override
  Map<String, dynamic> toJson() => {
        "qrData": qrData,
        "credentialSubjectID": credentialSubjectID,
        "credentialStatusRevocationNonce": revocationNonce,
        "credentialStatusID": credentialStatusID,
        "issuerID": issuerDid,
        "pubKey": publicKey,
        "nullifierSeed": nullifierSeed,
        "signalHash": signalHash,
        "request": {
          "circuitId": "anonAadhaarV1",
        },
      };
}
