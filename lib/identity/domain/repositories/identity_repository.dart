import 'package:polygonid_flutter_sdk/common/domain/entities/env_config_entity.dart';
import 'package:polygonid_flutter_sdk/identity/data/dtos/id_description.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/node_entity.dart';

import '../entities/identity_entity.dart';
import '../entities/rhs_node_entity.dart';

abstract class IdentityRepository {
  Future<String> getPrivateKey({
    required String? secret,
  });

  Future<List<String>> getPublicKeys({
    required String bjjPrivateKey,
  });

  Future<void> storeIdentity({required IdentityEntity identity});

  Future<void> removeIdentity({required String genesisDid});

  Future<IdentityEntity> getIdentity({required String genesisDid});

  Future<List<IdentityEntity>> getIdentities();

  Future<String> signMessage({
    required String privateKey,
    required String message,
  });

  Future<String> getDidIdentifier({
    required String claimsRoot,
    required String blockchain,
    required String network,
    required BigInt profileNonce,
    required EnvConfigEntity config,
    String? method,
  });

  Future<String> getEthDidIdentifier({
    required String ethAddress,
    required String blockchain,
    required String network,
    required BigInt profileNonce,
    required EnvConfigEntity config,
    String? method,
  });

  String getPrivateProfileForGenesisDid({
    required String genesisDid,
    required BigInt profileNonce,
  });

  // RHS
  Future<Map<String, dynamic>> getNonRevProof({
    required String identityState,
    required BigInt nonce,
    required String baseUrl,
    Map<String, dynamic>? cachedNonRevProof,
  });

  Future<String> getState({
    required String identifier,
    required String contractAddress,
  });

  Future<String> convertIdToBigInt({required String id});

  Future<IdDescription> describeId(
      {required BigInt id, EnvConfigEntity? config});

  Future<RhsNodeEntity> getStateRoots({required String url});

  Future<NodeEntity> getAuthClaimNode({required List<String> children});

  Future<String> exportIdentity({
    required String did,
    required String encryptionKey,
  });

  Future<void> importIdentity({
    required String did,
    required String encryptionKey,
    required String encryptedDb,
  });

  Future<void> putProfiles({
    required String did,
    required String encryptionKey,
    required Map<BigInt, String> profiles,
  });

  Future<Map<BigInt, String>> getProfiles({
    required String did,
    required String encryptionKey,
  });
}
