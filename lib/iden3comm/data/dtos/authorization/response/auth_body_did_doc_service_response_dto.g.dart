// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_body_did_doc_service_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthBodyDidDocServiceResponseDTO _$AuthBodyDidDocServiceResponseDTOFromJson(
        Map<String, dynamic> json) =>
    AuthBodyDidDocServiceResponseDTO(
      id: json['id'] as String?,
      type: json['type'] as String?,
      serviceEndpoint: json['serviceEndpoint'] as String?,
      metadata: json['metadata'] == null
          ? null
          : AuthBodyDidDocServiceMetadataResponseDTO.fromJson(
              json['metadata'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuthBodyDidDocServiceResponseDTOToJson(
    AuthBodyDidDocServiceResponseDTO instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('type', instance.type);
  writeNotNull('serviceEndpoint', instance.serviceEndpoint);
  writeNotNull('metadata', instance.metadata);
  return val;
}
