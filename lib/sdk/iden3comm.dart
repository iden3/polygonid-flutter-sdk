import 'package:injectable/injectable.dart';
import 'package:polygonid_flutter_sdk/common/domain/domain_constants.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/env_config_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/env_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/filter_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/error_exception.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/common/utils/credential_sort_order.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/add_did_profile_info_use_case.dart';
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/get_did_profile_info_list_use_case.dart';
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/get_did_profile_info_use_case.dart';
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/remove_did_profile_info_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/authenticate.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/authorization/request/auth_request_iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/credential/request/base.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/interaction/interaction_base_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/interaction/interaction_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/proof/response/iden3comm_proof_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/self_issuance/self_issued_credential_params.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/exceptions/iden3comm_exceptions.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/authenticate_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/clean_schema_cache_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/core_claim_from_credential_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/create_anon_aadhaar_credential_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/create_anon_aadhaar_proof_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/fetch_and_save_claims_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/fetch_credentials_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/fetch_onchain_claims_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/fetch_schema_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_auth_token_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_filters_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_iden3comm_claims_rev_nonce_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_iden3comm_claims_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_iden3comm_proofs_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_iden3message_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_schemas_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/interaction/add_interaction_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/interaction/get_interactions_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/interaction/remove_interactions_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/interaction/update_interaction_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/identity_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/circuit_data_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/zkproof_entity.dart';

abstract class PolygonIdSdkIden3comm {
  /// Returns a [Iden3MessageEntity] from an iden3comm message string.
  ///
  /// The [message] is the iden3comm message in string format
  ///
  /// When communicating through iden3comm with an Issuer or Verifier,
  /// iden3comm message string needs to be parsed to a supported
  /// [Iden3MessageEntity] by the Polygon Id Sdk using this method.
  Future<Iden3MessageEntity> getIden3Message({required String message});

  /// Returns the schemas from an [Iden3MessageEntity].
  Future<List<Map<String, dynamic>>> getSchemas(
      {required Iden3MessageEntity message});

  /// Fetches a schema from a given [schemaUrl].
  Future<Map<String, dynamic>> fetchSchema({required String schemaUrl});

  /// Returns a list of [FilterEntity] from an iden3comm message to
  /// apply to [Credential.getClaims]
  ///
  /// The [message] is the iden3comm message entity
  Future<List<FilterEntity>> getFilters({required Iden3MessageEntity message});

  /// Fetch a list of [ClaimEntity] from issuer using iden3comm message
  /// and stores them in Polygon Id Sdk.
  ///
  /// The [message] is the iden3comm message entity
  ///
  /// The [genesisDid] is the unique id of the identity
  ///
  /// The [profileNonce] is the nonce of the profile used from identity
  /// to obtain the did identifier
  ///
  /// The [privateKey] is the key used to access all the sensitive info from the identity
  /// and also to realize operations like generating proofs
  Future<List<ClaimEntity>> fetchAndSaveClaims({
    required CredentialOfferMessageEntity message,
    required String genesisDid,
    BigInt? profileNonce,
    required String privateKey,
  });

  /// Fetch a list of [ClaimEntity] from onchain contract using its address
  /// and stores them in Polygon Id Sdk.
  ///
  /// The [contractAddress] is the address of the onchain contract
  ///
  /// The [genesisDid] is the unique id of the identity
  ///
  /// The [profileNonce] is the nonce of the profile used from identity
  /// to obtain the did identifier
  ///
  /// The [privateKey] is the key used to access all the sensitive info from the identity
  /// and also to realize operations like generating proofs
  Future<List<ClaimEntity>> fetchOnchainClaims({
    required String contractAddress,
    required String genesisDid,
    BigInt? profileNonce,
    required String privateKey,
  });

  /// Get a list of [ClaimEntity] stored in Polygon Id Sdk that fulfills
  /// the request from iden3comm message.
  ///
  /// The [message] is the iden3comm message entity
  ///
  /// The [genesisDid] is the unique id of the identity
  ///
  /// The [profileNonce] is the nonce of the profile used from identity
  /// to obtain the did identifier
  ///
  /// The [privateKey] is the key used to access all the sensitive info from the identity
  /// and also to realize operations like generating proofs
  Future<List<ClaimEntity?>> getClaimsFromIden3Message({
    required Iden3MessageEntity message,
    required String genesisDid,
    BigInt? profileNonce,
    required String privateKey,
    Map<int, Map<String, dynamic>>? nonRevocationProofs,
    List<CredentialSortOrder> sortOrder,
  });

