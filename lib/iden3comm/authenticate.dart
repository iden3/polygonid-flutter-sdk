import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:ninja_prime/ninja_prime.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:polygonid_flutter_sdk/common/data/data_sources/mappers/filters_mapper.dart';
import 'package:polygonid_flutter_sdk/common/data/exceptions/network_exceptions.dart';
import 'package:polygonid_flutter_sdk/common/domain/domain_constants.dart';
import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/chain_config_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/env_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/filter_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/media_type.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_cases/get_selected_chain_use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/common/utils/base_64.dart';
import 'package:polygonid_flutter_sdk/common/utils/big_int_extension.dart';
import 'package:polygonid_flutter_sdk/common/utils/credential_sort_order.dart';
import 'package:polygonid_flutter_sdk/common/utils/pinata_gateway_utils.dart';
import 'package:polygonid_flutter_sdk/common/utils/uint8_list_utils.dart';
import 'package:polygonid_flutter_sdk/constants.dart';
import 'package:polygonid_flutter_sdk/credential/data/data_sources/lib_pidcore_credential_data_source.dart';
import 'package:polygonid_flutter_sdk/credential/data/data_sources/storage_claim_data_source.dart';
import 'package:polygonid_flutter_sdk/credential/data/dtos/claim_dto.dart';
import 'package:polygonid_flutter_sdk/credential/data/mappers/claim_mapper.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/refresh_credential_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/dtos/authorization/response/auth_body_did_doc_response_dto.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/dtos/authorization/response/auth_body_did_doc_service_metadata_devices_response_dto.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/dtos/authorization/response/auth_body_did_doc_service_metadata_response_dto.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/dtos/authorization/response/auth_body_did_doc_service_response_dto.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/dtos/authorization/response/auth_body_response_dto.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/dtos/authorization/response/auth_response_dto.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/mappers/proof_request_filters_mapper.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/authorization/request/auth_request_iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/constants.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/request/proof_request_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/request/proof_scope_query_request.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/request/proof_scope_request.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/response/jwz.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/proof/response/iden3comm_proof_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/proof/response/iden3comm_sd_proof_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/proof/response/iden3comm_vp_proof.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/exceptions/iden3comm_exceptions.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/exceptions/jwz_exceptions.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_iden3message_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/data/data_sources/lib_pidcore_identity_data_source.dart';
import 'package:polygonid_flutter_sdk/identity/data/data_sources/wallet_data_source.dart';
import 'package:polygonid_flutter_sdk/identity/data/dtos/circuit_type.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/hash_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/node_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/identity_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/tree_state_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/tree_type.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/smt_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_did_identifier_use_case.dart';
import 'package:polygonid_flutter_sdk/proof/data/data_sources/circuits_files_data_source.dart';
import 'package:polygonid_flutter_sdk/proof/data/data_sources/gist_mtproof_data_source.dart';
import 'package:polygonid_flutter_sdk/proof/data/data_sources/lib_pidcore_proof_data_source.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/gist_mtproof_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/circuit_data_entity.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/mtproof_dto.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/zkproof_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/exceptions/proof_generation_exceptions.dart';
import 'package:polygonid_flutter_sdk/proof/domain/repositories/proof_repository.dart';
import 'package:polygonid_flutter_sdk/proof/gist_proof_cache.dart';
import 'package:polygonid_flutter_sdk/proof/infrastructure/proof_generation_stream_manager.dart';
import 'package:polygonid_flutter_sdk/sdk/di/injector.dart';
import 'package:poseidon/poseidon.dart';
import 'package:sembast/sembast.dart';
import 'package:uuid/uuid.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/oaep.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/digests/sha512.dart';

class Authenticate {
  late ProofGenerationStepsStreamManager _proofGenerationStepsStreamManager;
  late StacktraceManager _stacktraceManager;

