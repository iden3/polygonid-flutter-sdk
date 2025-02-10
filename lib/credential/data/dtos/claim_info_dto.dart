import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'claim_proofs/claim_proof_dto.dart';

part 'claim_info_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class ClaimInfoDTO extends Equatable {
  final String id;
  @JsonKey(name: '@context')
  final List<String> context;
  final List<String> type;
  final String? expirationDate;
  final String issuanceDate;
  final CredentialSubjectDTO credentialSubject;
  final CredentialStatusDTO credentialStatus;
  final String issuer;
  final CredentialSchemaDTO credentialSchema;
  @JsonKey(name: 'proof')
  final List<ClaimProofDTO>? proofs;
  final RefreshServiceDTO? refreshService;
  final DisplayMethodDTO? displayMethod;

  const ClaimInfoDTO(
    this.id,
    this.context,
    this.type,
    this.expirationDate,
    this.issuanceDate,
    this.credentialSubject,
    this.credentialStatus,
    this.issuer,
    this.credentialSchema,
    this.proofs,
    this.refreshService,
    this.displayMethod,
  );

  factory ClaimInfoDTO.fromJson(Map<String, dynamic> json) =>
      _$ClaimInfoDTOFromJson(json);

  Map<String, dynamic> toJson() => _$ClaimInfoDTOToJson(this)
    ..removeWhere((dynamic key, dynamic value) => key == null || value == null);

  @override
  List<Object?> get props => [
        id,
        context,
        type,
        expirationDate,
        issuanceDate,
        credentialSubject,
        credentialStatus,
        issuer,
        credentialSchema,
        proofs,
        refreshService,
      ];
}

/// If credential is refreshable, this is the data needed to refresh it
class RefreshServiceDTO {
  final String id;
  final String type;

  const RefreshServiceDTO(this.id, this.type);

  factory RefreshServiceDTO.fromJson(Map<String, dynamic> json) {
    String id = json['id'] as String;
    String type = json['type'] as String;

    return RefreshServiceDTO(id, type);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      'id': id,
      'type': type,
    };

    return result;
  }

  @override
  List<Object?> get props => [id, type];

  @override
  String toString() {
    return 'RefreshServiceDTO{id: $id, type: $type}';
  }
}

class CredentialSubjectDTO extends Equatable {
  final String id;
  final String type;
  final Map<String, dynamic>? data;

  const CredentialSubjectDTO(this.id, this.type, this.data);

  /// There are dynamic field which depends on the [type]
  /// but since we don't want to set the possible [type] in stone, we unserialize
  /// them in [data] (removing the known fields)
  factory CredentialSubjectDTO.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> data = jsonDecode(jsonEncode(json));
    String id = json['id'] as String;
    String type = json['type'] as String;
    data.remove('id');
    data.remove('type');

    return CredentialSubjectDTO(id, type, data);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      'id': id,
      'type': type,
    };

    data?.forEach((key, value) => result.putIfAbsent(key, () => value));

    return result;
  }

  @override
  List<Object?> get props => [id, type, data];
}

@JsonEnum()
enum CredentialStatusType {
  @JsonValue("Iden3ReverseSparseMerkleTreeProof")
  reverseSparseMerkleTreeProof,
  @JsonValue("SparseMerkleTreeProof")
  sparseMerkleTreeProof,
  @JsonValue("Iden3OnchainSparseMerkleTreeProof2023")
  iden3OnchainSparseMerkleTreeProof2023,
  @JsonValue("Iden3commRevocationStatusV1.0")
  iden3commRevocationStatusV1
}

@JsonSerializable(explicitToJson: true)
class CredentialStatusDTO extends Equatable {
  final String id;
  final int? revocationNonce;
  @JsonKey(name: 'type')
  final CredentialStatusType type;
  final CredentialStatusDTO? statusIssuer;

  const CredentialStatusDTO(
      this.id, this.revocationNonce, this.type, this.statusIssuer);

  factory CredentialStatusDTO.fromJson(Map<String, dynamic> json) =>
      _$CredentialStatusDTOFromJson(json);

  Map<String, dynamic> toJson() => _$CredentialStatusDTOToJson(this)
    ..removeWhere((dynamic key, dynamic value) => key == null || value == null);

  @override
  List<Object?> get props => [id, revocationNonce, type, statusIssuer];
}

@JsonSerializable()
class CredentialSchemaDTO extends Equatable {
  final String id;
  final String type;

  const CredentialSchemaDTO(this.id, this.type);

  factory CredentialSchemaDTO.fromJson(Map<String, dynamic> json) =>
      _$CredentialSchemaDTOFromJson(json);

  Map<String, dynamic> toJson() => _$CredentialSchemaDTOToJson(this);

  @override
  List<Object?> get props => [id, type];
}

@JsonSerializable()
class DisplayMethodDTO {
  /// Contains url.
  final String id;
  final String type;

  DisplayMethodDTO(this.id, this.type);

  factory DisplayMethodDTO.fromJson(Map<String, dynamic> json) =>
      _$DisplayMethodDTOFromJson(json);

  Map<String, dynamic> toJson() => _$DisplayMethodDTOToJson(this);

  @override
  List<Object?> get props => [id, type];
}
