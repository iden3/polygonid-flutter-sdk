import 'dart:convert';

import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/authorization/request/auth_request_iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/request/proof_scope_request.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/response/jwz.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/interaction/interaction_base_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/interaction/interaction_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/request/proof_request_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/credential/response/fetch_iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/credential/request/offer_iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/proof/request/contract_iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/proof/response/iden3comm_proof_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/proof/response/iden3comm_sd_proof_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/proof/response/iden3comm_vp_proof.dart';

import 'common_mocks.dart';
import 'proof_mocks.dart';

class Iden3commMocks {
  /// [ProofScopeRequest]
  static String proofScopeRequestJson = '''
    {
      "id": 1,
      "circuitId": "${CommonMocks.circuitId}",
      "optional": false,
      "query": {
        "allowedIssuers": [
          "*"
        ],
        "context": "https://raw.githubusercontent.com/iden3/claim-schema-vocab/main/schemas/json-ld/kyc-v3.json-ld",
        "type": "KYCAgeCredential",
        "credentialSubject": {
          "birthday": {
            "\$lt": 20000101
          }
        }
      }
    }
  ''';
  static String otherProofScopeRequestJson = '''
    {
      "id": 1,
      "circuitId": "${CommonMocks.circuitId}",
      "optional": false,
      "query": {
        "allowedIssuers": [
          "*"
        ],
        "context": "https://raw.githubusercontent.com/iden3/claim-schema-vocab/main/schemas/json-ld/kyc-v3.json-ld",
        "type": "KYCCountryOfResidenceCredential",
        "credentialSubject": {
          "city": {
            "\$in": [208, 400]
          }
        }
      }
    }
  ''';

  static ProofScopeRequest proofScopeRequest =
      ProofScopeRequest.fromJson(jsonDecode(proofScopeRequestJson));

  static ProofScopeRequest otherProofScopeRequest =
      ProofScopeRequest.fromJson(jsonDecode(otherProofScopeRequestJson));

  /// [AuthIden3MessageEntity]
  static String authRequestBodyJson = '''
  {
  "reason": "test flow",
  "message": "",
  "callbackUrl": "${CommonMocks.url}",
  "scope": [
    $proofScopeRequestJson, $otherProofScopeRequestJson
  ],
  "url": "${CommonMocks.url}",
  "credentials": [
    {
      "id": "27887",
      "description": "Authenticating with iden3"
    }
  ]
}
  ''';

  static String authRequestJson = '''
{
  "id": "4dd6479b-99b6-405c-ba9e-c7b18d251a5e",
  "thid": "4dd6479b-99b6-405c-ba9e-c7b18d251a5e",
  "from": "${CommonMocks.did}",
  "typ": "application/iden3comm-plain-json",
  "type": "https://iden3-communication.io/authorization/1.0/request",
  "body": $authRequestBodyJson
}
''';

  static AuthIden3MessageEntity authRequest =
      AuthIden3MessageEntity.fromJson(jsonDecode(authRequestJson));

  /// [FetchIden3MessageEntity]
  static String fetchRequestBodyJson = '''
  {
    "id": "fe4d9b5e-7b7e-4b9e-8c5a-1b5b4b4e4e4e"
  }
  ''';

  static String fetchRequestJson = '''
{
  "id": "4dd6479b-99b6-405c-ba9e-c7b18d251a5e",
  "typ": "application/iden3comm-plain-json",
  "type": "https://iden3-communication.io/credentials/1.0/issuance-response",
  "thid": "4dd6479b-99b6-405c-ba9e-c7b18d251a5e",
  "from": "1125GJqgw6YEsKFwj63GY87MMxPL9kwDKxPUiwMLNZ",
  "to": "1244GJqgw6YEsKFwj63GY87MMxPL9kwDKxPUiwMLNZ",
  "body": $fetchRequestBodyJson
}
''';
  static FetchIden3MessageEntity fetchRequest =
      FetchIden3MessageEntity.fromJson(jsonDecode(fetchRequestJson));

  /// [OfferIden3MessageEntity]
  static String offerUrl = "theOfferUrl";

  static String offerRequestBodyJson = '''
  {
      "url": "$offerUrl",
      "credentials": [
        {
          "id": "claimId",
          "description": "claimDescription"
        },
        {
          "id": "otherClaimId",
          "description": "otherClaimDescription"
        }
      ]
  }
''';
  static String offerRequestJson = '''
{
  "id": "1",
  "typ": "theTyp",
  "type": "https://iden3-communication.io/credentials/1.0/offer",
  "thid": "theThid",
  "from": "theFrom",
  "body": $offerRequestBodyJson
}
''';
  static OfferIden3MessageEntity offerRequest =
      OfferIden3MessageEntity.fromJson(jsonDecode(offerRequestJson));