  Future<Iden3MessageEntity?> authenticate({
    required String privateKey,
    required String genesisDid,
    required BigInt profileNonce,
    required IdentityEntity identityEntity,
    required Iden3MessageEntity message,
    required EnvEntity env,
    required String? pushToken,
    String? challenge,
    final Map<String, dynamic>? transactionData,
    String? authClaimNonce,
  }) async {
    final nonce = authClaimNonce ?? DEFAULT_AUTH_CLAIM_NONCE;
    try {
      List<Iden3commProofEntity> proofs = [];
      Map<int, String> groupIdLinkNonceMap = {};

      AuthClaimCompanionObject? authClaimCompanionObject;
      ProofRepository proofRepository =
          await getItSdk.getAsync<ProofRepository>();
      _proofGenerationStepsStreamManager =
          getItSdk<ProofGenerationStepsStreamManager>();
      _stacktraceManager = getItSdk<StacktraceManager>();

      _proofGenerationStepsStreamManager.add("preparing authentication...");

      // Check if the message type is supported
      if (![
        Iden3MessageType.authRequest,
        Iden3MessageType.proofContractInvokeRequest
      ].contains(message.messageType)) {
        _stacktraceManager.addError(
          "[Authenticate] Unsupported message type: ${message.messageType} It should be either authRequest or proofContractInvokeRequest",
        );
        throw UnsupportedIden3MsgTypeException(
          type: message.messageType,
          errorMessage: "Unsupported message type\nIt should be either "
              "authRequest or proofContractInvokeRequest",
        );
      }

      Uint8List privateKeyBytes = hexToBytes(privateKey);

      GetSelectedChainUseCase getSelectedChainUseCase =
          await getItSdk.getAsync<GetSelectedChainUseCase>();

      ChainConfigEntity chain = await getSelectedChainUseCase.execute();
      _stacktraceManager.addTrace(
        "[Authenticate] Chain: ${chain.blockchain} ${chain.network}",
      );
      GetDidIdentifierUseCase getDidIdentifierUseCase =
          await getItSdk.getAsync<GetDidIdentifierUseCase>();

      String profileDid = await getDidIdentifierUseCase.execute(
        param: GetDidIdentifierParam.withPrivateKey(
          privateKey: privateKey,
          blockchain: chain.blockchain,
          network: chain.network,
          profileNonce: profileNonce,
          method: chain.method,
        ),
      );

      List<ProofRequestEntity> proofRequests = [];
      List<ClaimEntity> claims = [];

      // Get the credentials and proof requests by scope
      // it is assigning the proofRequests and claims to the variables directly
      // from the function call
      await getCredentialsAndProofRequestsByScope(
        message: message,
        proofRequests: proofRequests,
        genesisDid: genesisDid,
        privateKey: privateKey,
        claims: claims,
      );

      // this authClaimCompanionObject is the one that is being used to get the
      // authClaim, incProof, nonRevProof, treeState, authClaimNode, gistProofEntity
      _proofGenerationStepsStreamManager.add("getting auth claim...");
      authClaimCompanionObject ??= await getAuthClaim(
        genesisDid: genesisDid,
        env: env,
        chain: chain,
        privateKey: privateKey,
        privateKeyBytes: privateKeyBytes,
        authClaimNonce: nonce,
      );

      // if there are proof requests and claims and they are the same length
      // then create the proof for every proof request
      if (proofRequests.isNotEmpty &&
          claims.isNotEmpty &&
          proofRequests.length == claims.length) {
        // it is assigning the proofs to the variable directly from the function call
        await createProofForEveryProofRequest(
          proofRequests: proofRequests,
          claims: claims,
          identityEntity: identityEntity,
          groupIdLinkNonceMap: groupIdLinkNonceMap,
          genesisDid: genesisDid,
          profileNonce: profileNonce,
          privateKey: privateKey,
          challenge: challenge,
          env: env,
          message: message,
          transactionData: transactionData,
          privateKeyBytes: privateKeyBytes,
          proofRepository: proofRepository,
          authClaimCompanionObject: authClaimCompanionObject,
          proofs: proofs,
        );
      }

      // prepare the auth response message
      _proofGenerationStepsStreamManager
          .add("preparing authentication parameters...");
      String authResponseString = await prepareAuthResponseMessage(
        env: env,
        pushToken: pushToken,
        profileDid: profileDid,
        message: message,
        proofs: proofs,
      );

      // get the auth token
      _proofGenerationStepsStreamManager
          .add("preparing authentication token...");
      String authToken = await _getAuthToken(
        genesisDid: genesisDid,
        profileNonce: profileNonce,
        privateKey: privateKey,
        privateKeyBytes: privateKeyBytes,
        message: authResponseString,
        authClaim: authClaimCompanionObject.authClaim!,
        incProof: authClaimCompanionObject.incProof!,
        nonRevProof: authClaimCompanionObject.nonRevProof!,
        treeState: authClaimCompanionObject.treeState!,
        authClaimNode: authClaimCompanionObject.authClaimNode!,
        gistProofEntity: authClaimCompanionObject.gistProofEntity!,
        proofRepository: proofRepository,
        env: env,
      );
      _stacktraceManager.addTrace(
        "[Authenticate] authToken: $authToken",
      );

      _proofGenerationStepsStreamManager
          .add("sending auth token to the requester...");
      String? callbackUrl = message.body.callbackUrl;

      if (callbackUrl == null || callbackUrl.isEmpty) {
        _stacktraceManager.addError(
          "[Authenticate] Callback url is null or empty",
        );
        throw NullAuthenticateCallbackException(
          authRequest: message as AuthIden3MessageEntity,
          errorMessage: "Callback url is null or empty",
        );
      }

      // perform the authentication with the auth token calling the callback url
      http.Client httpClient = http.Client();
      Uri uri = Uri.parse(callbackUrl);
      http.Response response = await httpClient.post(
        uri,
        body: authToken,
        headers: {
          HttpHeaders.acceptHeader: '*/*',
          HttpHeaders.contentTypeHeader: 'text/plain',
        },
      ).timeout(const Duration(seconds: 30));

      _stacktraceManager.addTrace(
        "[Authenticate] responseStatusCode: ${response.statusCode}\nresponseBody: ${response.body}",
      );

      if (response.statusCode != 200) {
        _stacktraceManager.addError(
          "[Authenticate] Error sending auth token to the requester: ${response.statusCode} ${response.body}",
        );
        throw NetworkException(
          statusCode: response.statusCode,
          errorMessage: response.body,
        );
      }

      if (response.body.isEmpty) {
        return null;
      }

      try {
        final messageJson = jsonDecode(response.body);

        if (messageJson is! Map<String, dynamic> || messageJson.isEmpty) {
          return null;
        }

        final _getIden3MessageUseCase = getItSdk<GetIden3MessageUseCase>();
        final nextRequest = await _getIden3MessageUseCase.execute(
          param: jsonEncode(messageJson),
        );

        return nextRequest;
      } catch (e) {
        return null;
      }
    } on TimeoutException catch (e) {
      String waitingTime = e.duration?.inSeconds.toString() ?? "unknown";
      throw NetworkException(
          statusCode: 504,
          errorMessage:
              "Connection timeout while sending auth token to the requester.\nwaited for $waitingTime seconds.");
    } catch (e) {
      rethrow;
    }
  }

