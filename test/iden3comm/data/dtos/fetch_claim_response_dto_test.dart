import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/dtos/credential/response/fetch_claim_response_dto.dart';

// Data
String mockFetchClaim = '''
{
  "body": {
    "credential": {
      "@context": [
        "https://www.w3.org/2018/credentials/v1",
        "https://raw.githubusercontent.com/iden3/claim-schema-vocab/main/schemas/json-ld/iden3credential-v2.json-ld",
        "https://raw.githubusercontent.com/iden3/claim-schema-vocab/main/schemas/json-ld/kyc-v3.json-ld"
      ],
      "credentialSchema": {
        "id": "https://raw.githubusercontent.com/iden3/claim-schema-vocab/main/schemas/json/KYCAgeCredential-v3.json",
        "type": "JsonSchemaValidator2018"
      },
      "credentialStatus": {
        "id": "http://52.213.238.159/api/v1/identities/did%3Apolygonid%3Apolygon%3Amumbai%3A2qJNoD4vLiuoaM6B5rEidsSR4Kj9ZTJp1wgvhB6wBB/claims/revocation/status/2695678422",
        "revocationNonce": 2695678422,
        "type": "SparseMerkleTreeProof"
      },
      "credentialSubject": {
        "birthday": 19960424,
        "documentType": 899417,
        "id": "did:polygonid:polygon:mumbai:2qGJnNTaHyvZwcTG4jWDif2E5GnWuLGfuWb2misbrC",
        "type": "KYCAgeCredential"
      },
      "expirationDate": "2030-01-01T00:00:00Z",
      "id": "http://52.213.238.159/api/v1/identities/did:polygonid:polygon:mumbai:2qJNoD4vLiuoaM6B5rEidsSR4Kj9ZTJp1wgvhB6wBB/claims/3f43b616-9d57-11ed-a2b8-0242ac120004",
      "issuanceDate": "2023-01-26T08:55:56.747082936Z",
      "issuer": "did:polygonid:polygon:mumbai:2qJNoD4vLiuoaM6B5rEidsSR4Kj9ZTJp1wgvhB6wBB",
      "proof": [
        {
          "coreClaim": "c9b2370371b7fa8b3dab2a5ba81b68382a000000000000000000000000000000021254956ce0d077706ce9c95fe7e7998897a106a37c11d544154e151a850d006e9670688456f9f4be95af1f032b527ba957d5b7b9f70a6cfeac4abb151caf230000000000000000000000000000000000000000000000000000000000000000d6c9aca00000000080d8db700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
          "issuerData": {
            "authCoreClaim": "cca3371a6cb1b715004407e325bd993c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c05e1567fa2f44c94f26e84f8463fb39dbee2d98d90c9a7d343aa02aea1e80146bb9acb6b6f75a23edbfbed032826b699ee637b9944cb5e7680f26e5b789fe0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
            "credentialStatus": {
              "id": "http://52.213.238.159/api/v1/identities/did%3Apolygonid%3Apolygon%3Amumbai%3A2qJNoD4vLiuoaM6B5rEidsSR4Kj9ZTJp1wgvhB6wBB/claims/revocation/status/0",
              "revocationNonce": 0,
              "type": "SparseMerkleTreeProof"
            },
            "id": "did:polygonid:polygon:mumbai:2qJNoD4vLiuoaM6B5rEidsSR4Kj9ZTJp1wgvhB6wBB",
            "mtp": {
              "existence": true,
              "siblings": []
            },
            "state": {
              "rootOfRoots": "02427d5b0d16baf64e1513f9650eb959550b7c4d54738a707d1de355b756a914",
              "claimsTreeRoot": "6b8bb8c1dac02f010ac1642a694a3d7b32e1152907636521fb31dc01ba6abf0f",
              "revocationTreeRoot": "0000000000000000000000000000000000000000000000000000000000000000",
              "value": "168f3b0c33822a02e3c070ead88e1169c922984b8a91a8600dfe8a51eb9de12e"
            }
          },
          "signature": "09f22d676951d71c96cea291a011708f9de1380b8bb895d28bf9784104c0e209fda21b1f3ff6e0f94dfdf38c2e4b9cf428a3798cc03b99ed0c4ddcd29e12f401",
          "type": "BJJSignature2021"
        },
        {
          "coreClaim": "c9b2370371b7fa8b3dab2a5ba81b68382a000000000000000000000000000000021254956ce0d077706ce9c95fe7e7998897a106a37c11d544154e151a850d006e9670688456f9f4be95af1f032b527ba957d5b7b9f70a6cfeac4abb151caf230000000000000000000000000000000000000000000000000000000000000000d6c9aca00000000080d8db700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
          "issuerData": {
            "id": "did:polygonid:polygon:mumbai:2qJNoD4vLiuoaM6B5rEidsSR4Kj9ZTJp1wgvhB6wBB",
            "state": {
              "blockNumber": 31423536,
              "blockTimestamp": 1674723432,
              "claimsTreeRoot": "94b6bf063ddd6a0881f99b5580e5ebe36613d37dc6ade51679f46683f7f37e03",
              "revocationTreeRoot": "0000000000000000000000000000000000000000000000000000000000000000",
              "rootOfRoots": "ae0d86725527bf08779e54ac6636ce6db251cb7e82fcf8fac089200f07fbc70c",
              "txId": "0xc723a7353e36d06e21bb1426db845ebc4705c28188c13e60a67d7de3c9ccef05",
              "value": "8eda95e0017d30a9b48d01ad26efdb47fe28b3a9704732b1fb8537917bf13d0f"
            }
          },
          "mtp": {
            "existence": true,
            "siblings": [
              "9224151524065521610459630456698808555233973268242007269052989118449206228209",
              "14838613564893626998757603376162516408231719530749557145478409763867715178472",
              "0",
              "1629821442553780810224570434827430830509082759185746511632017916301016098201",
              "14633544220149887348900383206633509039569184168313773699754851378075184622010"
            ]
          },
          "type": "Iden3SparseMerkleProof"
        }
      ],
      "type": [
        "VerifiableCredential",
        "KYCAgeCredential"
      ]
    }
  },
  "from": "did:polygonid:polygon:mumbai:2qJNoD4vLiuoaM6B5rEidsSR4Kj9ZTJp1wgvhB6wBB",
  "id": "073c2313-06e2-4371-83b9-d01c800c1978",
  "thid": "814fac46-e4f3-4b38-a9c4-df261010f655",
  "to": "did:polygonid:polygon:mumbai:2qGJnNTaHyvZwcTG4jWDif2E5GnWuLGfuWb2misbrC",
  "typ": "application/iden3comm-plain-json",
  "type": "https://iden3-communication.io/credentials/1.0/issuance-response"
}
''';
String mockOtherTypeFetchClaim = '''
{
  "body": {
    "credential": {
      "@context": [
        "https://www.w3.org/2018/credentials/v1",
        "https://raw.githubusercontent.com/iden3/claim-schema-vocab/main/schemas/json-ld/iden3credential-v2.json-ld",
        "https://raw.githubusercontent.com/iden3/claim-schema-vocab/main/schemas/json-ld/kyc-v3.json-ld"
      ],
      "credentialSchema": {
        "id": "https://raw.githubusercontent.com/iden3/claim-schema-vocab/main/schemas/json/KYCCountryOfResidenceCredential-v2.json",
        "type": "JsonSchemaValidator2018"
      },
      "credentialStatus": {
        "id": "http://52.213.238.159/api/v1/identities/did%3Apolygonid%3Apolygon%3Amumbai%3A2qJNoD4vLiuoaM6B5rEidsSR4Kj9ZTJp1wgvhB6wBB/claims/revocation/status/1059717501",
        "revocationNonce": 1059717501,
        "type": "SparseMerkleTreeProof"
      },
      "credentialSubject": {
        "countryCode": 385,
        "documentType": 482499,
        "id": "did:polygonid:polygon:mumbai:2qGJnNTaHyvZwcTG4jWDif2E5GnWuLGfuWb2misbrC",
        "type": "KYCCountryOfResidenceCredential"
      },
      "expirationDate": "2030-01-01T00:00:00Z",
      "id": "http://52.213.238.159/api/v1/identities/did:polygonid:polygon:mumbai:2qJNoD4vLiuoaM6B5rEidsSR4Kj9ZTJp1wgvhB6wBB/claims/e923516e-9d94-11ed-b6c2-0242ac130007",
      "issuanceDate": "2023-01-26T16:17:21.047963329Z",
      "issuer": "did:polygonid:polygon:mumbai:2qJNoD4vLiuoaM6B5rEidsSR4Kj9ZTJp1wgvhB6wBB",
      "proof": [
        {
          "coreClaim": "18f30714a35a5db88ca24728c0c53dfd2a000000000000000000000000000000021254956ce0d077706ce9c95fe7e7998897a106a37c11d544154e151a850d009700e8422b42774224ac558852b9139467fb3a645038272dff6cf4c7c8e78c2900000000000000000000000000000000000000000000000000000000000000007d012a3f0000000080d8db700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
          "issuerData": {
            "authCoreClaim": "cca3371a6cb1b715004407e325bd993c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c05e1567fa2f44c94f26e84f8463fb39dbee2d98d90c9a7d343aa02aea1e80146bb9acb6b6f75a23edbfbed032826b699ee637b9944cb5e7680f26e5b789fe0f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
            "credentialStatus": {
              "id": "http://52.213.238.159/api/v1/identities/did%3Apolygonid%3Apolygon%3Amumbai%3A2qJNoD4vLiuoaM6B5rEidsSR4Kj9ZTJp1wgvhB6wBB/claims/revocation/status/0",
              "revocationNonce": 0,
              "type": "SparseMerkleTreeProof"
            },
            "id": "did:polygonid:polygon:mumbai:2qJNoD4vLiuoaM6B5rEidsSR4Kj9ZTJp1wgvhB6wBB",
            "mtp": {
              "existence": true,
              "siblings": []
            },
            "state": {
              "claimsTreeRoot": "a69c9f7f0eb7bb69e3904608be7551b60853211c31b2700bbe6eecd00651c228",
              "value": "168f3b0c33822a02e3c070ead88e1169c922984b8a91a8600dfe8a51eb9de12e"
            }
          },
          "signature": "f492f1d147fd8a9343576107e676113e2ab6cfd51baf247f461c66c30b035e1bf20e7aa6462f642d2563be6f99e844c66ab947e47d1bd8b3a1c23e9cf67ecc03",
          "type": "BJJSignature2021"
        },
        {
          "coreClaim": "18f30714a35a5db88ca24728c0c53dfd2a000000000000000000000000000000021254956ce0d077706ce9c95fe7e7998897a106a37c11d544154e151a850d009700e8422b42774224ac558852b9139467fb3a645038272dff6cf4c7c8e78c2900000000000000000000000000000000000000000000000000000000000000007d012a3f0000000080d8db700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
          "issuerData": {
            "id": "did:polygonid:polygon:mumbai:2qJNoD4vLiuoaM6B5rEidsSR4Kj9ZTJp1wgvhB6wBB",
            "state": {
              "blockNumber": 31435957,
              "blockTimestamp": 1674749891,
              "claimsTreeRoot": "aa33cd8a9bf47f28342a96dd0b86ff85b08fd2c2a28fb73188de51645aa2b214",
              "revocationTreeRoot": "28a8ecaca2cac20d60b60c49aa760dba9717f9b4eb6bdac008f8a10c8cacf10f",
              "rootOfRoots": "9a43342829d669a70f527469643433202690c82e642dae1aa19ec33a12df0d01",
              "txId": "0x91f47c7a4ba8a74da4b71f26d2549225be3a6033d7bc6f4f4e64998e9303b7a7",
              "value": "b80f624fb48bbc038898c4e09e58684213ed3dd50736b1194b0fda8a11205901"
            }
          },
          "mtp": {
            "existence": true,
            "siblings": [
              "7328094089625865818837183572832884779427593528171218874180707839088049235874",
              "16546707433365560662293830265897996442609716162176871793483031980134475297186",
              "14127945985630909587008787426474283882613485324969055192834958485985193411049",
              "9772271368725529862838873447956479710336513070810298013472579705160393697038",
              "12338695122068474492889642945130245192533091548690372161120141718360318388693"
            ]
          },
          "type": "Iden3SparseMerkleProof"
        }
      ],
      "type": [
        "VerifiableCredential",
        "KYCCountryOfResidenceCredential"
      ]
    }
  },
  "from": "did:polygonid:polygon:mumbai:2qJNoD4vLiuoaM6B5rEidsSR4Kj9ZTJp1wgvhB6wBB",
  "id": "f4d8b17a-db05-4d4a-a995-7c720bf360cb",
  "thid": "d4e3ca6f-780d-4dea-be34-de1829fd9c4d",
  "to": "did:polygonid:polygon:mumbai:2qGJnNTaHyvZwcTG4jWDif2E5GnWuLGfuWb2misbrC",
  "typ": "application/iden3comm-plain-json",
  "type": "https://iden3-communication.io/credentials/1.0/other-response"
}
''';