  /// Get a list of [int] revocation nonces of claims stored in Polygon Id Sdk that fulfills
  /// the request from iden3comm message.
  ///
  /// The [message] is the iden3comm message entity
  ///
  /// The [genesisDid] is the unique id of the identity
  ///
  /// The [profileNonce] is the nonce of the profile used from identity
  /// to obtain the did identifier
  ///
  /// The [privateKey] is the key used to access all the sensitive info from the identity
  /// and also to realize operations like generating proofs
  Future<List<int>> getClaimsRevNonceFromIden3Message({
    required Iden3MessageEntity message,
    required String genesisDid,
    BigInt? profileNonce,
    required String privateKey,
  });

  /// Get a list of [Iden3commProofEntity] from iden3comm message
  ///
  /// The [message] is the iden3comm message entity
  ///
  /// The [genesisDid] is the unique id of the identity
  ///
  /// The [profileNonce] is the nonce of the profile used from identity
  /// to obtain the did identifier
  ///
  /// The [privateKey] is the key used to access all the sensitive info from the identity
  /// and also to realize operations like generating proofs
  Future<List<Iden3commProofEntity>> getProofs({
    required Iden3MessageEntity message,
    required String genesisDid,
    BigInt? profileNonce,
    required String privateKey,
    String? challenge,
    EnvConfigEntity config,
    Map<int, Map<String, dynamic>>? nonRevocationProofs,
    Map<String, dynamic>? transactionData,
  });

  /// Authenticate response from iden3Message sharing the needed
  /// (if any) proofs requested by it
  ///
  /// The [message] is the iden3comm message entity
  ///
  /// The [genesisDid] is the unique id of the identity
  ///
  /// The [profileNonce] is the nonce of the profile used from identity
  /// to obtain the did identifier
  ///
  /// The [privateKey] is the key used to access all the sensitive info from the identity
  /// and also to realize operations like generating proofs
  ///
  /// The [pushToken] is the push notification registration token so the issuer/verifer
  /// can send notifications to the identity.
  Future<Iden3MessageEntity?> authenticate({
    required Iden3MessageEntity message,
    required String genesisDid,
    BigInt? profileNonce,
    required String privateKey,
    String? pushToken,
    String? challenge,
  });

  /// Gets a list of [InteractionEntity] associated to the identity previously stored
  /// in the the Polygon ID Sdk
  ///
  /// /// The [genesisDid] is the unique id of the identity
  ///
  /// The [profileNonce] is the nonce of the profile used from identity
  /// to obtain the did identifier
  ///
  /// The [privateKey]  is the key used to access all the sensitive info from the identity
  /// and also to realize operations like generating proofs
  Future<List<InteractionBaseEntity>> getInteractions({
    String? genesisDid,
    BigInt? profileNonce,
    String? privateKey,
    List<InteractionType>? types,
    List<InteractionState>? states,
    List<FilterEntity>? filters,
  });

  /// Saves an [InteractionBaseEntity] in the Polygon ID Sdk
  ///
  /// The [interaction] is the interaction to be saved
  /// The [genesisDid] is the unique id of the identity
  /// The [privateKey]  is the key used to access all the sensitive info from the identity
  /// to obtain the did identifier
  Future<InteractionBaseEntity> addInteraction({
    required InteractionBaseEntity interaction,
    String? genesisDid,
    String? privateKey,
  });

  /// Removes a list of [InteractionEntity] from the Polygon ID Sdk by their ids
  ///
  /// The [genesisDid] is the unique id of the identity
  /// The [privateKey]  is the key used to access all the sensitive info from the identity
  /// The [ids] is the list of ids of the interactions to be removed
  Future<void> removeInteractions({
    String? genesisDid,
    String? privateKey,
    required List<String> ids,
  });