  Future<String> prepareAuthResponseMessage({
    required EnvEntity env,
    required String? pushToken,
    required String profileDid,
    required Iden3MessageEntity message,
    required List<Iden3commProofEntity> proofs,
  }) async {
    String pushUrl = env.pushUrl;

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String packageName = packageInfo.packageName;

    AuthBodyDidDocResponseDTO? didDocResponse = await _getDidDoc(
      pushUrl: pushUrl,
      pushToken: pushToken,
      packageName: packageName,
      profileDid: profileDid,
    );

    AuthResponseDTO authResponse = AuthResponseDTO(
      id: const Uuid().v4(),
      thid: message.thid,
      to: message.from,
      from: profileDid,
      typ: MediaType.ZKPMessage.name,
      type: Iden3MessageType.authResponse.type,
      body: AuthBodyResponseDTO(
        message: (message as AuthIden3MessageEntity).body.message,
        scope: proofs,
        did_doc: didDocResponse,
      ),
    );

    String authResponseString = jsonEncode(authResponse.toJson());
    return authResponseString;
  }

  ///
  Future<void> createProofForEveryProofRequest({
    required List<ProofRequestEntity> proofRequests,
    required List<ClaimEntity> claims,
    required IdentityEntity identityEntity,
    required Map<int, String> groupIdLinkNonceMap,
    required String genesisDid,
    required BigInt profileNonce,
    required String privateKey,
    required String? challenge,
    required EnvEntity env,
    required Iden3MessageEntity message,
    required Map<String, dynamic>? transactionData,
    required Uint8List privateKeyBytes,
    required ProofRepository proofRepository,
    required AuthClaimCompanionObject authClaimCompanionObject,
    required List<Iden3commProofEntity> proofs,
  }) async {
    for (int i = 0; i < proofRequests.length; i++) {
      ProofRequestEntity proofRequest = proofRequests[i];
      ClaimEntity claim = claims[i];

      if (claim.expiration != null) {
        claim = await _checkCredentialExpirationAndTryRefreshIfExpired(
          claim: claim,
          genesisDid: genesisDid,
          privateKey: privateKey,
        );
      }

      _proofGenerationStepsStreamManager.add(
          "#${i + 1} creating proof for ${proofRequest.scope.query.type}...");

      final appDir = await getApplicationDocumentsDirectory();
      final circuitsDataSource = CircuitsFilesDataSource(appDir);

      final graphFileBytes =
          await circuitsDataSource.loadGraphFile(proofRequest.scope.circuitId);
      final zkeyFilePath = await circuitsDataSource
          .getZkeyFilePath(proofRequest.scope.circuitId);

      CircuitDataEntity circuitDataEntity = CircuitDataEntity(
        proofRequest.scope.circuitId,
        graphFileBytes,
        zkeyFilePath,
      );

      BigInt claimSubjectProfileNonce = identityEntity.profiles.keys.firstWhere(
          (k) => identityEntity.profiles[k] == claim.did,
          orElse: () => GENESIS_PROFILE_NONCE);

      int? groupId = proofRequest.scope.query.groupId;
      String linkNonce = "0";
      // Check if groupId exists in the map
      if (groupId != null) {
        if (groupIdLinkNonceMap.containsKey(groupId)) {
          // Use the existing linkNonce for this groupId
          linkNonce = groupIdLinkNonceMap[groupId]!;
        } else {
          // Generate a new linkNonce for this groupId
          linkNonce =
              generateLinkNonce(); // Replace this with your linkNonce generation logic
          groupIdLinkNonceMap[groupId] = linkNonce;
        }
      }

      Map<String, dynamic>? config;
      String? signature;

      if (proofRequest.scope.circuitId == CircuitType.mtponchain.name ||
          proofRequest.scope.circuitId == CircuitType.sigonchain.name ||
          proofRequest.scope.circuitId == CircuitType.circuitsV3onchain.name) {
        /// SIGN MESSAGE
        signature = await signMessage(
          privateKey: privateKeyBytes,
          message: challenge!,
        );
      }

      config = env.config.toJson();

      List<String> splittedDid = genesisDid.split(":");
      String id = splittedDid[4];
      final generateInputsRes =
          await proofRepository.calculateAtomicQueryInputs(
        id: id,
        profileNonce: profileNonce,
        claimSubjectProfileNonce: claimSubjectProfileNonce,
        claim: claim,
        proofScopeRequest: proofRequest.scope.toJson(),
        circuitId: proofRequest.scope.circuitId,
        incProof: authClaimCompanionObject.incProof,
        nonRevProof: authClaimCompanionObject.nonRevProof,
        gistProof: authClaimCompanionObject.gistProofEntity,
        authClaim: authClaimCompanionObject.authClaim,
        treeState: authClaimCompanionObject.treeState,
        challenge: challenge,
        signature: signature,
        config: config,
        verifierId: message.from,
        linkNonce: linkNonce,
        scopeParams: proofRequest.scope.params,
        transactionData: transactionData,
      );

      final atomicQueryInputs = json.encode(generateInputsRes.inputs);
      if (kDebugMode) {
        //just for debug
        logger().i("atomicQueryInputs: $atomicQueryInputs");
      }

      Iden3commVPProof? vpProof;
      final verifiablePresentation = generateInputsRes.verifiablePresentation;
      if (verifiablePresentation != null) {
        vpProof = Iden3commVPProof.fromJson(verifiablePresentation);
      }

      Uint8List witnessBytes = await proofRepository.calculateWitness(
        circuitData: circuitDataEntity,
        atomicQueryInputs: atomicQueryInputs,
      );

      ZKProofEntity zkProofEntity = await proofRepository.prove(
        circuitData: circuitDataEntity,
        wtnsBytes: witnessBytes,
      );

      Iden3commProofEntity proof;
      if (vpProof != null) {
        proof = Iden3commSDProofEntity(
          id: proofRequest.scope.id,
          circuitId: proofRequest.scope.circuitId,
          proof: zkProofEntity.proof,
          pubSignals: zkProofEntity.pubSignals,
          publicStatesInfo: generateInputsRes.publicStatesInfo,
          vp: vpProof,
        );
      } else {
        proof = Iden3commProofEntity(
          id: proofRequest.scope.id,
          circuitId: proofRequest.scope.circuitId,
          proof: zkProofEntity.proof,
          pubSignals: zkProofEntity.pubSignals,
          publicStatesInfo: generateInputsRes.publicStatesInfo,
        );
      }
      proofs.add(proof);
    }
  }

