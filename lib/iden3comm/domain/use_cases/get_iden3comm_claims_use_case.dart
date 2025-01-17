import 'package:collection/collection.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/filter_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/common/utils/credential_sort_order.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/get_claims_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/request/proof_request_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/request/proof_scope_query_request.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/exceptions/iden3comm_exceptions.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/repositories/iden3comm_credential_repository.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_proof_requests_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/data/dtos/circuit_type.dart';
import 'package:polygonid_flutter_sdk/proof/domain/exceptions/proof_generation_exceptions.dart';
import 'package:polygonid_flutter_sdk/proof/domain/use_cases/is_proof_circuit_supported_use_case.dart';

class GetIden3commClaimsParam {
  final Iden3MessageEntity message;
  final String genesisDid;
  final BigInt profileNonce;
  final String encryptionKey;
  final Map<int, Map<String, dynamic>> nonRevocationProofs;

  List<CredentialSortOrder> credentialSortOrderList;

  GetIden3commClaimsParam({
    required this.message,
    required this.genesisDid,
    required this.profileNonce,
    required this.encryptionKey,
    required this.nonRevocationProofs,
    this.credentialSortOrderList = const [],
  });
}

class GetIden3commClaimsUseCase
    extends FutureUseCase<GetIden3commClaimsParam, List<ClaimEntity?>> {
  final Iden3commCredentialRepository _iden3commCredentialRepository;
  final GetClaimsUseCase _getClaimsUseCase;
  final IsProofCircuitSupportedUseCase _isProofCircuitSupported;
  final GetProofRequestsUseCase _getProofRequestsUseCase;
  final StacktraceManager _stacktraceManager;

  GetIden3commClaimsUseCase(
    this._iden3commCredentialRepository,
    this._getClaimsUseCase,
    this._isProofCircuitSupported,
    this._getProofRequestsUseCase,
    this._stacktraceManager,
  );

  @override
  Future<List<ClaimEntity?>> execute({
    required GetIden3commClaimsParam param,
  }) async {
    List<ClaimEntity?> claims = [];

    List<ProofRequestEntity> requests =
        await _getProofRequestsUseCase.execute(param: param.message);
    _stacktraceManager
        .addTrace("[GetIden3commClaimsUseCase] requests: $requests");

    var groupedByGroupId = groupBy(requests, (obj) => obj.scope.query.groupId);

    Map<int, List<ClaimEntity>> claimsByGroupId = {};

    for (var group in groupedByGroupId.entries) {
      int? groupId = group.key;
      if (groupId == null) {
        continue;
      }
      List<ProofRequestEntity> groupRequests = group.value;
      List<FilterEntity> filtersForQueryClaimDb = [];
      for (ProofRequestEntity request in groupRequests) {
        bool supportedCircuit = await _isProofCircuitSupported.execute(
            param: request.scope.circuitId);
        if (!supportedCircuit) {
          continue; //TODO maybe throw exception
        }
        List<FilterEntity> filterForSingleRequest =
            await _iden3commCredentialRepository.getFilters(request: request);
        filtersForQueryClaimDb.addAll(filterForSingleRequest);
        filtersForQueryClaimDb = filtersForQueryClaimDb.toSet().toList();
      }

      List<ClaimEntity> claimsFiltered = await _getClaimsUseCase.execute(
        param: GetClaimsParam(
          filters: filtersForQueryClaimDb,
          genesisDid: param.genesisDid,
          profileNonce: param.profileNonce,
          encryptionKey: param.encryptionKey,
          credentialSortOrderList: param.credentialSortOrderList,
        ),
      );
      claimsByGroupId[groupId] = claimsFiltered;
    }

    /// We got [ProofRequestEntity], let's find the associated [ClaimEntity]
    for (ProofRequestEntity request in requests) {
      // we check if circuit from the request is supported
      bool supportedCircuit = await _isProofCircuitSupported.execute(
          param: request.scope.circuitId);
      if (!supportedCircuit) {
        continue; //TODO maybe throw exception
      }

      List<ClaimEntity> validClaims = [];

      int? requestGroupId = request.scope.query.groupId;
      if (requestGroupId != null &&
          claimsByGroupId.containsKey(requestGroupId)) {
        validClaims = claimsByGroupId[requestGroupId] ?? [];
      } else {
        List<FilterEntity> filters =
            await _iden3commCredentialRepository.getFilters(request: request);
        _stacktraceManager
            .addTrace("[GetIden3commClaimsUseCase] filters: $filters");

        List<ClaimEntity> claimsFiltered = await _getClaimsUseCase.execute(
          param: GetClaimsParam(
            filters: filters,
            genesisDid: param.genesisDid,
            profileNonce: param.profileNonce,
            encryptionKey: param.encryptionKey,
            credentialSortOrderList: param.credentialSortOrderList,
          ),
        );

        validClaims = claimsFiltered;
      }

      // filter manually positive integer
      validClaims = _filterManuallyIfPositiveInteger(
        request: request,
        claimsFiltered: validClaims,
      );

      //filter manually proof type
      validClaims = _filterManuallyIfQueryContainsProofType(
        request: request,
        claimsFiltered: validClaims,
      );

      if (validClaims.isEmpty) {
        _stacktraceManager
            .addTrace("[GetIden3commClaimsUseCase] claims is empty");
        continue;
      }

      var validClaim = validClaims.firstWhereOrNull((element) {
        List<Map<String, dynamic>> proofs = element.info["proof"];
        List<String> proofTypes =
            proofs.map((e) => e["type"] as String).toList();

        final circuitId = request.scope.circuitId;
        // TODO (moria): remove this with v3 circuit release
        if (circuitId.startsWith(CircuitType.v3CircuitPrefix) &&
            !circuitId.endsWith(CircuitType.currentCircuitBetaPostfix)) {
          _stacktraceManager.addTrace(
              "V3 circuit beta version mismatch $circuitId is not supported, current is ${CircuitType.currentCircuitBetaPostfix}");
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
        _stacktraceManager.addTrace(
            "[GetIden3commClaimsUseCase] claims has no valid proof type");
        continue;
      }

      claims.add(validClaim);
    }

    /// If we have requests but didn't get any proofs, we throw
    /// as it could be we didn't find any associated [ClaimEntity]
    if (requests.isNotEmpty && claims.isEmpty ||
        claims.length != requests.length) {
      _stacktraceManager.addTrace(
          "[GetIden3commClaimsUseCase] error getting claims for requests: $requests");
      _stacktraceManager.addError(
          "[GetIden3commClaimsUseCase] error getting claims for requests: $requests");
      throw CredentialsNotFoundException(
        proofRequests: requests,
        errorMessage: "Error getting claims for requests",
      );
    }

    return claims;
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

  /// The positiveInteger type is not supported by the filter 'cause this type
  /// is stored as a string in the database. So we need to filter manually
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
    // Implement the filtering logic here, similar to what you have in your switch case
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
}