  /// Updated the states of a [InteractionBaseEntity] in the Polygon ID Sdk
  ///
  /// The [id] is the id of the notification to be updated
  /// The [genesisDid] is the unique id of the identity
  /// The [profileNonce] is the nonce of the profile used from identity
  /// to obtain the did identifier
  /// The [privateKey]  is the key used to access all the sensitive info from the identity
  /// The [state] is the new state of the interaction
  Future<InteractionBaseEntity> updateInteraction({
    required String id,
    String? genesisDid,
    BigInt? profileNonce,
    String? privateKey,
    InteractionState? state,
  });

  /// Handles notifications and store them
  ///
  /// The [payload] is the notification payload
// Future<void> handleNotification({required String payload});

  /// Cleans the schema cache
  Future<void> cleanSchemaCache();

  /// Add info about a did we interacted with
  /// in case of backup restore we can know which dids we have interacted with
  /// and use the correct profile
  /// in the Map we actually use
  /// * [profileNonce]
  /// * [selectedProfileType]
  Future<void> addDidProfileInfo({
    required String did,
    required String privateKey,
    required String interactedWithDid,
    required Map<String, dynamic> info,
  });

  ///
  Future<Map<String, dynamic>> getDidProfileInfo({
    required String did,
    required String privateKey,
    required String interactedWithDid,
  });

  ///
  Future<List<Map<String, dynamic>>> getDidProfileInfoList({
    required String did,
    required String privateKey,
    required List<FilterEntity>? filters,
  });

  ///
  Future<void> removeDidProfileInfo({
    required String did,
    required String privateKey,
    required String interactedWithDid,
  });

  Future<List<ClaimEntity>> fetchCredentials({
    required CredentialOfferMessageEntity credentialOfferMessage,
    required String privateKey,
    required String genesisDid,
    required BigInt profileNonce,
    String? blockchain,
    String? network,
  });

  Future<ZKProofEntity> getAnonAadhaarProof({
    required String qrData,
    required String profileDid,
    required SelfIssuedCredentialParams selfIssuedCredentialParams,
  });

  Future<ClaimEntity> getAnonAadhaarCredential({
    required String qrData,
    required String profileDid,
    required SelfIssuedCredentialParams selfIssuedCredentialParams,
    required Map<String, dynamic> additionalFields,
  });
}

@injectable
class Iden3comm implements PolygonIdSdkIden3comm {
  final FetchAndSaveClaimsUseCase _fetchAndSaveClaimsUseCase;
  final FetchOnchainClaimsUseCase _fetchOnchainClaimsUseCase;
  final GetIden3MessageUseCase _getIden3MessageUseCase;
  final GetSchemasUseCase _getSchemasUseCase;
  final FetchSchemaUseCase _fetchSchemaUseCase;
  final AuthenticateUseCase _authenticateUseCase;
  final GetFiltersUseCase _getFiltersUseCase;
  final GetIden3commClaimsUseCase _getIden3commClaimsUseCase;
  final GetIden3commClaimsRevNonceUseCase _getIden3commClaimsRevNonceUseCase;
  final GetIden3commProofsUseCase _getIden3commProofsUseCase;
  final GetInteractionsUseCase _getInteractionsUseCase;
  final AddInteractionUseCase _addInteractionUseCase;
  final RemoveInteractionsUseCase _removeInteractionsUseCase;
  final UpdateInteractionUseCase _updateInteractionUseCase;
  final CleanSchemaCacheUseCase _cleanSchemaCacheUseCase;
  final StacktraceManager _stacktraceManager;
  final AddDidProfileInfoUseCase _addDidProfileInfoUseCase;
  final GetDidProfileInfoUseCase _getDidProfileInfoUseCase;
  final GetDidProfileInfoListUseCase _getDidProfileInfoListUseCase;
  final RemoveDidProfileInfoUseCase _removeDidProfileInfoUseCase;
  final GetAuthTokenUseCase _getAuthTokenUseCase;
  final FetchCredentialsUseCase _fetchCredentialsUseCase;
  final CreateAnonAadhaarCredentialUseCase _createAnonAadhaarCredentialUseCase;
  final CreateAnonAadhaarProofUseCase _createAnonAadhaarProofUseCase;
  final CoreClaimFromCredentialUseCase _coreClaimFromCredentialUseCase;

