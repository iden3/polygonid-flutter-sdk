import 'dart:convert';

import 'package:polygonid_flutter_sdk/common/domain/domain_constants.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/media_type.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/credential/data/dtos/claim_info_dto.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/credential/domain/exceptions/credential_exceptions.dart';
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/remove_claims_use_case.dart';
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/save_claims_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/credential/request/credential_refresh_iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/repositories/iden3comm_credential_repository.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_auth_token_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/get_identity_use_case.dart';
import 'package:uuid/uuid.dart';

class RefreshCredentialUseCase
    extends FutureUseCase<RefreshCredentialParam, ClaimEntity> {
  final StacktraceManager _stacktraceManager;
  final GetIdentityUseCase _getIdentityUseCase;
  final GetAuthTokenUseCase _getAuthTokenUseCase;
  final Iden3commCredentialRepository _iden3commCredentialRepository;
  final RemoveClaimsUseCase _removeClaimsUseCase;
  final SaveClaimsUseCase _saveClaimsUseCase;

  RefreshCredentialUseCase(
    this._stacktraceManager,
    this._getIdentityUseCase,
    this._getAuthTokenUseCase,
    this._iden3commCredentialRepository,
    this._removeClaimsUseCase,
    this._saveClaimsUseCase,
  );

  @override
  Future<ClaimEntity> execute({required RefreshCredentialParam param}) async {
    var identityEntity = await _getIdentityUseCase.execute(
        param: GetIdentityParam(
            genesisDid: param.genesisDid, privateKey: param.privateKey));

    BigInt claimSubjectProfileNonce = identityEntity.profiles.keys.firstWhere(
        (k) => identityEntity.profiles[k] == param.credential.did,
        orElse: () => GENESIS_PROFILE_NONCE);

    if (!param.credential.info.containsKey("refreshService") ||
        param.credential.info["refreshService"] == null) {
      _stacktraceManager
          .addError("[RefreshCredentialUseCase] Refresh service not found");
      throw RefreshCredentialException(
          errorMessage: "Refresh service not found");
    }

    RefreshServiceDTO refreshService =
        RefreshServiceDTO.fromJson(param.credential.info["refreshService"]);
    String refreshServiceUrl = refreshService.id;
    String id = const Uuid().v4();
    CredentialRefreshIden3MessageEntity credentialRefreshEntity =
        CredentialRefreshIden3MessageEntity(
      id: id,
      typ: MediaType.PlainMessage.name,
      type: Iden3MessageType.credentialRefresh.type,
      thid: id,
      body: CredentialRefreshBodyRequest(
        param.credential.id,
        "expired",
      ),
      from: param.credential.did,
      to: param.credential.issuer,
    );

    String authToken = await _getAuthTokenUseCase.execute(
      param: GetAuthTokenParam(
        genesisDid: param.genesisDid,
        profileNonce: claimSubjectProfileNonce,
        privateKey: param.privateKey,
        message: jsonEncode(credentialRefreshEntity),
      ),
    );

    ClaimEntity claimEntity;

    claimEntity = await _iden3commCredentialRepository.refreshCredential(
      authToken: authToken,
      url: refreshServiceUrl,
      profileDid: param.credential.did,
    );

    if (claimEntity.id != param.credential.id) {
      await _removeClaimsUseCase.execute(
        param: RemoveClaimsParam(
          claimIds: [param.credential.id],
          genesisDid: param.genesisDid,
          privateKey: param.privateKey,
        ),
      );
    }

    await _saveClaimsUseCase.execute(
      param: SaveClaimsParam(
        claims: [claimEntity],
        genesisDid: param.genesisDid,
        privateKey: param.privateKey,
      ),
    );

    return claimEntity;
  }
}

class RefreshCredentialParam {
  final ClaimEntity credential;
  final String genesisDid;
  final String privateKey;

  RefreshCredentialParam({
    required this.credential,
    required this.genesisDid,
    required this.privateKey,
  });
}