String mockFetchCredentialMTP = '''
{
  "body": {
    "credential": {
      "id": "https://issuer-admin.polygonid.me/v1/credentials/69b66264-a0b2-11ee-93b5-0242ac120009",
      "@context": [
        "https://www.w3.org/2018/credentials/v1",
        "https://schema.iden3.io/core/jsonld/iden3proofs.jsonld",
        "ipfs://QmdH1Vu79p2NcZLFbHxzJnLuUHJiMZnBeT7SNpLaqK7k9X"
      ],
      "type": [
        "VerifiableCredential",
        "POAP01"
      ],
      "issuanceDate": "2023-12-22T10:11:03.325197614Z",
      "credentialSubject": {
        "city": "affasfsg",
        "id": "did:polygonid:polygon:mumbai:2qFXVU2SPH9WvhPW1S4nqrY2zc9q8124hoj5hr2Tmy",
        "type": "POAP01"
      },
      "credentialStatus": {
        "id": "https://rhs-staging.polygonid.me/node?state=cf4d52e845a60ab1c442546eddfefa3ec3c01e04db239a5bac170e7fc1bd6b19",
        "revocationNonce": 3135116222,
        "statusIssuer": {
          "id": "https://issuer-admin.polygonid.me/v1/credentials/revocation/status/3135116222",
          "revocationNonce": 3135116222,
          "type": "SparseMerkleTreeProof"
        },
        "type": "Iden3ReverseSparseMerkleTreeProof"
      },
      "issuer": "did:polygonid:polygon:mumbai:2qMCebtitXNzau92r4JNV3y162hkzVZPn75UPMiE1G",
      "credentialSchema": {
        "id": "ipfs://QmTSwnuCB9grYMB2z5EKXDagfChurK5MiMCS6efrRbsyVX",
        "type": "JsonSchema2023"
      },
      "proof" : []
    }
  },
  "from": "did:polygonid:polygon:mumbai:2qMCebtitXNzau92r4JNV3y162hkzVZPn75UPMiE1G",
  "id": "166aa1b4-69d2-4355-aea1-d802c2341186",
  "threadID": "5a23c836-8e4c-4c2b-bbdf-df3dd342884d",
  "to": "did:polygonid:polygon:mumbai:2qFXVU2SPH9WvhPW1S4nqrY2zc9q8124hoj5hr2Tmy",
  "typ": "application/iden3comm-plain-json",
  "type": "https://iden3-communication.io/credentials/1.0/issuance-response"
}
''';

var json = jsonDecode(mockFetchClaim);
var jsonMTP = jsonDecode(mockFetchCredentialMTP);

// Dependencies

// Tested instance

void main() {
  group("Claim DTO", () {
    setUp(() {});

    test("Serializable", () {
      // ignore: unused_local_variable
      FetchClaimResponseDTO dto = FetchClaimResponseDTO.fromJson(json);
    });
  });

  group("FetchClaimResponseDTO with MTP", () {
    test("should parse valid JSON with MTP correctly", () {
      var dto = FetchClaimResponseDTO.fromJson(jsonMTP);
      expect(dto.type, FetchClaimResponseType.issuance);
      expect(dto.from,
          "did:polygonid:polygon:mumbai:2qMCebtitXNzau92r4JNV3y162hkzVZPn75UPMiE1G");
      expect(dto.credential.id,
          "https://issuer-admin.polygonid.me/v1/credentials/69b66264-a0b2-11ee-93b5-0242ac120009");
    });
  });
}
