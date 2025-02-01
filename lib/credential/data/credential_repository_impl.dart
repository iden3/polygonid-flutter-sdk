import 'package:polygonid_flutter_sdk/common/data/data_sources/mappers/filters_mapper.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/filter_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/error_exception.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/common/utils/credential_sort_order.dart';
import 'package:polygonid_flutter_sdk/credential/data/data_sources/cache_claim_data_source.dart';
import 'package:polygonid_flutter_sdk/credential/data/data_sources/remote_claim_data_source.dart';
import 'package:polygonid_flutter_sdk/credential/data/data_sources/storage_claim_data_source.dart';
import 'package:polygonid_flutter_sdk/credential/data/dtos/claim_dto.dart';
import 'package:polygonid_flutter_sdk/credential/data/mappers/claim_mapper.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/credential/domain/exceptions/credential_exceptions.dart';
import 'package:polygonid_flutter_sdk/credential/domain/repositories/credential_repository.dart';

import 'data_sources/local_claim_data_source.dart';
import 'dtos/claim_info_dto.dart';

class CredentialRepositoryImpl extends CredentialRepository {
  final RemoteClaimDataSource _remoteClaimDataSource;
  final StorageClaimDataSource _storageClaimDataSource;
  final LocalClaimDataSource _localClaimDataSource;
  final CacheCredentialDataSource _cacheCredentialDataSource;
  final ClaimMapper _claimMapper;
  final FiltersMapper _filtersMapper;
  final StacktraceManager _stacktraceManager;

  CredentialRepositoryImpl(
    this._remoteClaimDataSource,
    this._storageClaimDataSource,
    this._localClaimDataSource,
    this._cacheCredentialDataSource,
    this._claimMapper,
    this._filtersMapper,
    this._stacktraceManager,
  );

  @override
  Future<void> saveClaims({
    required List<ClaimEntity> claims,
    required String genesisDid,
    required String encryptionKey,
  }) async {
    try {
      final List<ClaimDTO> claimDTOList =
          claims.map((claim) => _claimMapper.mapTo(claim)).toList();
      await _storageClaimDataSource.storeClaims(
        claims: claimDTOList,
        did: genesisDid,
        encryptionKey: encryptionKey,
      );
    } on PolygonIdSDKException catch (_) {
      rethrow;
    } catch (error) {
      _stacktraceManager
          .addError('Error while saving claims in the DB\n${error.toString()}');
      throw SaveClaimException(
        errorMessage:
            'Error while saving claims in the DB\n${error.toString()}',
        error: error,
      );
    }
  }

  @override
  Future<List<ClaimEntity>> getClaims({
    List<FilterEntity>? filters,
    required String genesisDid,
    required String encryptionKey,
    List<CredentialSortOrder> credentialSortOrderList = const [],
  }) async {
    try {
      final claimDTOs = await _storageClaimDataSource.getClaims(
        filter: filters == null ? null : _filtersMapper.mapTo(filters),
        did: genesisDid,
        encryptionKey: encryptionKey,
        credentialSortOrderList: credentialSortOrderList,
      );

      final List<ClaimEntity> claimEntityList =
          claimDTOs.map((claim) => _claimMapper.mapFrom(claim)).toList();
      return claimEntityList;
    } on PolygonIdSDKException catch (_) {
      rethrow;
    } catch (error) {
      _stacktraceManager
          .addError('Error while getting claims from DB\n${error.toString()}');
      throw GetClaimsException(
        errorMessage: "Error while getting claims from DB\n${error.toString()}",
        error: error,
      );
    }
  }

  @override
  Future<ClaimEntity> getClaim({
    required String claimId,
    required String genesisDid,
    required String encryptionKey,
  }) async {
    try {
      ClaimDTO claimDTO = await _storageClaimDataSource.getClaim(
        credentialId: claimId,
        did: genesisDid,
        encryptionKey: encryptionKey,
      );

      ClaimEntity claimEntity = _claimMapper.mapFrom(claimDTO);
      return claimEntity;
    } on PolygonIdSDKException catch (_) {
      rethrow;
    } catch (e) {
      _stacktraceManager
          .addError('Error while getting claim from DB\n${e.toString()}');
      throw ClaimNotFoundException(
        id: claimId,
        errorMessage: 'Credential not found',
      );
    }
  }