  Iden3comm(
    this._fetchAndSaveClaimsUseCase,
    this._fetchOnchainClaimsUseCase,
    this._getIden3MessageUseCase,
    this._getSchemasUseCase,
    this._fetchSchemaUseCase,
    this._authenticateUseCase,
    this._getFiltersUseCase,
    this._getIden3commClaimsUseCase,
    this._getIden3commClaimsRevNonceUseCase,
    this._getIden3commProofsUseCase,
    this._getInteractionsUseCase,
    this._addInteractionUseCase,
    this._removeInteractionsUseCase,
    this._updateInteractionUseCase,
    this._cleanSchemaCacheUseCase,
    this._stacktraceManager,
    this._addDidProfileInfoUseCase,
    this._getDidProfileInfoUseCase,
    this._getDidProfileInfoListUseCase,
    this._removeDidProfileInfoUseCase,
    this._getAuthTokenUseCase,
    this._fetchCredentialsUseCase,
    this._createAnonAadhaarCredentialUseCase,
    this._createAnonAadhaarProofUseCase,
    this._coreClaimFromCredentialUseCase,
  );

  @override
  Future<Iden3MessageEntity> getIden3Message({required String message}) {
    _stacktraceManager.clearStacktrace();
    return _getIden3MessageUseCase.execute(param: message);
  }

  @override
  Future<List<Map<String, dynamic>>> getSchemas(
      {required Iden3MessageEntity message}) {
    _stacktraceManager.clearStacktrace();
    return _getSchemasUseCase.execute(param: message);
  }

  @override
  Future<Map<String, dynamic>> fetchSchema({required String schemaUrl}) {
    _stacktraceManager.clearStacktrace();
    return _fetchSchemaUseCase.execute(param: schemaUrl);
  }

  @override
  Future<List<FilterEntity>> getFilters({required Iden3MessageEntity message}) {
    _stacktraceManager.clearStacktrace();
    return _getFiltersUseCase.execute(param: message);
  }

  @override
  Future<List<ClaimEntity>> fetchAndSaveClaims({
    required CredentialOfferMessageEntity message,
    required String genesisDid,
    BigInt? profileNonce,
    required String privateKey,
  }) {
    _stacktraceManager.clearStacktrace();

    return _fetchAndSaveClaimsUseCase.execute(
      param: FetchAndSaveClaimsParam(
        message: message,
        genesisDid: genesisDid,
        profileNonce: profileNonce ?? GENESIS_PROFILE_NONCE,
        privateKey: privateKey,
      ),
    );
  }

