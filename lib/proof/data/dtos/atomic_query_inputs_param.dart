import 'package:polygonid_flutter_sdk/common/utils/format_utils.dart';
import 'package:polygonid_flutter_sdk/credential/data/dtos/claim_info_dto.dart';
import 'package:polygonid_flutter_sdk/identity/data/dtos/circuit_type.dart';

class AtomicQueryInputsParam {
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

  AtomicQueryInputsParam({
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