  Future<void> getCredentialsAndProofRequestsByScope({
    required List<ProofRequestEntity> proofRequests,
    required List<ClaimEntity> claims,
    required Iden3MessageEntity message,
    required String genesisDid,
    required String privateKey,
  }) async {
    List<ProofScopeRequest>? scopes = message.body.scope;
    if (scopes == null || scopes.isEmpty) {
      return;
    }

    final groupedByGroupId = groupBy(scopes, (obj) => obj.query.groupId);

    Map<int, List<ClaimEntity>> claimsByGroupId = {};

    // for each group of scopes
    for (final group in groupedByGroupId.entries) {
      int? groupId = group.key;
      if (groupId == null) {
        continue;
      }

      List<FilterEntity> filtersForQueryClaimDb = [];

      List<ProofScopeRequest> groupScopes = group.value;
      for (final scope in groupScopes) {
        Map<String, dynamic> credentialSchema =
            await fetchSchema(schemaUrl: scope.query.context!);
        ProofRequestEntity proofRequest = ProofRequestEntity(
          scope,
          credentialSchema,
        );
        ProofRequestFiltersMapper proofRequestFiltersMapper =
            getItSdk<ProofRequestFiltersMapper>();
        List<FilterEntity> filterForSingleScope =
            proofRequestFiltersMapper.mapFrom(proofRequest);
        // we add the filters for each scope to the list of filters
        filtersForQueryClaimDb.addAll(filterForSingleScope);
        // we remove duplicates
        filtersForQueryClaimDb = filtersForQueryClaimDb.toSet().toList();
      }

      FiltersMapper filtersMapper = getItSdk<FiltersMapper>();
      Filter filter = filtersMapper.mapTo(filtersForQueryClaimDb);

      StorageClaimDataSource storageClaimDataSource =
          getItSdk<StorageClaimDataSource>();

      List<ClaimDTO> claimDTO = await storageClaimDataSource.getClaims(
        filter: filter,
        did: genesisDid,
        privateKey: privateKey,
        credentialSortOrderList: [CredentialSortOrder.IssuanceDateDescending],
      );
      ClaimMapper claimMapper = getItSdk<ClaimMapper>();
      List<ClaimEntity> validClaims =
          claimDTO.map((e) => claimMapper.mapFrom(e)).toList();
      claimsByGroupId[groupId] = validClaims;
    }

    for (final scope in scopes) {
      List<ClaimEntity> validClaims = [];
      Map<String, dynamic> credentialSchema =
          await fetchSchema(schemaUrl: scope.query.context!);
      ProofRequestEntity proofRequest = ProofRequestEntity(
        scope,
        credentialSchema,
      );
      proofRequests.add(proofRequest);

      if (scope.query.groupId != null) {
        validClaims = claimsByGroupId[scope.query.groupId] ?? [];
      } else {
        ProofRequestFiltersMapper proofRequestFiltersMapper =
            getItSdk<ProofRequestFiltersMapper>();
        List<FilterEntity> filtersForQueryClaimDb =
            proofRequestFiltersMapper.mapFrom(proofRequest);
        FiltersMapper filtersMapper = getItSdk<FiltersMapper>();
        Filter filter = filtersMapper.mapTo(filtersForQueryClaimDb);

        StorageClaimDataSource storageClaimDataSource =
            getItSdk<StorageClaimDataSource>();

        List<ClaimDTO> claimDTO = await storageClaimDataSource.getClaims(
          filter: filter,
          did: genesisDid,
          privateKey: privateKey,
          credentialSortOrderList: [CredentialSortOrder.IssuanceDateDescending],
        );
        ClaimMapper claimMapper = getItSdk<ClaimMapper>();
        validClaims = claimDTO.map((e) => claimMapper.mapFrom(e)).toList();
      }

      validClaims = _filterManuallyIfPositiveInteger(
        request: proofRequest,
        claimsFiltered: validClaims,
      );

      validClaims = _filterManuallyIfQueryContainsProofType(
        request: proofRequest,
        claimsFiltered: validClaims,
      );

      if (validClaims.isEmpty) {
        continue;
      }

      final validClaim = validClaims.firstWhereOrNull((element) {
        List<Map<String, dynamic>> proofs = element.info["proof"];
        List<String> proofTypes =
            proofs.map((e) => e["type"] as String).toList();

        final circuitId = scope.circuitId;
        // TODO (moria): remove this with v3 circuit release
        if (circuitId.startsWith(CircuitType.v3CircuitPrefix) &&
            !circuitId.endsWith(CircuitType.currentCircuitBetaPostfix)) {
          _stacktraceManager.addError(
            "[Authenticate] V3 circuit beta version mismatch $circuitId is not supported, current is ${CircuitType.currentCircuitBetaPostfix}",
          );
          throw CircuitNotDownloadedException(
              circuit: circuitId,
              errorMessage:
                  "V3 circuit beta version mismatch $circuitId is not supported, current is ${CircuitType.currentCircuitBetaPostfix}");
        }

        CircuitType circuitType = CircuitType.fromString(circuitId);

        switch (circuitType) {
          case CircuitType.mtp:
          case CircuitType.mtponchain:
            bool success = [
              'Iden3SparseMerkleProof',
              'Iden3SparseMerkleTreeProof'
            ].any((element) => proofTypes.contains(element));
            return success;
          case CircuitType.sig:
          case CircuitType.sigonchain:
            bool success = proofTypes.contains('BJJSignature2021');
            return success;
          case CircuitType.auth:
          case CircuitType.unknown:
            break;
          case CircuitType.circuitsV3:
          case CircuitType.circuitsV3onchain:
          case CircuitType.linkedMultyQuery10:
            bool success = [
              'Iden3SparseMerkleProof',
              'Iden3SparseMerkleTreeProof',
              'BJJSignature2021',
            ].any((element) => proofTypes.contains(element));
            return success;
        }
        return false;
      });

      if (validClaim == null) {
        continue;
      }

      claims.add(validClaim);
    }
  }

