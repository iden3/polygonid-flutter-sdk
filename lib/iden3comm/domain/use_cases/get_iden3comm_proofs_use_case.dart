import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:ninja_prime/ninja_prime.dart';

import 'package:intl/intl.dart';
import 'package:polygonid_flutter_sdk/common/domain/domain_constants.dart';
import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/env_config_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/common/utils/credential_sort_order.dart';
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/refresh_credential_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/proof/response/iden3comm_proof_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/request/proof_request_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/exceptions/iden3comm_exceptions.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/generate_iden3comm_proof_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/data/dtos/circuit_type.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/get_identity_use_case.dart';
import 'package:polygonid_flutter_sdk/proof/domain/use_cases/is_proof_circuit_supported_use_case.dart';
import 'package:polygonid_flutter_sdk/proof/infrastructure/proof_generation_stream_manager.dart';

import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/circuit_data_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/repositories/proof_repository.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_iden3comm_claims_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_proof_requests_use_case.dart';

class GetIden3commProofsParam {
  final Iden3MessageEntity message;
  final String genesisDid;
  final BigInt profileNonce;
  final String privateKey;
  final String? challenge;
  final EnvConfigEntity? config;
  final Map<int, Map<String, dynamic>>? nonRevocationProofs;

  final Map<String, dynamic>? transactionData;

  GetIden3commProofsParam({
    required this.message,
    required this.genesisDid,
    required this.profileNonce,
    required this.privateKey,
    this.challenge,
    this.config,
    this.nonRevocationProofs,
    this.transactionData,
  });
}

