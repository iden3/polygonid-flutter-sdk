/*
{
  "type": "https://iden3-communication.io/authorization-response/v1",
  "data": {
    "scope": [
      {
        "type": "zeroknowledge",
        "circuit_id": "auth",
        "pub_signals": [
          "383481829333688262229762912714748186426235428103586432827469388069546950656",
          "12345"
        ],
        "proof_data": {
          "pi_a": [
            "14146277947056297753840642586002829867111675410988595047766001252156753371528",
            "14571022849315211248046007113544986624773029852663683182064313232057584750907",
            "1"
          ],
          "pi_b": [
            [
              "16643510334478363316178974136322830670001098048711963846055396047727066595515",
              "10398230582752448515583571758866992012509398625081722188208617704185602394573"
            ],
            [
              "6754852150473185509183929580585027939167256175425095292505368999953776521762",
              "4988338043999536569468301597030911639875135237017470300699903062776921637682"
            ],
            [
              "1",
              "0"
            ]
          ],
          "pi_c": [
            "17016608018243685488662035612576776697709541343999980909476169114486580874935",
            "1344455328868272682523157740509602348889110849570014394831093852006878298645",
            "1"
          ],
          "protocol": "groth16"
        }
      }
    ]
  }
}

{
  "id": "627a0eb7-2b7b-40aa-aa2b-f201a2b4b709",
  "typ": "application/iden3comm-plain-json",
  "type": "https://iden3-communication.io/authorization/1.0/request",
  "thid": "627a0eb7-2b7b-40aa-aa2b-f201a2b4b709",
  "body": {
    "callbackUrl": "https://verifier-v2.polygonid.me/api/callback?sessionId=590414",
    "reason": "test flow",
    "scope": [
      {
        "id": 1,
        "circuitId": "credentialAtomicQuerySigV2",
        "query": {
          "allowedIssuers": [
            "*"
          ],
          "context": "https://raw.githubusercontent.com/iden3/claim-schema-vocab/main/schemas/json-ld/kyc-v3.json-ld",
          "credentialSubject": {
            "birthday": {
              "$lt": 20000101
            }
          },
          "type": "KYCAgeCredential"
        }
      }
    ]
  },
  "from": "did:polygonid:polygon:mumbai:2qDyy1kEo2AYcP3RT4XGea7BtxsY285szg6yP9SPrs"
}

*/

import 'package:flutter/foundation.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/zkproof_entity.dart';

class ProofScopeResponse {
  final int id;
  final String circuitId;
  final String? txHash;
  final Map<String, dynamic>? verifiablePresentation;
  final ZKProofBaseEntity proof;
  final List<String> publicSignals;

  ProofScopeResponse({
    required this.id,
    required this.circuitId,
    this.txHash,
    this.verifiablePresentation,
    required this.proof,
    required this.publicSignals,
  });

  /// Creates an instance from the given json
  ///
  /// @param [Map<String, dynamic>] json
  /// @returns [ProofScopeResponse]
  factory ProofScopeResponse.fromJson(Map<String, dynamic> json) {
    ZKProofBaseEntity proof = ZKProofBaseEntity.fromJson(json['proof']);

    return ProofScopeResponse(
      id: json['id'],
      circuitId: json['circuitId'],
      verifiablePresentation: json['vp'],
      txHash: json['txHash'],
      proof: proof,
      publicSignals: json['pub_signals'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'circuitId': circuitId,
        if (verifiablePresentation != null) 'vp': verifiablePresentation,
        if (txHash != null) 'txHash': txHash,
        'proof': proof.toJson(),
        'pub_signals': publicSignals,
      }..removeWhere(
          (dynamic key, dynamic value) => key == null || value == null);

  @override
  String toString() =>
      "[ProofScopeRequest] {id: $id, circuitId: $circuitId, txHash: $txHash, vp: $verifiablePresentation, proof: $proof, pub_signals: $publicSignals}";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProofScopeResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          circuitId == other.circuitId &&
          txHash == other.txHash &&
          verifiablePresentation == other.verifiablePresentation &&
          proof == other.proof &&
          listEquals(publicSignals, other.publicSignals);

  @override
  int get hashCode => runtimeType.hashCode;
}
