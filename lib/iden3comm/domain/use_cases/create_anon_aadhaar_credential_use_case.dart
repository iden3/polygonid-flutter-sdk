import 'dart:convert';

import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_cases/get_env_use_case.dart';
import 'package:polygonid_flutter_sdk/credential/data/data_sources/lib_pidcore_credential_data_source.dart';
import 'package:polygonid_flutter_sdk/credential/data/dtos/claim_dto.dart';
import 'package:polygonid_flutter_sdk/credential/data/dtos/claim_info_dto.dart';
import 'package:polygonid_flutter_sdk/credential/data/mappers/claim_mapper.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/data_sources/remote_iden3comm_data_source.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/self_issuance/self_issued_credential_params.dart';

class CreateAnonAadhaarCredentialParam {
  final String qrData;
  final String profileDid;
  final SelfIssuedCredentialParams selfIssuedCredentialParams;

  CreateAnonAadhaarCredentialParam({
    required this.qrData,
    required this.profileDid,
    required this.selfIssuedCredentialParams,
  });
}

class CreateAnonAadhaarCredentialUseCase
    extends FutureUseCase<CreateAnonAadhaarCredentialParam, ClaimEntity> {
  final LibPolygonIdCoreCredentialDataSource _libPolygonIdCoreCredentialDS;
  final RemoteIden3commDataSource _remoteIden3commDataSource;
  final GetEnvUseCase _getEnvUseCase;
  final ClaimMapper _claimMapper;

  CreateAnonAadhaarCredentialUseCase(
    this._libPolygonIdCoreCredentialDS,
    this._remoteIden3commDataSource,
    this._getEnvUseCase,
    this._claimMapper,
  );

  @override
  Future<ClaimEntity> execute({
    required CreateAnonAadhaarCredentialParam param,
  }) async {
    final env = await _getEnvUseCase.execute();

    final credentialJson =
        _libPolygonIdCoreCredentialDS.credentialFromAnonAadhaar(
      qrData: param.qrData,
      did: param.profileDid,
      selfIssuedCredentialParams: param.selfIssuedCredentialParams,
      config: jsonEncode(env.config.toJson()),
    );

    final claimJson = jsonDecode(credentialJson);
    final claimInfoDto = ClaimInfoDTO.fromJson(claimJson);

    final claimDto = ClaimDTO(
      id: claimInfoDto.id,
      issuer: claimInfoDto.issuer,
      did: param.profileDid,
      type: claimInfoDto.credentialSubject.type,
      info: claimInfoDto,
      credentialRawValue: jsonEncode({
        "from": param.selfIssuedCredentialParams.issuerDid,
        "body": claimJson,
        // TODO Maybe use some other type
        "type": "https://iden3-communication.io/credentials/1.0/offer",
      }),
    );

    final displayMethod = claimInfoDto.displayMethod;
    await Future.wait([
      _remoteIden3commDataSource
          .fetchSchema(url: claimInfoDto.credentialSchema.id)
          .then((schema) {
        claimDto.schema = schema;
        return claimDto;
      }).catchError((_) => claimDto),
      if (displayMethod != null)
        _remoteIden3commDataSource
            .fetchDisplayType(url: displayMethod.id)
            .then((displayType) {
          displayType['type'] = displayMethod.type;
          claimDto.displayType = displayType;
          return claimDto;
        }).catchError((_) {
          return claimDto;
        }),
    ]);

    return _claimMapper.mapFrom(claimDto);
  }
}