  /// Fetches the schema from the given URL
  Future<Map<String, dynamic>> fetchSchema({required String schemaUrl}) async {
    if (schemaUrl.toLowerCase().startsWith("ipfs://")) {
      String fileHash = schemaUrl.replaceFirst("ipfs://", "");
      String? pinataGatewayUrl =
          await PinataGatewayUtils().retrievePinataGatewayUrlFromEnvironment(
        fileHash: fileHash,
      );

      if (pinataGatewayUrl != null) {
        schemaUrl = pinataGatewayUrl;
      } else {
        schemaUrl = "https://ipfs.io/ipfs/$fileHash";
      }
    }

    final schemaUri = Uri.parse(schemaUrl);
    final dio = Dio();
    final dir = await getApplicationDocumentsDirectory();
    final path = dir.path;
    dio.interceptors.add(
      DioCacheInterceptor(
        options: CacheOptions(
          store: HiveCacheStore(path),
          policy: CachePolicy.request,
          hitCacheOnErrorExcept: [],
          maxStale: const Duration(days: 14),
          priority: CachePriority.high,
        ),
      ),
    );
    final schemaResponse = await dio.get(schemaUri.toString());
    if (schemaResponse.statusCode == 200 || schemaResponse.statusCode == 304) {
      Map<String, dynamic> schema = {};
      bool isMap = schemaResponse.data is Map<String, dynamic>;
      if (!isMap) {
        schema = json.decode(schemaResponse.data);
      } else {
        schema = schemaResponse.data;
      }

      return schema;
    } else {
      _stacktraceManager.addError(
        "[Authenticate] Error fetching schema: ${schemaResponse.statusCode} ${schemaResponse.statusMessage}",
      );
      throw NetworkException(
        statusCode: schemaResponse.statusCode ?? 0,
        errorMessage: schemaResponse.statusMessage ?? "",
      );
    }
  }

  List<ClaimEntity> _filterManuallyIfPositiveInteger({
    required ProofRequestEntity request,
    required List<ClaimEntity> claimsFiltered,
  }) {
    try {
      if (request.scope.query.credentialSubject == null) return claimsFiltered;

      ProofScopeQueryRequest query = request.scope.query;
      Map<String, dynamic>? context =
          request.context["@context"][0][query.type]["@context"];
      if (context == null) return claimsFiltered;

      Map<String, dynamic> requestMap = request.scope.query.credentialSubject!;
      requestMap.forEach((key, map) {
        if (map == null || map is! Map || map.isEmpty) return;

        String type = _getTypeFromNestedObject(context, key);
        if (!type.contains("positiveInteger")) return;

        _processMap(map, key, claimsFiltered);
      });
    } catch (ignored) {
      // Consider logging the exception
    }
    return claimsFiltered;
  }

  void _processMap(dynamic map, String key, List<ClaimEntity> claimsFiltered) {
    map.forEach((operator, needle) {
      _filterClaims(operator, needle, key, claimsFiltered);
    });
  }

