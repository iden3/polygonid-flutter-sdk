import 'package:json_annotation/json_annotation.dart';

import '../../../../../credential/data/dtos/claim_info_dto.dart';

part 'fetch_claim_response_dto.g.dart';

@JsonEnum()
enum FetchClaimResponseType {
  @JsonValue("")
  unknown,
  @JsonValue("https://iden3-communication.io/authorization/1.0/request")
  auth,
  @JsonValue("https://iden3-communication.io/credentials/1.0/offer")
  offer,
  @JsonValue("https://iden3-communication.io/credentials/1.0/onchain-offer")
  onchainOffer,
  @JsonValue("https://iden3-communication.io/credentials/1.0/issuance-response")
  issuance,
  @JsonValue(
      "https://iden3-communication.io/proofs/1.0/contract-invoke-request")
  contractFunctionCall,
  @JsonValue(
      "https://iden3-communication.io/proofs/1.0/contract-invoke-response")
  contractFunctionCallResponse,
}

@JsonSerializable(explicitToJson: true, createToJson: false)
class FetchClaimResponseDTO {
  @JsonKey(unknownEnumValue: FetchClaimResponseType.unknown)
  final FetchClaimResponseType type;
  final String from;
  @FetchClaimResponseCredentialConverter()
  @JsonKey(name: 'body')
  final ClaimInfoDTO credential;

  FetchClaimResponseDTO(this.type, this.from, this.credential);

  factory FetchClaimResponseDTO.fromJson(Map<String, dynamic> json) =>
      _$FetchClaimResponseDTOFromJson(json);
}

class FetchClaimResponseCredentialConverter
    extends JsonConverter<ClaimInfoDTO, Map<String, dynamic>> {
  const FetchClaimResponseCredentialConverter();

  @override
  ClaimInfoDTO fromJson(Map<String, dynamic> json) {
    return ClaimInfoDTO.fromJson(json['credential']);
  }

  @override
  Map<String, dynamic> toJson(ClaimInfoDTO object) {
    return object.toJson();
  }
}
