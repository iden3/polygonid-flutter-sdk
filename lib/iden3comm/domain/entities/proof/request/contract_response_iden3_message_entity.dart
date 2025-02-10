/*
{
  "id": "c811849d-6bfb-4d85-936e-3d9759c7f105",
  "typ": "application/iden3comm-plain-json",
  "type": "https://iden3-communication.io/proofs/1.0/contract-invoke-request",
  "body": {
    "transaction_data": {
      "contract_address": "0x516D8DBece16890d0670Dfd3Cb1740FcdF375B10",
      "method_id": "b68967e2",
      "chain_id": 80001,
      "network": "polygon-mumbai"
    },
    "reason": "airdrop participation",
    "scope": [
      {
        "id": 1,
        "circuit_id": "credentialAtomicQueryMTP",
        "rules": {
          "query": {
            "allowed_issuers": [
              "*"
            ],
            "req": {
              "birthday": {
                "$lt": 20000101
              }
            },
            "schema": {
              "url": "https://raw.githubusercontent.com/iden3/claim-schema-vocab/main/schemas/json-ld/kyc-v2.json-ld",
              "type": "KYCAgeCredential"
            }
          }
        }
      }
    ]
  }
}
*/

import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/proof/request/contract_function_call_body_response.dart';

class ContractResponseIden3MessageEntity
    extends Iden3MessageEntity<ContractFunctionCallResponseBody> {
  ContractResponseIden3MessageEntity({
    required super.id,
    String? typ,
    required super.type,
    String? thid,
    required super.body,
    super.nextRequest,
    String? from,
  }) : super(
          messageType: Iden3MessageType.proofContractInvokeResponse,
          thid: thid ?? '',
          typ: typ ?? '',
          from: from ?? '',
        );

  /// Creates an instance from the given json
  ///
  /// @param [Map<String, dynamic>] json
  /// @returns [ContractIden3MessageEntity]
  factory ContractResponseIden3MessageEntity.fromJson(
      Map<String, dynamic> json) {
    final body = ContractFunctionCallResponseBody.fromJson(json['body']);
    return ContractResponseIden3MessageEntity(
      id: json['id'],
      typ: json['typ'] ?? '',
      type: json['type'],
      thid: json['thid'] ?? '',
      body: body,
      nextRequest: json['next_request'],
      from: json['from'] ?? '',
    );
  }

  @override
  String toString() => "[ContractIden3MessageEntity] {${super.toString()}";

  @override
  bool operator ==(Object other) =>
      super == other && other is ContractResponseIden3MessageEntity;

  @override
  int get hashCode => runtimeType.hashCode;
}
