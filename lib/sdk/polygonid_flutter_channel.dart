import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/env_config_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/env_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/filter_entity.dart';
import 'package:polygonid_flutter_sdk/common/utils/credential_sort_order.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/authorization/request/auth_request_iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/credential/request/base.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/interaction/interaction_base_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/interaction/interaction_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/credential/request/offer_iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/proof/response/iden3comm_proof_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/did_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/identity_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/private_identity_entity.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/circuits_to_download_param.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/mtproof_dto.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/circuit_data_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/download_info_entity.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/gist_mtproof_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/zkproof_entity.dart';
import 'package:polygonid_flutter_sdk/sdk/credential.dart';
import 'package:polygonid_flutter_sdk/sdk/iden3comm.dart';
import 'package:polygonid_flutter_sdk/sdk/identity.dart';
import 'package:polygonid_flutter_sdk/sdk/polygon_id_sdk.dart';
import 'package:polygonid_flutter_sdk/sdk/proof.dart';

const downloadCircuitsName = 'downloadCircuits';
const proofGenerationStepsName = 'proofGenerationSteps';

/// PolygonIdSdh channel, to be able to use the SDK in native code
/// We are implementing the interfaces of the SDK just to be sure nothing is missing
@injectable
class PolygonIdFlutterChannel
    implements
        PolygonIdSdkIden3comm,
        PolygonIdSdkIdentity,
        PolygonIdSdkCredential,
        PolygonIdSdkProof {
  final PolygonIdSdk _polygonIdSdk;
  final MethodChannel _methodChannel;
  final Map<String, StreamSubscription> _streamSubscriptions = {};

  Future<void> _listen(
      {required String name,
      required Stream stream,
      Function? onError,
      void Function()? onDone,
      bool? cancelOnError}) {
    return _addSubscription(
        name,
        stream.listen(
            (event) => _methodChannel.invokeMethod('onStreamData', {
                  'key': name,
                  'data': jsonEncode(event),
                }),
            onError: onError,
            onDone: onDone,
            cancelOnError: cancelOnError));
  }

  Future<void> _addSubscription(
      String name, StreamSubscription subscription) async {
    await _closeSubscription(name);
    _streamSubscriptions[name] = subscription;
  }

  Future<void> _closeSubscription(String name) async {
    await _streamSubscriptions[name]?.cancel();
    _streamSubscriptions.remove(name);
  }

  PolygonIdFlutterChannel(this._polygonIdSdk, this._methodChannel) {
    _methodChannel.setMethodCallHandler((call) {
      logger().d(call.method);

      switch (call.method) {
        /// Internal
        case 'closeStream':
          return call.arguments['key'] != null
              ? _closeSubscription(call.arguments['key'] as String)
              : Future.value();

        /// SDK
        case 'init':
          return PolygonIdSdk.init(
              env: call.arguments['env'] != null
                  ? EnvEntity.fromJson(jsonDecode(call.arguments['env']))
                  : null);

        case 'setEnv':
          return _polygonIdSdk.setEnv(
              env: EnvEntity.fromJson(jsonDecode(call.arguments['env'])));

        case 'getEnv':
          return _polygonIdSdk.getEnv().then((env) => jsonEncode(env));

        case 'setSelectedChain':
          return _polygonIdSdk.setSelectedChain(
              chainConfigId: call.arguments['chainConfigId'] as String);

        case 'getSelectedChain':
          return _polygonIdSdk
              .getSelectedChain()
              .then((chain) => jsonEncode(chain));

        case 'switchLog':
          return _polygonIdSdk.switchLog(enabled: call.arguments['enabled']);

        /// Iden3comm
        case 'addInteraction':
          Map<String, dynamic> json = jsonDecode(call.arguments['interaction']);
          InteractionBaseEntity interaction;

          try {
            interaction = InteractionEntity.fromJson(json);
          } catch (e) {
            interaction = InteractionBaseEntity.fromJson(json);
          }

          return addInteraction(
                  interaction: interaction,
                  genesisDid: call.arguments['genesisDid'] as String,
                  privateKey: call.arguments['privateKey'] as String)
              .then((interaction) => jsonEncode(interaction.toJson()));

        case 'authenticate':
          return authenticate(
              message: AuthIden3MessageEntity.fromJson(
                  jsonDecode(call.arguments['message'])),
              genesisDid: call.arguments['genesisDid'] as String,
              profileNonce: BigInt.tryParse(
                  call.arguments['profileNonce'] as String? ?? ''),
              privateKey: call.arguments['privateKey'] as String,
              pushToken: call.arguments['pushToken'] as String?);

        case 'fetchAndSaveClaims':
          return fetchAndSaveClaims(
                  message: OfferIden3MessageEntity.fromJson(
                      jsonDecode(call.arguments['message'])),
                  genesisDid: call.arguments['genesisDid'] as String,
                  profileNonce: BigInt.tryParse(
                      call.arguments['profileNonce'] as String? ?? ''),
                  privateKey: call.arguments['privateKey'] as String)
              .then((claims) =>
                  claims.map((claim) => jsonEncode(claim)).toList());

        case 'fetchOnchainClaims':
          return fetchOnchainClaims(
                  contractAddress: call.arguments['contractAddress'] as String,
                  genesisDid: call.arguments['genesisDid'] as String,
                  profileNonce: BigInt.tryParse(
                      call.arguments['profileNonce'] as String? ?? ''),
                  privateKey: call.arguments['privateKey'] as String)
              .then((claims) =>
                  claims.map((claim) => jsonEncode(claim)).toList());

        case 'getClaimsFromIden3Message':
          throw UnimplementedError();

        case 'getFilters':
          return getIden3Message(message: call.arguments['message'])
              .then((message) => getFilters(message: message))
              .then((filters) =>
                  filters.map((filter) => jsonEncode(filter)).toList());

        case 'getIden3Message':
          return getIden3Message(message: call.arguments['message'])
              .then((message) => jsonEncode(message));

        case 'getSchemas':
          return getIden3Message(message: call.arguments['message']).then(
              (message) => getSchemas(message: message)
                  .then((schemas) => jsonEncode(schemas)));

        case 'getInteractions':
          return getInteractions(
            genesisDid: call.arguments['genesisDid'] as String?,
            profileNonce: BigInt.tryParse(
                call.arguments['profileNonce'] as String? ?? ''),
            privateKey: call.arguments['privateKey'] as String?,
            types: (call.arguments['types'] as List?)
                ?.map((type) => InteractionType.values
                    .firstWhere((interactionType) => interactionType == type))
                .toList(),
            states: (call.arguments['states'] as List?)
                ?.map((state) => InteractionState.values.firstWhere(
                    (interactionState) => interactionState == state))
                .toList(),
            filters: (call.arguments['filters'] as List?)
                ?.map((filter) => FilterEntity.fromJson(jsonDecode(filter)))
                .toList(),
          ).then((interactions) => interactions
              .map((interaction) => jsonEncode(interaction.toJson()))
              .toList());

        case 'getProofs':
          return getIden3Message(message: call.arguments['message'])
              .then((message) => getProofs(
                  message: message,
                  genesisDid: call.arguments['genesisDid'] as String,
                  profileNonce: BigInt.tryParse(
                      call.arguments['profileNonce'] as String? ?? ''),
                  privateKey: call.arguments['privateKey'] as String,
                  challenge: call.arguments['challenge'] as String?))
              .then((message) => jsonEncode(message));

        case 'removeInteractions':
          return removeInteractions(
              genesisDid: call.arguments['genesisDid'] as String?,
              privateKey: call.arguments['privateKey'] as String?,
              ids: call.arguments['ids'] as List<String>);

        case 'updateInteraction':
          return updateInteraction(
                  id: call.arguments['id'] as String,
                  genesisDid: call.arguments['genesisDid'] as String?,
                  privateKey: call.arguments['privateKey'] as String?,
                  state: call.arguments['state'] != null
                      ? InteractionState.values.firstWhere((interactionState) =>
                          interactionState == call.arguments['state'] ||
                          interactionState.toString() ==
                              call.arguments['state'].toString() ||
                          interactionState.name ==
                              call.arguments['state'].toString())
                      : null)
              .then((interaction) => jsonEncode(interaction.toJson()));

        /// Identity
        case 'addIdentity':
          return addIdentity(secret: call.arguments['secret'] as String?)
              .then((identity) => jsonEncode(identity.toJson()));

        case 'addProfile':
          return addProfile(
            genesisDid: call.arguments['genesisDid'] as String,
            privateKey: call.arguments['privateKey'] as String,
            profileNonce:
                BigInt.parse(call.arguments['profileNonce'] as String),
          );

        case 'backupIdentity':
          return backupIdentity(
              genesisDid: call.arguments['genesisDid'] as String,
              privateKey: call.arguments['privateKey'] as String);

        case 'checkIdentityValidity':
          return checkIdentityValidity(
              secret: call.arguments['secret'] as String);

        case 'getDidEntity':
          return getDidEntity(did: call.arguments['did'] as String)
              .then((DidEntity did) => jsonEncode(did.toJson()));

        case 'getDidIdentifier':
          return getDidIdentifier(
              privateKey: call.arguments['privateKey'] as String,
              blockchain: call.arguments['blockchain'] as String,
              network: call.arguments['network'] as String,
              profileNonce: BigInt.tryParse(
                  call.arguments['profileNonce'] as String? ?? ''));

        case 'getIdentities':
          return getIdentities().then((identities) => identities
              .map((identity) => jsonEncode(identity.toJson()))
              .toList());

        case 'getIdentity':
          return getIdentity(
                  genesisDid: call.arguments['genesisDid'] as String,
                  privateKey: call.arguments['privateKey'] as String?)
              .then((identity) => jsonEncode(identity.toJson()));

        case 'getPrivateKey':
          return getPrivateKey(secret: call.arguments['secret'] as String);

        case 'getProfiles':
          return getProfiles(
                  genesisDid: call.arguments['genesisDid'] as String,
                  privateKey: call.arguments['privateKey'] as String)
              .then((profiles) => profiles
                  .map((key, value) => MapEntry(key.toString(), value)));

        case 'getState':
          return getState(did: call.arguments['did'] as String);

        case 'removeIdentity':
          return removeIdentity(
              genesisDid: call.arguments['genesisDid'] as String,
              privateKey: call.arguments['privateKey'] as String);

        case 'removeProfile':
          return removeProfile(
              genesisDid: call.arguments['genesisDid'] as String,
              privateKey: call.arguments['privateKey'] as String,
              profileNonce:
                  BigInt.parse(call.arguments['profileNonce'] as String));

        case 'restoreIdentity':
          return restoreIdentity(
                  genesisDid: call.arguments['genesisDid'] as String,
                  privateKey: call.arguments['privateKey'] as String,
                  encryptedDb: call.arguments['encryptedDb'] as String?)
              .then((identity) => jsonEncode(identity));

        case 'sign':
          return sign(
              message: call.arguments['message'] as String,
              privateKey: call.arguments['privateKey'] as String);

        /// Credential
        case 'getClaims':
          return getClaims(
                  filters: (call.arguments['filters'] as List?)
                      ?.map((filter) =>
                          FilterEntity.fromJson(jsonDecode(filter as String)))
                      .toList(),
                  genesisDid: call.arguments['genesisDid'] as String,
                  privateKey: call.arguments['privateKey'] as String)
              .then((claims) =>
                  claims.map((claim) => jsonEncode(claim.toJson())).toList());

        case 'getClaimsByIds':
          return getClaimsByIds(
                  claimIds: (call.arguments['claimIds'] as List)
                      .map((e) => e as String)
                      .toList(),
                  genesisDid: call.arguments['genesisDid'] as String,
                  privateKey: call.arguments['privateKey'] as String)
              .then((claims) =>
                  claims.map((claim) => jsonEncode(claim)).toList());

        case 'getClaimRevocationStatus':
          return getClaimRevocationStatus(
                  claimId: call.arguments['claimId'] as String,
                  genesisDid: call.arguments['genesisDid'] as String,
                  privateKey: call.arguments['privateKey'] as String)
              .then((revStatus) => jsonEncode(revStatus));

        case 'removeClaim':
          return removeClaim(
              claimId: call.arguments['claimId'] as String,
              genesisDid: call.arguments['genesisDid'] as String,
              privateKey: call.arguments['privateKey'] as String);

        case 'removeClaims':
          return removeClaims(
              claimIds: (call.arguments['claimIds'] as List)
                  .map((e) => e as String)
                  .toList(),
              genesisDid: call.arguments['genesisDid'] as String,
              privateKey: call.arguments['privateKey'] as String);

        case 'saveClaims':
          return saveClaims(
                  claims: (call.arguments['claims'] as List)
                      .map((claim) => ClaimEntity.fromJson(jsonDecode(claim)))
                      .toList(),
                  genesisDid: call.arguments['genesisDid'] as String,
                  privateKey: call.arguments['privateKey'] as String)
              .then((claims) =>
                  claims.map((claim) => jsonEncode(claim)).toList());

        case 'updateClaim':
          return updateClaim(
                  claimId: call.arguments['claimId'] as String,
                  issuer: call.arguments['issuer'] as String?,
                  genesisDid: call.arguments['genesisDid'] as String,
                  state: call.arguments['state'] != null
                      ? ClaimState.values.firstWhere(
                          (claimState) => claimState == call.arguments['state'])
                      : null,
                  expiration: call.arguments['expiration'] as String?,
                  type: call.arguments['type'] as String?,
                  data: call.arguments['data'] as Map<String, dynamic>?,
                  privateKey: call.arguments['privateKey'] as String)
              .then((claim) => jsonEncode(claim));

        case 'startDownloadCircuits':
          return _listen(
              name: downloadCircuitsName,
              stream: initCircuitsDownloadAndGetInfoStream(
                circuitsToDownload:
                    (call.arguments['circuitsToDownload'] as List)
                        .map((e) => CircuitsToDownloadParam.fromJson(
                            jsonDecode(e as String)))
                        .toList(),
              ),
              onDone: () {
                _closeSubscription('downloadCircuits')
                    .then((_) => downloadCircuitsName);
              });

        case 'isAlreadyDownloadedCircuitsFromServer':
          return isAlreadyDownloadedCircuitsFromServer(
              circuitsFileName: call.arguments['circuitsFileName']);

        case 'cancelDownloadCircuits':
          return cancelDownloadCircuits()
              .then((_) => _closeSubscription('downloadCircuits'));

        case 'proofGenerationStepsStream':
          return _listen(
              name: proofGenerationStepsName,
              stream: proofGenerationStepsStream(),
              onDone: () {
                _closeSubscription('proofGenerationSteps')
                    .then((_) => proofGenerationStepsName);
              });

        case 'prove':
          // TODO: finish this params
          return prove(
            identifier: call.arguments['identifier'] as String,
            profileNonce:
                BigInt.parse(call.arguments['profileNonce'] as String),
            claimSubjectProfileNonce: BigInt.parse(
                call.arguments['claimSubjectProfileNonce'] as String),
            credential: ClaimEntity.fromJson(
                jsonDecode(call.arguments['credential'] as String)),
            circuitData: CircuitDataEntity.fromJson(
                jsonDecode(call.arguments['circuitData'] as String)),
            proofScopeRequest:
                call.arguments['proofScopeRequest'] as Map<String, dynamic>,
            authClaim: (call.arguments['authClaim'] as List?)
                ?.map((e) => e as String)
                .toList(),
            signature: call.arguments['signature'] as String?,
            challenge: call.arguments['challenge'] as String?,
            treeState: call.arguments['treeState'] as Map<String, dynamic>?,
          ).then((proof) => jsonEncode(proof));

        default:
          throw PlatformException(
              code: 'not_implemented',
              message: 'Method ${call.method} not implemented');
      }
    });
  }

  /// Iden3comm
  @override
  Future<InteractionBaseEntity> addInteraction({
    required InteractionBaseEntity interaction,
    required String genesisDid,
    required String privateKey,
  }) {
    return _polygonIdSdk.iden3comm.addInteraction(
      interaction: interaction,
      genesisDid: genesisDid,
      privateKey: privateKey,
    );
  }

  @override
  Future<Iden3MessageEntity?> authenticate({
    required Iden3MessageEntity message,
    required String genesisDid,
    BigInt? profileNonce,
    required String privateKey,
    String? pushToken,
    Map<int, Map<String, dynamic>>? nonRevocationProofs,
    String? challenge,
  }) {
    return _polygonIdSdk.iden3comm.authenticate(
      message: message,
      genesisDid: genesisDid,
      profileNonce: profileNonce,
      privateKey: privateKey,
      pushToken: pushToken,
      nonRevocationProofs: nonRevocationProofs,
      challenge: challenge,
    );
  }

  @override
  Future<List<ClaimEntity>> fetchAndSaveClaims({
    required CredentialOfferMessageEntity message,
    required String genesisDid,
    BigInt? profileNonce,
    required String privateKey,
  }) {
    return _polygonIdSdk.iden3comm.fetchAndSaveClaims(
        message: message,
        genesisDid: genesisDid,
        profileNonce: profileNonce,
        privateKey: privateKey);
  }

  @override
  Future<List<ClaimEntity>> fetchOnchainClaims({
    required String contractAddress,
    required String genesisDid,
    BigInt? profileNonce,
    required String privateKey,
  }) {
    return _polygonIdSdk.iden3comm.fetchOnchainClaims(
      contractAddress: contractAddress,
      genesisDid: genesisDid,
      profileNonce: profileNonce,
      privateKey: privateKey,
    );
  }

  @override
  Future<List<ClaimEntity?>> getClaimsFromIden3Message({
    required Iden3MessageEntity message,
    required String genesisDid,
    BigInt? profileNonce,
    required String privateKey,
    Map<int, Map<String, dynamic>>? nonRevocationProofs,
    List<CredentialSortOrder> sortOrder = const [],
  }) {
    return _polygonIdSdk.iden3comm.getClaimsFromIden3Message(
      message: message,
      genesisDid: genesisDid,
      profileNonce: profileNonce,
      privateKey: privateKey,
      nonRevocationProofs: nonRevocationProofs,
      sortOrder: sortOrder,
    );
  }

  @override
  Future<List<int>> getClaimsRevNonceFromIden3Message(
      {required Iden3MessageEntity message,
      required String genesisDid,
      BigInt? profileNonce,
      required String privateKey}) {
    return _polygonIdSdk.iden3comm.getClaimsRevNonceFromIden3Message(
      message: message,
      genesisDid: genesisDid,
      profileNonce: profileNonce,
      privateKey: privateKey,
    );
  }

  @override
  Future<List<FilterEntity>> getFilters({required Iden3MessageEntity message}) {
    return _polygonIdSdk.iden3comm.getFilters(message: message);
  }

  @override
  Future<Iden3MessageEntity> getIden3Message({required String message}) {
    return _polygonIdSdk.iden3comm.getIden3Message(message: message);
  }

  @override
  Future<List<Map<String, dynamic>>> getSchemas(
      {required Iden3MessageEntity message}) {
    return _polygonIdSdk.iden3comm.getSchemas(message: message);
  }

  @override
  Future<Map<String, dynamic>> fetchSchema({required String schemaUrl}) {
    return _polygonIdSdk.iden3comm.fetchSchema(schemaUrl: schemaUrl);
  }

  @override
  Future<List<InteractionBaseEntity>> getInteractions(
      {String? genesisDid,
      BigInt? profileNonce,
      String? privateKey,
      List<InteractionType>? types,
      List<InteractionState>? states,
      List<FilterEntity>? filters}) {
    return _polygonIdSdk.iden3comm.getInteractions(
        genesisDid: genesisDid,
        profileNonce: profileNonce,
        privateKey: privateKey,
        types: types,
        states: states,
        filters: filters);
  }

  @override
  Future<List<Iden3commProofEntity>> getProofs({
    required Iden3MessageEntity message,
    required String genesisDid,
    BigInt? profileNonce,
    required String privateKey,
    String? challenge,
    EnvConfigEntity? config,
    Map<int, Map<String, dynamic>>? nonRevocationProofs,
    Map<String, dynamic>? transactionData,
  }) {
    return _polygonIdSdk.iden3comm.getProofs(
      message: message,
      genesisDid: genesisDid,
      profileNonce: profileNonce,
      privateKey: privateKey,
      challenge: challenge,
      config: config,
      nonRevocationProofs: nonRevocationProofs,
      transactionData: transactionData,
    );
  }

  @override
  Future<void> removeInteractions(
      {String? genesisDid, String? privateKey, required List<String> ids}) {
    return _polygonIdSdk.iden3comm.removeInteractions(
        genesisDid: genesisDid, privateKey: privateKey, ids: ids);
  }

  @override
  Future<InteractionBaseEntity> updateInteraction(
      {required String id,
      String? genesisDid,
      BigInt? profileNonce,
      String? privateKey,
      InteractionState? state}) {
    return _polygonIdSdk.iden3comm.updateInteraction(
        id: id,
        genesisDid: genesisDid,
        profileNonce: profileNonce,
        privateKey: privateKey,
        state: state);
  }

  /// Identity
  @override
  Future<PrivateIdentityEntity> addIdentity({String? secret}) {
    return _polygonIdSdk.identity.addIdentity(secret: secret);
  }

  @override
  Future<void> addProfile({
    required String genesisDid,
    required String privateKey,
    required BigInt profileNonce,
    String? existingProfileDid,
  }) {
    return _polygonIdSdk.identity.addProfile(
      genesisDid: genesisDid,
      privateKey: privateKey,
      profileNonce: profileNonce,
      existingProfileDid: existingProfileDid,
    );
  }

  @override
  Future<String> backupIdentity(
      {required String genesisDid, required String privateKey}) {
    return _polygonIdSdk.identity
        .backupIdentity(genesisDid: genesisDid, privateKey: privateKey);
  }

  @override
  Future<void> checkIdentityValidity({required String secret}) {
    return _polygonIdSdk.identity.checkIdentityValidity(secret: secret);
  }

  @override
  Future<DidEntity> getDidEntity({required String did}) {
    return _polygonIdSdk.identity.getDidEntity(did: did);
  }

  @override
  Future<String> getDidIdentifier(
      {required String privateKey,
      required String blockchain,
      required String network,
      BigInt? profileNonce}) {
    return _polygonIdSdk.identity.getDidIdentifier(
        privateKey: privateKey,
        blockchain: blockchain,
        network: network,
        profileNonce: profileNonce);
  }

  @override
  Future<List<IdentityEntity>> getIdentities() {
    return _polygonIdSdk.identity.getIdentities();
  }

  @override
  Future<IdentityEntity> getIdentity(
      {required String genesisDid, String? privateKey}) {
    return _polygonIdSdk.identity
        .getIdentity(genesisDid: genesisDid, privateKey: privateKey);
  }

  @override
  Future<String> getPrivateKey({required String secret}) {
    return _polygonIdSdk.identity.getPrivateKey(secret: secret);
  }

  @override
  Future<Map<BigInt, String>> getProfiles(
      {required String genesisDid, required String privateKey}) {
    return _polygonIdSdk.identity
        .getProfiles(genesisDid: genesisDid, privateKey: privateKey);
  }

  @override
  Future<String> getState({required String did}) {
    return _polygonIdSdk.identity.getState(did: did);
  }

  @override
  Future<void> removeIdentity(
      {required String genesisDid, required String privateKey}) {
    return _polygonIdSdk.identity
        .removeIdentity(genesisDid: genesisDid, privateKey: privateKey);
  }

  @override
  Future<void> removeProfile(
      {required String genesisDid,
      required String privateKey,
      required BigInt profileNonce}) {
    return _polygonIdSdk.identity.removeProfile(
        genesisDid: genesisDid,
        privateKey: privateKey,
        profileNonce: profileNonce);
  }

  @override
  Future<PrivateIdentityEntity> restoreIdentity(
      {required String genesisDid,
      required String privateKey,
      String? encryptedDb}) {
    return _polygonIdSdk.identity.restoreIdentity(
        genesisDid: genesisDid,
        privateKey: privateKey,
        encryptedDb: encryptedDb);
  }

  @override
  Future<String> sign({required String privateKey, required String message}) {
    return _polygonIdSdk.identity
        .sign(privateKey: privateKey, message: message);
  }

  /// Credential
  @override
  Future<List<ClaimEntity>> getClaims({
    List<FilterEntity>? filters,
    required String genesisDid,
    required String privateKey,
    List<CredentialSortOrder> credentialSortOrderList = const [],
  }) {
    return _polygonIdSdk.credential.getClaims(
      filters: filters,
      genesisDid: genesisDid,
      privateKey: privateKey,
      credentialSortOrderList: credentialSortOrderList,
    );
  }

  @override
  Future<List<ClaimEntity>> getClaimsByIds(
      {required List<String> claimIds,
      required String genesisDid,
      required String privateKey}) {
    return _polygonIdSdk.credential.getClaimsByIds(
        claimIds: claimIds, genesisDid: genesisDid, privateKey: privateKey);
  }

  @override
  Future<Map<String, dynamic>> getClaimRevocationStatus(
      {required String claimId,
      required String genesisDid,
      required String privateKey}) {
    return _polygonIdSdk.credential.getClaimRevocationStatus(
        claimId: claimId, genesisDid: genesisDid, privateKey: privateKey);
  }

  @override
  Future<void> removeClaim(
      {required String claimId,
      required String genesisDid,
      required String privateKey}) {
    return _polygonIdSdk.credential.removeClaim(
        claimId: claimId, genesisDid: genesisDid, privateKey: privateKey);
  }

  @override
  Future<void> removeClaims(
      {required List<String> claimIds,
      required String genesisDid,
      required String privateKey}) {
    return _polygonIdSdk.credential.removeClaims(
        claimIds: claimIds, genesisDid: genesisDid, privateKey: privateKey);
  }

  @override
  Future<List<ClaimEntity>> saveClaims(
      {required List<ClaimEntity> claims,
      required String genesisDid,
      required String privateKey}) {
    return _polygonIdSdk.credential.saveClaims(
        claims: claims, genesisDid: genesisDid, privateKey: privateKey);
  }

  @override
  Future<ClaimEntity> updateClaim(
      {required String claimId,
      String? issuer,
      required String genesisDid,
      ClaimState? state,
      String? expiration,
      String? type,
      Map<String, dynamic>? data,
      required String privateKey}) {
    return _polygonIdSdk.credential.updateClaim(
        claimId: claimId,
        issuer: issuer,
        genesisDid: genesisDid,
        state: state,
        expiration: expiration,
        type: type,
        data: data,
        privateKey: privateKey);
  }

  /// Proof
  @override
  Stream<DownloadInfo> initCircuitsDownloadAndGetInfoStream({
    required List<CircuitsToDownloadParam> circuitsToDownload,
  }) {
    return _polygonIdSdk.proof.initCircuitsDownloadAndGetInfoStream(
      circuitsToDownload: circuitsToDownload,
    );
  }

  @override
  Future<bool> isAlreadyDownloadedCircuitsFromServer(
      {required String circuitsFileName}) {
    return _polygonIdSdk.proof.isAlreadyDownloadedCircuitsFromServer(
        circuitsFileName: circuitsFileName);
  }

  @override
  Future<void> cancelDownloadCircuits() {
    return _polygonIdSdk.proof.cancelDownloadCircuits();
  }

  @override
  Stream<String> proofGenerationStepsStream() {
    return _polygonIdSdk.proof.proofGenerationStepsStream();
  }

  @override
  Future<ZKProofEntity> prove({
    required String identifier,
    required BigInt profileNonce,
    required BigInt claimSubjectProfileNonce,
    required ClaimEntity credential,
    required CircuitDataEntity circuitData,
    required Map<String, dynamic> proofScopeRequest,
    List<String>? authClaim,
    MTProofEntity? incProof,
    MTProofEntity? nonRevProof,
    GistMTProofEntity? gistProof,
    Map<String, dynamic>? treeState,
    String? challenge,
    String? signature,
    Map<String, dynamic>? config,
  }) {
    return _polygonIdSdk.proof.prove(
        identifier: identifier,
        profileNonce: profileNonce,
        claimSubjectProfileNonce: claimSubjectProfileNonce,
        credential: credential,
        circuitData: circuitData,
        proofScopeRequest: proofScopeRequest,
        challenge: challenge,
        signature: signature,
        authClaim: authClaim,
        incProof: incProof,
        nonRevProof: nonRevProof,
        gistProof: gistProof,
        treeState: treeState,
        config: config);
  }

  @override
  Future<void> cleanSchemaCache() {
    // TODO: implement cleanSchemaCache
    throw UnimplementedError();
  }

  @override
  Future<void> addDidProfileInfo({
    required String did,
    required String privateKey,
    required String interactedWithDid,
    required Map<String, dynamic> info,
  }) {
    // TODO: implement addDidProfileInfo
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getDidProfileInfo({
    required String did,
    required String privateKey,
    required String interactedWithDid,
  }) {
    // TODO: implement getDidProfileInfo
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> getDidProfileInfoList({
    required String did,
    required String privateKey,
    required List<FilterEntity>? filters,
  }) {
    // TODO: implement getDidProfileInfoList
    throw UnimplementedError();
  }

  @override
  Future<void> removeDidProfileInfo({
    required String did,
    required String privateKey,
    required String interactedWithDid,
  }) {
    // TODO: implement removeDidProfileInfo
    throw UnimplementedError();
  }

  @override
  Future<void> restoreProfiles({
    required String genesisDid,
    required String privateKey,
  }) {
    // TODO: implement restoreProfiles
    throw UnimplementedError();
  }

  @override
  Future<ClaimEntity> refreshCredential({
    required String genesisDid,
    required String privateKey,
    required ClaimEntity credential,
  }) {
    // TODO: implement refreshCredential
    throw UnimplementedError();
  }

  @override
  Future<ClaimEntity>? getCredentialById(
      {required String credentialId,
      required String genesisDid,
      required String privateKey}) {
    // TODO: implement getCredentialById
    throw UnimplementedError();
  }

  @override
  Future<ClaimEntity>? getCredentialByPartialId({
    required String partialCredentialId,
    required String genesisDid,
    required String privateKey,
  }) {
    // TODO: implement getCredentialByPartialId
    throw UnimplementedError();
  }

  @override
  Future<void> cacheCredential(
      {required ClaimEntity credential, EnvConfigEntity? configParam}) {
    // TODO: implement cacheCredential
    throw UnimplementedError();
  }

  @override
  Future<void> cacheCredentials(
      {required List<ClaimEntity> credentials, EnvConfigEntity? configParam}) {
    // TODO: implement cacheCredentials
    throw UnimplementedError();
  }

  @override
  Future<List<ClaimEntity>> fetchCredentials(
      {required CredentialOfferMessageEntity<CredentialOfferBody>
          credentialOfferMessage,
      required String privateKey,
      required String genesisDid,
      required BigInt profileNonce,
      String? blockchain,
      String? network}) {
    // TODO: implement fetchCredentialsUseCase
    throw UnimplementedError();
  }
}
