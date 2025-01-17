import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:polygonid_flutter_sdk/credential/data/dtos/claim_dto.dart';
import 'package:polygonid_flutter_sdk/credential/data/dtos/display_type/unknown_display_type.dart';
import 'package:polygonid_flutter_sdk/credential/data/mappers/claim_info_mapper.dart';
import 'package:polygonid_flutter_sdk/credential/data/mappers/claim_mapper.dart';
import 'package:polygonid_flutter_sdk/credential/data/mappers/claim_state_mapper.dart';
import 'package:polygonid_flutter_sdk/credential/data/mappers/display_type_mapper.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/dtos/credential/response/fetch_claim_response_dto.dart';

import '../../../iden3comm/data/dtos/fetch_claim_response_dto_test.dart';
import 'claim_mapper_test.mocks.dart';

// Data
const privateKey = "thePrivateKey";
const identifier = "theIdentifier";
const authClaim = "theAuthClaim";

/// We assume [FetchClaimResponseDTO] has been tested
final fetchClaimDTO =
    FetchClaimResponseDTO.fromJson(jsonDecode(mockFetchClaim));
final Map<String, dynamic> info = fetchClaimDTO.credential.toJson();
final dto = ClaimDTO(
  id: fetchClaimDTO.credential.id,
  issuer: fetchClaimDTO.from,
  did: identifier,
  expiration: fetchClaimDTO.credential.expirationDate,
  type: fetchClaimDTO.credential.credentialSubject.type,
  info: fetchClaimDTO.credential,
  credentialRawValue: mockFetchClaim,
);
final entity = ClaimEntity(
  issuer: fetchClaimDTO.from,
  did: identifier,
  expiration: fetchClaimDTO.credential.expirationDate,
  info: info,
  type: fetchClaimDTO.credential.credentialSubject.type,
  state: ClaimState.active,
  id: fetchClaimDTO.credential.id,
  credentialRawValue: mockFetchClaim,
);
final displayType = UnknownDisplayType({});

// Dependencies
MockClaimStateMapper stateMapper = MockClaimStateMapper();
MockClaimInfoMapper infoMapper = MockClaimInfoMapper();
MockDisplayTypeMapper displayTypeMapper = MockDisplayTypeMapper();
// Tested instance
ClaimMapper mapper = ClaimMapper(stateMapper, infoMapper, displayTypeMapper);

@GenerateMocks([
  ClaimStateMapper,
  ClaimInfoMapper,
  DisplayTypeMapper,
])
void main() {
  setUp(() {});

  group("Map from", () {
    test(
        "Given a ClaimDTO, when I call mapFrom, then I expect an ClaimEntity to be returned",
        () {
      // Given
      when(infoMapper.mapFrom(any)).thenReturn(info);
      when(stateMapper.mapFrom(any)).thenReturn(ClaimState.active);
      when(displayTypeMapper.mapFrom(any)).thenReturn(displayType);

      // When
      expect(mapper.mapFrom(dto), entity);

      // Then
      expect(verify(infoMapper.mapFrom(captureAny)).captured.first,
          fetchClaimDTO.credential);
      expect(verify(stateMapper.mapFrom(captureAny)).captured.first, '');
      verifyNever(displayTypeMapper.mapFrom(captureAny));
    });
  });

  group("Map to", () {
    test(
        "Given a ClaimEntity, when I call mapTo, then I expect an ClaimDTO to be returned",
        () {
      // Given
      when(infoMapper.mapTo(any)).thenReturn(fetchClaimDTO.credential);
      when(stateMapper.mapTo(any)).thenReturn('');
      when(displayTypeMapper.mapTo(any)).thenReturn({});

      // When
      expect(mapper.mapTo(entity), dto);

      // Then
      expect(verify(infoMapper.mapTo(captureAny)).captured.first, info);
      expect(verify(stateMapper.mapTo(captureAny)).captured.first,
          ClaimState.active);
    });
  });
}