  /// [ContractFunctionCallRequest]
  static String contractFunctionCallRequestBodyTxJson = '''
{
  "contract_address": "0x0000000000000000000000000000000000000000",
  "method_id": "0x00000000",
  "chain_id": 1,
  "network": "mainnet"
}
''';
  static String contractFunctionCallRequestBodyJson = '''
{
  "transaction_data": $contractFunctionCallRequestBodyTxJson,
  "reason": "theTransactionReason",
  "scope": [
    $proofScopeRequestJson
  ]
}
''';

  static String contractFunctionCallRequestJson = '''
{
  "id": "theId",
  "typ": "theTyp",
  "type": "https://iden3-communication.io/proofs/1.0/contract-invoke-request",
  "body": $contractFunctionCallRequestBodyJson
}
''';

  static ContractIden3MessageEntity contractFunctionCallRequest =
      ContractIden3MessageEntity.fromJson(
          jsonDecode(contractFunctionCallRequestJson));

  static Map<String, dynamic> mockContext = {
    "@context": [
      {
        "@version": 1.1,
        "@protected": true,
        "id": "@id",
        "type": "@type",
        "KYCAgeCredential": {
          "@id":
              "https://raw.githubusercontent.com/iden3/claim-schema-vocab/main/schemas/json-ld/kyc-v4.jsonld#KYCAgeCredential",
          "@context": {
            "@version": 1.1,
            "@protected": true,
            "id": "@id",
            "type": "@type",
            "kyc-vocab":
                "https://github.com/iden3/claim-schema-vocab/blob/main/credentials/kyc.md#",
            "xsd": "http://www.w3.org/2001/XMLSchema#",
            "birthday": {"@id": "kyc-vocab:birthday", "@type": "xsd:integer"},
            "documentType": {
              "@id": "kyc-vocab:documentType",
              "@type": "xsd:integer"
            }
          }
        },
        "KYCCountryOfResidenceCredential": {
          "@id":
              "https://raw.githubusercontent.com/iden3/claim-schema-vocab/main/schemas/json-ld/kyc-v4.jsonld#KYCCountryOfResidenceCredential",
          "@context": {
            "@version": 1.1,
            "@protected": true,
            "id": "@id",
            "type": "@type",
            "kyc-vocab":
                "https://github.com/iden3/claim-schema-vocab/blob/main/credentials/kyc.md#",
            "xsd": "http://www.w3.org/2001/XMLSchema#",
            "countryCode": {
              "@id": "kyc-vocab:countryCode",
              "@type": "xsd:integer"
            },
            "documentType": {
              "@id": "kyc-vocab:documentType",
              "@type": "xsd:integer"
            }
          }
        }
      }
    ]
  };

  /// [Iden3commVPProof]
  static String iden3commVpProofJson = '''
  {
    "verifiableCredential": {
      "documentType": 99,
      "@type": "KYCAgeCredential"
    },
    "@type": "VerifiablePresentation",
    "@context": [
      "https://www.w3.org/2018/credentials/v1",
      "https://raw.githubusercontent.com/iden3/claim-schema-vocab/main/schemas/json-ld/kyc-v3.json-ld"
    ]
  }
  ''';

  /// [JWZHeader]
  static String jwzHeaderJson = '''
  {
      "alg": "groth16",
      "circuitId": "authV2",
      "crit": [
          "circuitId"
      ],
      "typ": "application/iden3-zkp-json"
  }
  ''';

  static List<ProofRequestEntity> proofRequestList = [
    ProofRequestEntity(Iden3commMocks.proofScopeRequest, mockContext),
    ProofRequestEntity(Iden3commMocks.proofScopeRequest, mockContext),
  ];

  static Iden3commProofEntity iden3commProof = Iden3commProofEntity(
    id: proofRequestList[0].scope.id,
    circuitId: proofRequestList[0].scope.circuitId,
    proof: ProofMocks.zkProof.proof,
    pubSignals: ProofMocks.zkProof.pubSignals,
    publicStatesInfo: ProofMocks.publicStatesInfo,
  );

  static Iden3commSDProofEntity iden3commSDProof = Iden3commSDProofEntity(
    id: proofRequestList[0].scope.id,
    circuitId: proofRequestList[0].scope.circuitId,
    proof: ProofMocks.zkProof.proof,
    pubSignals: ProofMocks.zkProof.pubSignals,
    publicStatesInfo: ProofMocks.publicStatesInfo,
    vp: vp,
  );

  static Iden3commVPProof vp =
      Iden3commVPProof.fromJson(jsonDecode(iden3commVpProofJson));

  static JWZHeader jwzHeader = JWZHeader.fromJson(jsonDecode(jwzHeaderJson));

  static JWZPayload jwzPayload = JWZPayload(payload: CommonMocks.message);

  static JWZEntity jwz = JWZEntity(
      header: jwzHeader, payload: jwzPayload, proof: ProofMocks.zkProof);

