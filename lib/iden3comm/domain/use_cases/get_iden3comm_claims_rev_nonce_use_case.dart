import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/get_claim_revocation_nonce_use_case.dart';
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/get_claims_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/request/proof_request_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/repositories/iden3comm_credential_repository.dart';
import 'package:polygonid_flutter_sdk/proof/domain/use_cases/is_proof_circuit_supported_use_case.dart';

import 'get_proof_requests_use_case.dart';

class GetIden3commClaimsRevNonceParam {
  final Iden3MessageEntity message;
  final String genesisDid;
  final BigInt profileNonce;
  final String encryptionKey;

  GetIden3commClaimsRevNonceParam({
    required this.message,
    required this.genesisDid,
    required this.profileNonce,
    required this.encryptionKey,
  });
}

class GetIden3commClaimsRevNonceUseCase
    extends FutureUseCase<GetIden3commClaimsRevNonceParam, List<int>> {
  final Iden3commCredentialRepository _iden3commCredentialRepository;
  final GetClaimsUseCase _getClaimsUseCase;
  final GetClaimRevocationNonceUseCase _getClaimRevNonceUseCase;
  final IsProofCircuitSupportedUseCase _isProofCircuitSupported;
  final GetProofRequestsUseCase _getProofRequestsUseCase;

  GetIden3commClaimsRevNonceUseCase(
    this._iden3commCredentialRepository,
    this._getClaimsUseCase,
    this._getClaimRevNonceUseCase,
    this._isProofCircuitSupported,
    this._getProofRequestsUseCase,
  );

  @override
  Future<List<int>> execute({
    required GetIden3commClaimsRevNonceParam param,
  }) async {
    Set<int> claimsRevNonce = <int>{};

    final requests = await _getProofRequestsUseCase.execute(
      param: param.message,
    );

    /// We got [ProofRequestEntity], let's find the associated [ClaimEntity]
    for (ProofRequestEntity request in requests) {
      final isProofCircuitSupported = await _isProofCircuitSupported.execute(
          param: request.scope.circuitId);

      if (isProofCircuitSupported) {
        // Claims
        final filters = await _iden3commCredentialRepository.getFilters(
          request: request,
        );
        final claims = await _getClaimsUseCase.execute(
          param: GetClaimsParam(
            filters: filters,
            genesisDid: param.genesisDid,
            profileNonce: param.profileNonce,
            encryptionKey: param.encryptionKey,
          ),
        );

        for (int i = 0; i < claims.length; i++) {
          int revNonce = await _getClaimRevNonceUseCase.execute(
            param: claims[i],
          );
          claimsRevNonce.add(revNonce);
        }
      }
    }
    return claimsRevNonce.toList();
  }
}