class GetIden3commProofsUseCase
    extends FutureUseCase<GetIden3commProofsParam, List<Iden3commProofEntity>> {
  final ProofRepository _proofRepository;
  final GetIden3commClaimsUseCase _getIden3commClaimsUseCase;
  final GenerateIden3commProofUseCase _generateIden3commProofUseCase;
  final IsProofCircuitSupportedUseCase _isProofCircuitSupported;
  final GetProofRequestsUseCase _getProofRequestsUseCase;
  final GetIdentityUseCase _getIdentityUseCase;
  final ProofGenerationStepsStreamManager _proofGenerationStepsStreamManager;
  final StacktraceManager _stacktraceManager;

  final RefreshCredentialUseCase _refreshCredentialUseCase;

  GetIden3commProofsUseCase(
    this._proofRepository,
    this._getIden3commClaimsUseCase,
    this._generateIden3commProofUseCase,
    this._isProofCircuitSupported,
    this._getProofRequestsUseCase,
    this._getIdentityUseCase,
    this._proofGenerationStepsStreamManager,
    this._stacktraceManager,
    this._refreshCredentialUseCase,
  );

  @override
  Future<List<Iden3commProofEntity>> execute({
    required GetIden3commProofsParam param,
  }) async {
    try {
      List<Iden3commProofEntity> proofs = [];
      Map<int, String> groupIdLinkNonceMap = {};

      _proofGenerationStepsStreamManager.add("Getting proof requests");
      List<ProofRequestEntity> requests =
          await _getProofRequestsUseCase.execute(param: param.message);
      _stacktraceManager
          .addTrace("[GetIden3commProofsUseCase] requests: $requests");

      List<ClaimEntity?> claims = await _getIden3commClaimsUseCase.execute(
        param: GetIden3commClaimsParam(
          message: param.message,
          genesisDid: param.genesisDid,
          profileNonce: param.profileNonce,
          encryptionKey: param.privateKey,
          nonRevocationProofs: param.nonRevocationProofs ?? {},
          credentialSortOrderList: [CredentialSortOrder.ExpirationDescending],
        ),
      );
      _stacktraceManager.addTrace(
          "[GetIden3commProofsUseCase] claims found: ${claims.length}");

      if ((requests.isNotEmpty &&
              claims.isNotEmpty &&
              requests.length == claims.length) ||
          requests.isEmpty) {
        /// We got [ProofRequestEntity], let's find the associated [ClaimEntity]
        /// and generate [ProofEntity]
        for (int i = 0; i < requests.length; i++) {
          ProofRequestEntity request = requests[i];
          ClaimEntity? claim = claims[i];

          if (claim == null) {
            continue;
          }

          if (claim.expiration != null) {
            claim = await _checkCredentialExpirationAndTryRefreshIfExpired(
              claim: claim,
              param: param,
            );
          }

          bool isCircuitSupported = await _isProofCircuitSupported.execute(
            param: request.scope.circuitId,
          );
          bool isCorrectType = claim.type == request.scope.query.type;

          if (isCorrectType && isCircuitSupported) {
            String circuitId = request.scope.circuitId;
            CircuitDataEntity circuitData =
                await _proofRepository.loadCircuitFiles(circuitId);

            String? challenge;
            String? privKey;
            if (circuitId == CircuitType.mtponchain.name ||
                circuitId == CircuitType.sigonchain.name ||
                circuitId == CircuitType.circuitsV3onchain.name) {
              privKey = param.privateKey;
              challenge = param.challenge;
            }

            var identityEntity = await _getIdentityUseCase.execute(
              param: GetIdentityParam(
                genesisDid: param.genesisDid,
                privateKey: param.privateKey,
              ),
            );

            BigInt claimSubjectProfileNonce = identityEntity.profiles.keys
                .firstWhere((k) => identityEntity.profiles[k] == claim!.did,
                    orElse: () => GENESIS_PROFILE_NONCE);

            int? groupId = request.scope.query.groupId;
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

            _proofGenerationStepsStreamManager
                .add("#${i + 1} creating proof for ${claim.type}");

            // Generate proof param
            GenerateIden3commProofParam proofParam =
                GenerateIden3commProofParam(
              did: param.genesisDid,
              profileNonce: param.profileNonce,
              claimSubjectProfileNonce: claimSubjectProfileNonce,
              credential: claim,
              request: request.scope,
              circuitData: circuitData,
              privateKey: privKey,
              challenge: challenge,
              config: param.config,
              verifierId: param.message.from,
              linkNonce: linkNonce,
              transactionData: param.transactionData,
            );

            // Generate proof
            Iden3commProofEntity proof =
                await _generateIden3commProofUseCase.execute(
              param: proofParam,
            );

            proofs.add(proof);
          }
        }
      } else {
        _stacktraceManager.addTrace(
            "[GetIden3commProofsUseCase] CredentialsNotFoundException - requests: $requests");
        _stacktraceManager.addError(
            "[GetIden3commProofsUseCase] CredentialsNotFoundException - requests: $requests");
        throw CredentialsNotFoundException(
          errorMessage: "Credentials not found for requests",
          proofRequests: requests,
        );
      }

      /// If we have requests but didn't get any proofs, we throw
      /// as it could be we didn't find any associated [ClaimEntity]
      if (requests.isNotEmpty && proofs.isEmpty ||
          proofs.length != requests.length) {
        _stacktraceManager.addTrace(
            "[GetIden3commProofsUseCase] ProofsNotFoundException - requests: $requests");
        _stacktraceManager.addError(
            "[GetIden3commProofsUseCase] ProofsNotFoundException - requests: $requests");
        throw ProofsNotCreatedException(
          proofRequests: requests,
          errorMessage: "Proofs not created for requests",
        );
      }

      return proofs;
    } catch (e) {
      _stacktraceManager.addTrace("[GetIden3commProofsUseCase] Exception: $e");
      rethrow;
    }
  }

  /// We generate a random linkNonce for each groupId
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

  /// Check if the credential is expired and try to refresh it if it is
  /// and if it has a refresh service
  Future<ClaimEntity> _checkCredentialExpirationAndTryRefreshIfExpired({
    required ClaimEntity claim,
    required GetIden3commProofsParam param,
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

      ClaimEntity refreshedClaimEntity =
          await _refreshCredentialUseCase.execute(
              param: RefreshCredentialParam(
        credential: claim,
        genesisDid: param.genesisDid,
        privateKey: param.privateKey,
      ));

      claim = refreshedClaimEntity;
    }
    return claim;
  }
}