  static String encodedJWZ =
      'eyJhbGciOiJncm90aDE2IiwiY2lyY3VpdElkIjoiYXV0aFYyIiwiY3JpdCI6WyJjaXJjdWl0SWQiXSwidHlwIjoiYXBwbGljYXRpb24vaWRlbjMtemtwLWpzb24ifQ.dGhlTWVzc2FnZQ.eyJwcm9vZiI6eyJwaV9hIjpbIjEyOTcyMjU3NDc4MDU1Mzg1Mjg3MjU0MzY1MjQyOTI5NTAxMzEzMzIwNTU4NzQ4OTM5MDExNjYwMDg5NjA4NzQzMDk5NzQ1MTExMTgwIiwiMjE2MjI3OTU4MTgyODMzOTA4MDI2NjU1MDQ3Njc2NDcwNjA0NjE2MzE4OTAxODM1MjU3OTY3NTM0MTQ0NTAyNDE2MDYyNDk1NzA4MDMiLCIxIl0sInBpX2IiOltbIjEyODQ3MDk5NjgxNDgzNjIwMjQ0ODkxODk2ODg5NTA5NTY1OTA1MjAwODQ3NjM5MTU2NjYyNTY2NjQ2ODMxNjQ0NDI1NTg3NzY3NjA1IiwiNzcyNjkwNjY1ODg3NDM1NTkyODU2NjEzNjU4MjIzMzc1MzQyMjMwODY5OTgzMDI4MjEyODQyNTgwMTc5MjEwMDUyMjc0MDg0MjcxNCJdLFsiNjk4MDQ2NzkwNjI1NzAxNDE0NzIzOTE1NDQ0MTc5ODE5MDAzODM4MDMxNTMwNTAzNjkyNjM2ODM0MDAwODUyMDgyODQ1NTYwNjc1MiIsIjIyMzAyNDk3NTU5MzM0MDI2NDU1ODI3NTAzNzYxNzgzMDA0NTYyNjMwMDQ4NzQwNjk3ODcyMjI2MzEyNDA5OTk2NDI0NDQ4NzQ4MDUiXSxbIjEiLCIwIl1dLCJwaV9jIjpbIjE2OTg2MDg3OTA1MDQ4NDg1NDg4NzQzODYxNTE0MjM4OTY3MDIxMTM2MjI1NzcwMjM1MzI2OTQxNDYwOTM4OTkzOTE1NTY1MTIxNzU1IiwiNjIzODMyNTA3NzU1ODQ4NzA4MjIwOTYyMzU5NTUyMzEyNjYyMjc0ODM2MDk5OTI0NjAxOTg3ODM4ODExMTU4MzEwNjUxNjMzODQzNiIsIjEiXSwicHJvdG9jb2wiOiJncm90aDE2IiwiY3VydmUiOiJibjEyOCJ9LCJwdWJfc2lnbmFscyI6WyIxNzMxNjAwOTUyOTcyODI1NTE3OTQwNzczMjIzMTMwOTQ0MTU4NzEzMzMzMjA4MjYzOTY0OTg5NDc4ODk2MjgxNDQwMjI4NTgzODYxMiIsIjQyMTkzOTQyNTU5MDQ2NDYyMDE1MjQ5Njc4MjY0NzIwMDQyNTgzNTkzMzg2OTE4MTIxMjcyNTA4Mjk0ODAxMjg2MzA3NjM1NDE5OTIiLCIzNTQyMDAxMzc0NzIyNDk2Mzg3NzE5OTE2MjI0NjcyODcwNzI2MDMyNDk1MDI1NjUxMjExNjU5Nzc1NjU3MzU5NDEzNzMyOTY2NCJdfQ';

  static List<InteractionEntity> interactionEntities = [
    InteractionEntity(
      id: CommonMocks.intValues[0].toString(),
      from: CommonMocks.did,
      genesisDid: CommonMocks.did,
      profileNonce: CommonMocks.nonce,
      type: InteractionType.offer,
      timestamp: 0,
      message: CommonMocks.message,
      state: InteractionState.opened,
      to: CommonMocks.did,
    ),
    InteractionEntity(
      id: CommonMocks.intValues[1].toString(),
      from: CommonMocks.did,
      genesisDid: CommonMocks.did,
      profileNonce: CommonMocks.nonce,
      type: InteractionType.authRequest,
      timestamp: 0,
      message: CommonMocks.message,
      state: InteractionState.received,
      to: CommonMocks.did,
    ),
    InteractionEntity(
      id: CommonMocks.intValues[2].toString(),
      from: CommonMocks.did,
      genesisDid: CommonMocks.did,
      profileNonce: CommonMocks.nonce,
      type: InteractionType.offer,
      timestamp: 0,
      message: CommonMocks.message,
      state: InteractionState.accepted,
      to: CommonMocks.did,
    ),
  ];
}