  void _filterClaims(String operator, dynamic needle, String key,
      List<ClaimEntity> claimsFiltered) {
    claimsFiltered.removeWhere((element) {
      Map<String, dynamic> credentialSubject =
          element.info["credentialSubject"];
      dynamic value = _getNestedValue(credentialSubject, key);
      if (value != null) {
        BigInt valueBigInt = BigInt.parse(value);
        switch (operator) {
          case '\$gt':
            return valueBigInt <= BigInt.from(needle);
          case '\$gte':
            return valueBigInt < BigInt.from(needle);
          case '\$lt':
            return valueBigInt >= BigInt.from(needle);
          case '\$lte':
            return valueBigInt > BigInt.from(needle);
          case '\$eq':
            return valueBigInt != BigInt.from(needle);
          case '\$neq':
            return valueBigInt == BigInt.from(needle);
          case '\$in':
            List<dynamic> values = List.from(needle);
            List<String> stringList = values.map((e) => e.toString()).toList();
            return !stringList.contains(value);
          case '\$nin':
            List<dynamic> values = List.from(needle);
            List<String> stringList = values.map((e) => e.toString()).toList();
            return stringList.contains(value);
        }
      }
      return false;
    });
  }

  List<ClaimEntity> _filterManuallyIfQueryContainsProofType({
    required ProofRequestEntity request,
    required List<ClaimEntity> claimsFiltered,
  }) {
    try {
      if (request.scope.query.proofType == null ||
          request.scope.query.proofType!.isEmpty) return claimsFiltered;

      String proofType = request.scope.query.proofType!;
      claimsFiltered.removeWhere((element) {
        List<Map<String, dynamic>> proofs = element.info["proof"];
        List<String> proofTypes =
            proofs.map((e) => e["type"] as String).toList();
        return !proofTypes.contains(proofType);
      });
    } catch (ignored) {
      // Consider logging the exception
    }
    return claimsFiltered;
  }

  String _getTypeFromNestedObject(
      Map<String, dynamic> contextMap, String nestedKey) {
    List<String> keys = nestedKey.split('.');
    dynamic value = contextMap;
    for (String key in keys) {
      if (value is Map<String, dynamic> && value[key].containsKey("@context")) {
        value = value[key]["@context"];
      } else if (value is Map<String, dynamic> &&
          value[key].containsKey("@type")) {
        value = value[key]["@type"];
        break;
      } else {
        break;
      }
    }
    return value;
  }

  ///
  dynamic _getNestedValue(Map<String, dynamic> map, String key) {
    List<String> keys = key.split('.');
    dynamic value = map;
    for (String key in keys) {
      if (value is Map<String, dynamic> && value.containsKey(key)) {
        value = value[key];
      } else {
        break;
      }
    }
    return value;
  }

  String generateLinkNonce() {
    final BigInt safeMaxVal = BigInt.parse(
        "21888242871839275222246405745257275088548364400416034343698204186575808495617");
    // get max value of 2 ^ 248
    BigInt base = BigInt.parse('2');
    int exponent = 248;
    final maxVal = base.pow(exponent) - BigInt.one;
    final random = Random.secure();
    BigInt randomNumber;
    do {
      randomNumber = randomBigInt(248, max: maxVal, random: random);
      if (kDebugMode) {
        logger().i("random number $randomNumber");
        logger().i("less than safeMax ${randomNumber < safeMaxVal}");
      }
    } while (randomNumber >= safeMaxVal);

    return randomNumber.toString();
  }

  /// SIGN MESSAGE WITH BJJ KEY
  Future<String> signMessage(
      {required Uint8List privateKey, required String message}) async {
    final walletDs = getItSdk<WalletDataSource>();
    return walletDs.signMessage(privateKey: privateKey, message: message);
  }

  Future<AuthBodyDidDocResponseDTO?> _getDidDoc({
    required String? pushUrl,
    required String? pushToken,
    required String? packageName,
    required String profileDid,
  }) async {
    if (pushUrl == null ||
        pushToken == null ||
        packageName == null ||
        pushUrl.isEmpty ||
        pushToken.isEmpty ||
        packageName.isEmpty) {
      return null;
    }

    return AuthBodyDidDocResponseDTO(
      context: const ["https://www.w3.org/ns/did/v1"],
      id: profileDid,
      service: [
        AuthBodyDidDocServiceResponseDTO(
          id: '$profileDid#mobile',
          type: 'Iden3MobileServiceV1',
          serviceEndpoint: 'iden3comm:v0.1:callbackHandler',
        ),
        AuthBodyDidDocServiceResponseDTO(
          id: "$profileDid#push",
          type: "push-notification",
          serviceEndpoint: pushUrl,
          metadata: AuthBodyDidDocServiceMetadataResponseDTO(devices: [
            AuthBodyDidDocServiceMetadataDevicesResponseDTO(
              ciphertext:
                  await _getPushCipherText(pushToken, pushUrl, packageName),
              alg: "RSA-OAEP-512",
            )
          ]),
        )
      ],
    );
  }

  Future<String> _getPushCipherText(
    String pushToken,
    String serviceEndpoint,
    String packageName,
  ) async {
    var pushInfo = {
      "app_id": packageName, //"com.polygonid.wallet",
      "pushkey": pushToken,
    };

    Dio dio = Dio();
    final dir = await getApplicationDocumentsDirectory();
    final path = dir.path;
    dio.interceptors.add(
      DioCacheInterceptor(
        options: CacheOptions(
          store: HiveCacheStore(path),
          policy: CachePolicy.request,
          hitCacheOnErrorExcept: [],
          maxStale: const Duration(days: 7),
          priority: CachePriority.high,
        ),
      ),
    );

    var publicKeyResponse =
        await dio.get(Uri.parse("$serviceEndpoint/public").toString());

    if (publicKeyResponse.statusCode == 200 ||
        publicKeyResponse.statusCode == 304) {
      String publicKeyPem = publicKeyResponse.data;
      var publicKey = RSAKeyParser().parse(publicKeyPem) as RSAPublicKey;
      final encrypter =
          OAEPEncoding.withCustomDigest(() => SHA512Digest(), RSAEngine());
      encrypter.init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
      Uint8List encrypted = encrypter
          .process(Uint8List.fromList(json.encode(pushInfo).codeUnits));
      return base64.encode(encrypted);
    } else {
      _stacktraceManager.addError(
        "[Authenticate] Error fetching public key: ${publicKeyResponse.statusCode} ${publicKeyResponse.statusMessage}",
      );
      throw NetworkException(
        statusCode: publicKeyResponse.statusCode ?? 0,
        errorMessage: publicKeyResponse.statusMessage ?? "",
      );
    }
  }

