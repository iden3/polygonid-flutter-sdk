// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claim_info_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClaimInfoDTO _$ClaimInfoDTOFromJson(Map<String, dynamic> json) => ClaimInfoDTO(
      json['id'] as String,
      (json['@context'] as List<dynamic>).map((e) => e as String).toList(),
      (json['type'] as List<dynamic>).map((e) => e as String).toList(),
      json['expirationDate'] as String?,
      json['issuanceDate'] as String,
      CredentialSubjectDTO.fromJson(
          json['credentialSubject'] as Map<String, dynamic>),
      CredentialStatusDTO.fromJson(
          json['credentialStatus'] as Map<String, dynamic>),
      json['issuer'] as String,
      CredentialSchemaDTO.fromJson(
          json['credentialSchema'] as Map<String, dynamic>),
      (json['proof'] as List<dynamic>?)
          ?.map((e) => ClaimProofDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['refreshService'] == null
          ? null
          : RefreshServiceDTO.fromJson(
              json['refreshService'] as Map<String, dynamic>),
      json['displayMethod'] == null
          ? null
          : DisplayMethodDTO.fromJson(
              json['displayMethod'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ClaimInfoDTOToJson(ClaimInfoDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      '@context': instance.context,
      'type': instance.type,
      'expirationDate': instance.expirationDate,
      'issuanceDate': instance.issuanceDate,
      'credentialSubject': instance.credentialSubject.toJson(),
      'credentialStatus': instance.credentialStatus.toJson(),
      'issuer': instance.issuer,
      'credentialSchema': instance.credentialSchema.toJson(),
      'proof': instance.proofs?.map((e) => e.toJson()).toList(),
      'refreshService': instance.refreshService?.toJson(),
      'displayMethod': instance.displayMethod?.toJson(),
    };

CredentialStatusDTO _$CredentialStatusDTOFromJson(Map<String, dynamic> json) =>
    CredentialStatusDTO(
      json['id'] as String,
      (json['revocationNonce'] as num?)?.toInt(),
      $enumDecode(_$CredentialStatusTypeEnumMap, json['type']),
      json['statusIssuer'] == null
          ? null
          : CredentialStatusDTO.fromJson(
              json['statusIssuer'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CredentialStatusDTOToJson(
        CredentialStatusDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'revocationNonce': instance.revocationNonce,
      'type': _$CredentialStatusTypeEnumMap[instance.type]!,
      'statusIssuer': instance.statusIssuer?.toJson(),
    };

const _$CredentialStatusTypeEnumMap = {
  CredentialStatusType.reverseSparseMerkleTreeProof:
      'Iden3ReverseSparseMerkleTreeProof',
  CredentialStatusType.sparseMerkleTreeProof: 'SparseMerkleTreeProof',
  CredentialStatusType.iden3OnchainSparseMerkleTreeProof2023:
      'Iden3OnchainSparseMerkleTreeProof2023',
  CredentialStatusType.iden3commRevocationStatusV1:
      'Iden3commRevocationStatusV1.0',
};

CredentialSchemaDTO _$CredentialSchemaDTOFromJson(Map<String, dynamic> json) =>
    CredentialSchemaDTO(
      json['id'] as String,
      json['type'] as String,
    );

Map<String, dynamic> _$CredentialSchemaDTOToJson(
        CredentialSchemaDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
    };

DisplayMethodDTO _$DisplayMethodDTOFromJson(Map<String, dynamic> json) =>
    DisplayMethodDTO(
      json['id'] as String,
      json['type'] as String,
    );

Map<String, dynamic> _$DisplayMethodDTOToJson(DisplayMethodDTO instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
    };