  @override
  Future<ClaimEntity> getCredentialByPartialId({
    required String partialId,
    required String genesisDid,
    required String encryptionKey,
  }) async {
    try {
      final claimDTOs = await _storageClaimDataSource.getCredentialByPartialId(
        partialId: partialId,
        did: genesisDid,
        encryptionKey: encryptionKey,
      );

      if (claimDTOs.isEmpty || claimDTOs.length > 1) {
        _stacktraceManager
            .addError('Error while getting claim by partial id from DB\n');
        throw ClaimNotFoundException(
          id: partialId,
          errorMessage: 'Credential by partial id not found',
        );
      }

      ClaimEntity claimEntity = _claimMapper.mapFrom(claimDTOs.first);
      return claimEntity;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeClaims({
    required List<String> claimIds,
    required String genesisDid,
    required String encryptionKey,
  }) async {
    try {
      await _storageClaimDataSource.removeClaims(
        claimIds: claimIds,
        did: genesisDid,
        encryptionKey: encryptionKey,
      );
    } on PolygonIdSDKException catch (_) {
      rethrow;
    } catch (error) {
      _stacktraceManager
          .addError('Error while removing claims from DB\n${error.toString()}');
      throw RemoveClaimsException(
        errorMessage:
            'Error while removing claims from DB\n${error.toString()}',
        error: error,
      );
    }
  }

  @override
  Future<void> removeAllClaims({
    required String genesisDid,
    required String encryptionKey,
  }) async {
    try {
      await _storageClaimDataSource.removeAllClaims(
        did: genesisDid,
        encryptionKey: encryptionKey,
      );
    } on PolygonIdSDKException catch (_) {
      rethrow;
    } catch (error) {
      _stacktraceManager.addError(
          'Error while removing all claims from DB\n${error.toString()}');
      throw RemoveClaimsException(
        errorMessage:
            'Error while removing all claims from DB\n${error.toString()}',
        error: error,
      );
    }
  }

  Future<String> getRhsRevocationId({required ClaimEntity claim}) {
    ClaimDTO claimDTO = _claimMapper.mapTo(claim);
    try {
      return Future.value(claimDTO.info.proofs
          .where((proof) => proof.type == "BJJSignature2021")
          .first
          .issuer
          .id);
    } on PolygonIdSDKException catch (_) {
      rethrow;
    } catch (error) {
      _stacktraceManager
          .addError('Error while getting revocation id\n${error.toString()}');
      throw NullRevocationStatusException(
        claim: claim,
        errorMessage: 'error while getting revocation id',
      );
    }
  }

  @override
  Future<String> getIssuerIdentifier({required ClaimEntity claim}) async {
    return _claimMapper.mapTo(claim).info.issuer;
  }

  @override
  Future<Map<String, dynamic>> getRevocationStatus({
    required ClaimEntity claim,
  }) async {
    final revStatusUrl = await getRevocationUrl(claim: claim, rhs: false);
    return _remoteClaimDataSource.getClaimRevocationStatus(revStatusUrl);
  }

  @override
  Future<bool> isUsingRHS({required ClaimEntity claim}) async {
    final claimDTO = _claimMapper.mapTo(claim);
    return claimDTO.info.credentialStatus.type ==
        CredentialStatusType.reverseSparseMerkleTreeProof;
  }

  @override
  Future<int> getRevocationNonce({
    required ClaimEntity claim,
    required bool rhs,
  }) {
    try {
      return Future.value(_claimMapper.mapTo(claim)).then(
        (claimDTO) => (claimDTO.info.credentialStatus.type ==
                CredentialStatusType.reverseSparseMerkleTreeProof
            ? (rhs
                ? claimDTO.info.credentialStatus.revocationNonce!
                : claimDTO.info.credentialStatus.statusIssuer!.revocationNonce!)
            : (rhs == false
                ? claimDTO.info.credentialStatus.revocationNonce!
                : throw NullRevocationStatusException(
                    claim: claim,
                    errorMessage: 'Revocation nonce not found',
                  ))),
      );
    } catch (error) {
      _stacktraceManager.addError(
          'Error while getting revocation nonce\n${error.toString()}');
      throw NullRevocationStatusException(
        claim: claim,
        errorMessage: 'error while getting revocation nonce',
      );
    }
  }

  @override
  Future<String> getRevocationUrl({
    required ClaimEntity claim,
    required bool rhs,
  }) {
    try {
      return Future.value(_claimMapper.mapTo(claim)).then((claimDTO) =>
          (claimDTO.info.credentialStatus.type ==
                  CredentialStatusType.reverseSparseMerkleTreeProof
              ? (rhs
                  ? claimDTO.info.credentialStatus.id
                  : claimDTO.info.credentialStatus.statusIssuer!.id)
              : (rhs == false
                  ? claimDTO.info.credentialStatus.id
                  : throw NullRevocationStatusException(
                      claim: claim,
                      errorMessage: 'Revocation url not found',
                    ))));
    } catch (error) {
      _stacktraceManager
          .addError('Error while getting revocation url\n${error.toString()}');
      throw NullRevocationStatusException(
        claim: claim,
        errorMessage: 'error while getting revocation url',
      );
    }
  }

  @override
  Future<List<String>> getAuthClaim({required List<String> publicKey}) {
    return _localClaimDataSource.getAuthClaim(publicKey: publicKey);
  }

  @override
  Future<bool> cacheCredential({
    required String credential,
    String? config,
  }) {
    return _cacheCredentialDataSource.cacheCredential(
      credential: credential,
      config: config,
    );
  }
}