  Future<String> _getAuthToken({
    required String genesisDid,
    required BigInt profileNonce,
    required String privateKey,
    required Uint8List privateKeyBytes,
    required String message,
    required List<String> authClaim,
    required NodeEntity authClaimNode,
    required MTProofEntity incProof,
    required MTProofEntity nonRevProof,
    required Map<String, dynamic> treeState,
    required GistMTProofEntity gistProofEntity,
    required ProofRepository proofRepository,
    required EnvEntity env,
  }) async {
    JWZHeader header = JWZHeader(
      circuitId: AcceptAuthCircuits.AuthV2.name,
      crit: ["circuitId"],
      typ: MediaType.ZKPMessage.name,
      alg: AcceptJwzAlgorithms.Groth16.name,
    );

    JWZPayload payload = JWZPayload(payload: message);
    JWZEntity jwz = JWZEntity(
      header: header,
      payload: payload,
    );

    String jwzString = stringFromJwz(jwz);

    Uint8List sha = Uint8List.fromList(
        sha256.convert(Uint8ArrayUtils.uint8ListfromString(jwzString)).bytes);

    // Endianness
    BigInt endian = Uint8ArrayUtils.leBuff2int(sha);

    BigInt qNormalized = endian.qNormalize();

    String authChallenge = poseidon1([qNormalized]).toString();

    String signature = await signMessage(
      privateKey: privateKeyBytes,
      message: authChallenge,
    );

    final libPidCoreIden3commDS = getItSdk<LibPolygonIdCoreProofDataSource>();

    final inputsResponse = await libPidCoreIden3commDS.getAuthInputs(
      genesisDid: genesisDid,
      profileNonce: profileNonce,
      authClaim: authClaim,
      incProof: incProof.toJson(),
      nonRevProof: nonRevProof.toJson(),
      gistProof: gistProofEntity.toJson(),
      treeState: treeState,
      challenge: authChallenge,
      signature: signature,
      config: env.config.toJson(),
    );

    final appDir = await getApplicationDocumentsDirectory();
    final circuitsDataSource = CircuitsFilesDataSource(appDir);

    final circuitDatFileBytes =
        await circuitsDataSource.loadGraphFile('authV2');
    final zkeyFilePath = await circuitsDataSource.getZkeyFilePath('authV2');

    CircuitDataEntity circuitDataEntity = CircuitDataEntity(
      "authV2",
      circuitDatFileBytes,
      zkeyFilePath,
    );

    Uint8List witnessBytes = await proofRepository.calculateWitness(
      circuitData: circuitDataEntity,
      atomicQueryInputs: jsonEncode(inputsResponse.inputs),
    );

    ZKProofEntity zkProofEntity = await proofRepository.prove(
      circuitData: circuitDataEntity,
      wtnsBytes: witnessBytes,
    );

    JWZEntity jwzZkProof = JWZEntity(
      header: header,
      payload: payload,
      proof: zkProofEntity,
    );

    String jwzZkProofString = stringFromJwz(jwzZkProof);
    return jwzZkProofString;
  }

  String stringFromJwz(JWZEntity jwzEntity) {
    if (jwzEntity.header == null) {
      _stacktraceManager.addError(
        "[Authenticate] JWZ header is null",
      );
      throw NullJWZHeaderException(errorMessage: "JWZ header is null");
    }

    if (jwzEntity.payload == null) {
      _stacktraceManager.addError(
        "[Authenticate] JWZ payload is null",
      );
      throw NullJWZPayloadException(errorMessage: "JWZ payload is null");
    }

    String header = Base64Util.encode64(jsonEncode(jwzEntity.header));
    String payload = "." + Base64Util.encode64(jwzEntity.payload!.payload);
    String proof = jwzEntity.proof != null
        ? "." + Base64Util.encode64(jsonEncode(jwzEntity.proof))
        : "";

    return "$header$payload$proof";
  }

