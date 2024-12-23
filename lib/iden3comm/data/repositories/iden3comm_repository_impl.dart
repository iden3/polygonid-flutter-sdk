import 'dart:convert';

import 'package:polygonid_flutter_sdk/common/domain/entities/media_type.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/data_sources/iden3_message_data_source.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/data_sources/lib_pidcore_iden3comm_data_source.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/data_sources/remote_iden3comm_data_source.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/dtos/authorization/response/auth_body_did_doc_response_dto.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/dtos/authorization/response/auth_body_response_dto.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/dtos/authorization/response/auth_response_dto.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/mappers/jwz_mapper.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/authorization/request/auth_request_iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/response/jwz.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/proof/response/iden3comm_proof_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/exceptions/iden3comm_exceptions.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/repositories/iden3comm_repository.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_iden3message_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/data/mappers/q_mapper.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/identity_entity.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/gist_mtproof_entity.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/mtproof_dto.dart';
import 'package:poseidon/poseidon.dart';
import 'package:uuid/uuid.dart';

class Iden3commRepositoryImpl extends Iden3commRepository {
  final Iden3MessageDataSource _iden3messageDataSource;
  final RemoteIden3commDataSource _remoteIden3commDataSource;
  final LibPolygonIdCoreIden3commDataSource
      _libPolygonIdCoreIden3commDataSource;
  final QMapper _qMapper;
  final JWZMapper _jwzMapper;
  final GetIden3MessageUseCase _getIden3MessageUseCase;
  final StacktraceManager _stacktraceManager;

  Iden3commRepositoryImpl(
    this._iden3messageDataSource,
    this._remoteIden3commDataSource,
    this._libPolygonIdCoreIden3commDataSource,
    this._qMapper,
    this._jwzMapper,
    this._getIden3MessageUseCase,
    this._stacktraceManager,
  );

  @override
  Future<Iden3MessageEntity?> authenticate({
    required AuthIden3MessageEntity request,
    required String authToken,
  }) async {
    String? url = request.body.callbackUrl;

    if (url == null || url.isEmpty) {
      _stacktraceManager.addError("Callback url is null or empty");
      throw NullAuthenticateCallbackException(
        authRequest: request,
        errorMessage: "Callback url is null or empty",
      );
    }

    final response = await _remoteIden3commDataSource.authWithToken(
      token: authToken,
      url: url,
    );

    if (response.data.isEmpty) {
      return null;
    }

    try {
      final messageJson = jsonDecode(response.data);
      if (messageJson is! Map<String, dynamic> || messageJson.isEmpty) {
        return null;
      }

      final nextRequest = await _getIden3MessageUseCase.execute(
        param: jsonEncode(messageJson),
      );

      return nextRequest;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String> encodeJWZ({required JWZEntity jwz}) {
    return Future.value(_jwzMapper.mapFrom(jwz));
  }

  @override
  Future<String> getAuthResponse({
    required String did,
    required AuthIden3MessageEntity request,
    required List<Iden3commProofEntity> scope,
    String? pushUrl,
    String? pushToken,
    String? packageName,
  }) async {
    AuthBodyDidDocResponseDTO? didDocResponse;
    if (pushUrl != null &&
        pushUrl.isNotEmpty &&
        pushToken != null &&
        pushToken.isNotEmpty &&
        packageName != null &&
        packageName.isNotEmpty) {
      didDocResponse = await _iden3messageDataSource.getDidDocResponse(
          pushUrl, did, pushToken, packageName);
    }

    AuthResponseDTO authResponse = AuthResponseDTO(
      id: const Uuid().v4(),
      thid: request.thid,
      to: request.from,
      from: did,
      typ: MediaType.ZKPMessage.name,
      //request
      //.typ, // "application/iden3-zkp-json", // TODO if it's plain json typ: "application/iden3comm-plain-json",
      type: Iden3MessageType.authResponse.type,
      body: AuthBodyResponseDTO(
        message: request.body.message,
        scope: scope,
        did_doc: didDocResponse,
      ),
    );
    return jsonEncode(authResponse.toJson());
  }

  @override
  Future<String> getAuthInputs({
    required String genesisDid,
    required BigInt profileNonce,
    required String challenge,
    required List<String> authClaim,
    required IdentityEntity identity,
    required String signature,
    required MTProofEntity incProof,
    required MTProofEntity nonRevProof,
    required GistMTProofEntity gistProof,
    required Map<String, dynamic> treeState,
  }) {
    return _libPolygonIdCoreIden3commDataSource.getAuthInputs(
      genesisDid: genesisDid,
      profileNonce: profileNonce,
      authClaim: authClaim,
      incProof: incProof.toJson(),
      nonRevProof: nonRevProof.toJson(),
      gistProof: gistProof.toJson(),
      treeState: treeState,
      challenge: challenge,
      signature: signature,
    );
  }

  @override
  Future<String> getChallenge({required String message}) async {
    final q = _qMapper.mapFrom(message);
    return poseidon1([BigInt.parse(q)]).toString();
  }

  @override
  Future<void> cleanSchemaCache() async {
    return _remoteIden3commDataSource.cleanSchemaCache();
  }
}
