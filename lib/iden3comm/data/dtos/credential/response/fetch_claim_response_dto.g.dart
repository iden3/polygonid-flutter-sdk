// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fetch_claim_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FetchClaimResponseDTO _$FetchClaimResponseDTOFromJson(
        Map<String, dynamic> json) =>
    FetchClaimResponseDTO(
      $enumDecode(_$FetchClaimResponseTypeEnumMap, json['type'],
          unknownValue: FetchClaimResponseType.unknown),
      json['from'] as String,
      const FetchClaimResponseCredentialConverter()
          .fromJson(json['body'] as Map<String, dynamic>),
    );

const _$FetchClaimResponseTypeEnumMap = {
  FetchClaimResponseType.unknown: '',
  FetchClaimResponseType.auth:
      'https://iden3-communication.io/authorization/1.0/request',
  FetchClaimResponseType.offer:
      'https://iden3-communication.io/credentials/1.0/offer',
  FetchClaimResponseType.onchainOffer:
      'https://iden3-communication.io/credentials/1.0/onchain-offer',
  FetchClaimResponseType.issuance:
      'https://iden3-communication.io/credentials/1.0/issuance-response',
  FetchClaimResponseType.contractFunctionCall:
      'https://iden3-communication.io/proofs/1.0/contract-invoke-request',
  FetchClaimResponseType.contractFunctionCallResponse:
      'https://iden3-communication.io/proofs/1.0/contract-invoke-response',
};