  Future<AuthClaimCompanionObject> getAuthClaim({
    required String privateKey,
    required String genesisDid,
    required EnvEntity env,
    required ChainConfigEntity chain,
    required Uint8List privateKeyBytes,
    required String authClaimNonce,
  }) async {
    List<String>? authClaim;
    MTProofEntity? incProof;
    MTProofEntity? nonRevProof;
    GistMTProofEntity? gistProofEntity;
    Map<String, dynamic>? treeState;
    var libPolygonIdCredential =
        getItSdk<LibPolygonIdCoreCredentialDataSource>();

    final identityRepo = await getItSdk.getAsync<IdentityRepository>();
    final publicKey = await identityRepo.getPublicKeys(privateKey: privateKey);

    String authClaimSchema = AUTH_CLAIM_SCHEMA;
    String issuedAuthClaim = libPolygonIdCredential.issueClaim(
      schema: authClaimSchema,
      nonce: authClaimNonce,
      publicKey: publicKey,
    );
    authClaim = List.from(jsonDecode(issuedAuthClaim));
    BigInt hashIndex = poseidon4([
      BigInt.parse(authClaim[0]),
      BigInt.parse(authClaim[1]),
      BigInt.parse(authClaim[2]),
      BigInt.parse(authClaim[3]),
    ]);
    BigInt hashValue = poseidon4([
      BigInt.parse(authClaim[4]),
      BigInt.parse(authClaim[5]),
      BigInt.parse(authClaim[6]),
      BigInt.parse(authClaim[7]),
    ]);
    BigInt hashClaimNode = poseidon3([
      hashIndex,
      hashValue,
      BigInt.one,
    ]);
    NodeEntity authClaimNode = NodeEntity(
      children: [
        HashEntity.fromBigInt(hashIndex),
        HashEntity.fromBigInt(hashValue),
        HashEntity.fromBigInt(BigInt.one),
      ],
      hash: HashEntity.fromBigInt(hashClaimNode),
      type: NodeType.leaf,
    );

    // INC PROOF
    SMTRepository smtRepository = getItSdk<SMTRepository>();
    incProof = await smtRepository.generateProof(
      key: authClaimNode.hash,
      type: TreeType.claims,
      did: genesisDid,
      privateKey: privateKey,
    );

    // NON REV PROOF
    nonRevProof = await smtRepository.generateProof(
      key: authClaimNode.hash,
      type: TreeType.revocation,
      did: genesisDid,
      privateKey: privateKey,
    );

    // TREE STATE
    List<HashEntity> trees = await Future.wait(
      [
        smtRepository.getRoot(
          type: TreeType.claims,
          did: genesisDid,
          privateKey: privateKey,
        ),
        smtRepository.getRoot(
          type: TreeType.revocation,
          did: genesisDid,
          privateKey: privateKey,
        ),
        smtRepository.getRoot(
          type: TreeType.roots,
          did: genesisDid,
          privateKey: privateKey,
        ),
      ],
      eagerError: true,
    );

    String hash = await smtRepository.hashState(
      claims: trees[0].string(),
      revocation: trees[1].string(),
      roots: trees[2].string(),
    );

    TreeStateEntity treeStateEntity = TreeStateEntity(
      hash,
      trees[0],
      trees[1],
      trees[2],
    );

    treeState = await smtRepository.convertState(
      state: treeStateEntity,
    );

    //GIST
    List<String> splittedDid = genesisDid.split(":");
    String id = splittedDid[4];
    var libPolygonIdIdentity = getItSdk<LibPolygonIdCoreIdentityDataSource>();
    String convertedId = libPolygonIdIdentity.genesisIdToBigInt(id);
    ContractAbi contractAbi = ContractAbi.fromJson(
        jsonEncode(jsonDecode(stateAbiJson)["abi"]), 'State');
    EthereumAddress ethereumAddress =
        EthereumAddress.fromHex(chain.stateContractAddr);
    DeployedContract contract = DeployedContract(contractAbi, ethereumAddress);

    String gistProof = await GistProofCache().getGistProof(
      id: convertedId,
      deployedContract: contract,
      envEntity: env,
    );

    final gistMTProofDataSource = getItSdk<GistMTProofDataSource>();
    gistProofEntity = gistMTProofDataSource.getGistMTProof(gistProof);

    return AuthClaimCompanionObject()
      ..authClaim = authClaim
      ..incProof = incProof
      ..nonRevProof = nonRevProof
      ..gistProofEntity = gistProofEntity
      ..treeState = treeState
      ..authClaimNode = authClaimNode;
  }

  Future<ClaimEntity> _checkCredentialExpirationAndTryRefreshIfExpired({
    required ClaimEntity claim,
    required String genesisDid,
    required String privateKey,
  }) async {
    var now = DateTime.now().toUtc();
    DateTime expirationTime =
        DateFormat("yyyy-MM-ddTHH:mm:ssZ").parse(claim.expiration!);

    var nowFormatted = DateFormat("yyyy-MM-dd HH:mm:ss").format(now);
    var expirationTimeFormatted =
        DateFormat("yyyy-MM-dd HH:mm:ss").format(expirationTime);
    bool isExpired = nowFormatted.compareTo(expirationTimeFormatted) > 0 ||
        claim.state == ClaimState.expired;

    if (isExpired && claim.info.containsKey("refreshService")) {
      _proofGenerationStepsStreamManager
          .add("Refreshing expired credential...");

      RefreshCredentialUseCase _refreshCredentialUseCase =
          await getItSdk.getAsync<RefreshCredentialUseCase>();

      ClaimEntity refreshedClaimEntity =
          await _refreshCredentialUseCase.execute(
              param: RefreshCredentialParam(
        credential: claim,
        genesisDid: genesisDid,
        privateKey: privateKey,
      ));

      claim = refreshedClaimEntity;
    }
    return claim;
  }
}

class AuthClaimCompanionObject {
  List<String>? authClaim;
  MTProofEntity? incProof;
  MTProofEntity? nonRevProof;
  GistMTProofEntity? gistProofEntity;
  Map<String, dynamic>? treeState;
  NodeEntity? authClaimNode;
}