  @override
  Future<List<ClaimEntity>> fetchOnchainClaims({
    required String contractAddress,
    required String genesisDid,
    BigInt? profileNonce,
    required String privateKey,
    String? chainId,
  }) {
    _stacktraceManager.clearStacktrace();

    return _fetchOnchainClaimsUseCase.execute(
      param: FetchOnchainClaimsParam(
        contractAddress: contractAddress,
        genesisDid: genesisDid,
        profileNonce: profileNonce,
        privateKey: privateKey,
        chainId: chainId,
      ),
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
    _stacktraceManager.clearStacktrace();
    return _getIden3commClaimsUseCase.execute(
        param: GetIden3commClaimsParam(
      message: message,
      genesisDid: genesisDid,
      profileNonce: profileNonce ?? GENESIS_PROFILE_NONCE,
      privateKey: privateKey,
      nonRevocationProofs: nonRevocationProofs ?? {},
      credentialSortOrderList: sortOrder,
    ));
  }

  @override
  Future<List<int>> getClaimsRevNonceFromIden3Message({
    required Iden3MessageEntity message,
    required String genesisDid,
    BigInt? profileNonce,
    required String privateKey,
  }) {
    _stacktraceManager.clearStacktrace();
    return _getIden3commClaimsRevNonceUseCase.execute(
        param: GetIden3commClaimsRevNonceParam(
      message: message,
      genesisDid: genesisDid,
      profileNonce: profileNonce ?? GENESIS_PROFILE_NONCE,
      privateKey: privateKey,
    ));
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
    _stacktraceManager.clearStacktrace();
    return _getIden3commProofsUseCase.execute(
        param: GetIden3commProofsParam(
      message: message,
      genesisDid: genesisDid,
      profileNonce: profileNonce ?? GENESIS_PROFILE_NONCE,
      privateKey: privateKey,
      challenge: challenge,
      config: config,
      nonRevocationProofs: nonRevocationProofs,
      transactionData: transactionData,
    ));
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
    _stacktraceManager.clearStacktrace();
    if (message is! AuthIden3MessageEntity) {
      _stacktraceManager.addTrace(
          '[authenticate] Invalid message type: ${message.messageType}');
      _stacktraceManager.addError(
          'Invalid message type: ${message.messageType}, expected: ${Iden3MessageType.authRequest}');
      throw InvalidIden3MsgTypeException(
        expected: Iden3MessageType.authRequest,
        actual: message.messageType,
        errorMessage:
            'Invalid message type, expected: ${Iden3MessageType.authRequest}, actual: ${message.messageType}',
      );
    }

    return _authenticateUseCase.execute(
      param: AuthenticateParam(
        message: message,
        genesisDid: genesisDid,
        profileNonce: profileNonce ?? GENESIS_PROFILE_NONCE,
        privateKey: privateKey,
        pushToken: pushToken,
        nonRevocationProofs: nonRevocationProofs,
        challenge: challenge,
      ),
    );
  }

  Future<Iden3MessageEntity?> authenticateV2({
    required String privateKey,
    required String genesisDid,
    required BigInt profileNonce,
    required IdentityEntity identityEntity,
    required Iden3MessageEntity message,
    required EnvEntity env,
    String? pushToken,
    String? challenge,
  }) async {
    try {
      return await Authenticate().authenticate(
        privateKey: privateKey,
        genesisDid: genesisDid,
        profileNonce: profileNonce,
        identityEntity: identityEntity,
        message: message,
        env: env,
        pushToken: pushToken,
      );
    } on PolygonIdSDKException catch (_) {
      rethrow;
    } catch (e) {
      _stacktraceManager.addTrace('[authenticateV2] Error: ${e.toString()}');
      _stacktraceManager.addError(e.toString());
      throw PolygonIdSDKException(
          errorMessage:
              "Error while authenticating with error: ${e.toString()}");
    }
  }

  @override
  Future<List<InteractionBaseEntity>> getInteractions({
    String? genesisDid,
    BigInt? profileNonce,
    String? privateKey,
    List<InteractionType>? types,
    List<InteractionState>? states,
    List<FilterEntity>? filters,
  }) {
    _stacktraceManager.clearStacktrace();
    return _getInteractionsUseCase.execute(
        param: GetInteractionsParam(
      genesisDid: genesisDid,
      profileNonce: profileNonce ?? GENESIS_PROFILE_NONCE,
      privateKey: privateKey,
      types: types,
      filters: filters,
    ));
  }

  @override
  Future<void> removeInteractions({
    String? genesisDid,
    String? privateKey,
    required List<String> ids,
  }) {
    _stacktraceManager.clearStacktrace();
    return _removeInteractionsUseCase.execute(
        param: RemoveInteractionsParam(
            genesisDid: genesisDid, privateKey: privateKey, ids: ids));
  }

  @override
  Future<InteractionBaseEntity> addInteraction({
    required InteractionBaseEntity interaction,
    String? genesisDid,
    String? privateKey,
  }) {
    _stacktraceManager.clearStacktrace();
    return _addInteractionUseCase.execute(
        param: AddInteractionParam(
            genesisDid: genesisDid,
            privateKey: privateKey,
            interaction: interaction));
  }

  @override
  Future<InteractionBaseEntity> updateInteraction({
    required String id,
    String? genesisDid,
    BigInt? profileNonce,
    String? privateKey,
    InteractionState? state,
  }) {
    _stacktraceManager.clearStacktrace();
    return _updateInteractionUseCase.execute(
        param: UpdateInteractionParam(
      genesisDid: genesisDid,
      profileNonce: profileNonce ?? GENESIS_PROFILE_NONCE,
      privateKey: privateKey,
      id: id,
      state: state,
    ));
  }

  @override
  Future<void> cleanSchemaCache() {
    return _cleanSchemaCacheUseCase.execute(param: null);
  }

  @override
  Future<void> addDidProfileInfo({
    required String did,
    required String privateKey,
    required String interactedWithDid,
    required Map<String, dynamic> info,
  }) {
    return _addDidProfileInfoUseCase.execute(
      param: AddDidProfileInfoParam(
        genesisDid: did,
        privateKey: privateKey,
        interactedWithDid: interactedWithDid,
        didProfileInfo: info,
      ),
    );
  }

  @override
  Future<Map<String, dynamic>> getDidProfileInfo({
    required String did,
    required String privateKey,
    required String interactedWithDid,
  }) {
    return _getDidProfileInfoUseCase.execute(
      param: GetDidProfileInfoParam(
        genesisDid: did,
        privateKey: privateKey,
        interactedWithDid: interactedWithDid,
      ),
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getDidProfileInfoList({
    required String did,
    required String privateKey,
    required List<FilterEntity>? filters,
  }) {
    return _getDidProfileInfoListUseCase.execute(
      param: GetDidProfileInfoListParam(
        genesisDid: did,
        privateKey: privateKey,
        filters: filters,
      ),
    );
  }

  @override
  Future<void> removeDidProfileInfo({
    required String did,
    required String privateKey,
    required String interactedWithDid,
  }) {
    return _removeDidProfileInfoUseCase.execute(
      param: RemoveDidProfileInfoParam(
        genesisDid: did,
        privateKey: privateKey,
        interactedWithDid: interactedWithDid,
      ),
    );
  }

  Future<String> getAuthToken({
    required String genesisDid,
    required String privateKey,
    required BigInt profileNonce,
    required String iden3message,
  }) {
    return _getAuthTokenUseCase.execute(
      param: GetAuthTokenParam(
        genesisDid: genesisDid,
        profileNonce: profileNonce,
        privateKey: privateKey,
        message: iden3message,
      ),
    );
  }

  @override
  Future<List<ClaimEntity>> fetchCredentials({
    required CredentialOfferMessageEntity credentialOfferMessage,
    required String privateKey,
    required String genesisDid,
    required BigInt profileNonce,
    String? blockchain,
    String? network,
  }) {
    return _fetchCredentialsUseCase.fetchCredentials(
      credentialOfferMessage: credentialOfferMessage,
      privateKey: privateKey,
      genesisDid: genesisDid,
      profileNonce: profileNonce,
      blockchain: blockchain,
      network: network,
    );
  }

  @override
  Future<ZKProofEntity> getAnonAadhaarProof({
    required String qrData,
    required String profileDid,
    required SelfIssuedCredentialParams selfIssuedCredentialParams,
    CircuitDataEntity? circuitData,
  }) async {
    return _createAnonAadhaarProofUseCase.execute(
      param: CreateAnonAadhaarProofParam(
        qrData: qrData,
        profileDid: profileDid,
        selfIssuedCredentialParams: selfIssuedCredentialParams,
        circuitData: circuitData,
      ),
    );
  }

  @override
  Future<ClaimEntity> getAnonAadhaarCredential({
    required String qrData,
    required String profileDid,
    required SelfIssuedCredentialParams selfIssuedCredentialParams,
    Map<String, dynamic>? additionalFields,
  }) {
    return _createAnonAadhaarCredentialUseCase.execute(
      param: CreateAnonAadhaarCredentialParam(
          qrData: qrData,
          profileDid: profileDid,
          selfIssuedCredentialParams: selfIssuedCredentialParams,
          additionalFields: additionalFields),
    );
  }

  Future<String> coreClaimFromCredential({
    required ClaimEntity credential,
    EnvConfigEntity? config,
  }) {
    return _coreClaimFromCredentialUseCase.execute(
      param: CoreClaimFromCredentialParam(
        credential: credential,
        config: config,
      ),
    );
  }
}
