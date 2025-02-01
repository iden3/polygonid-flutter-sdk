import 'package:polygonid_flutter_sdk/identity/domain/entities/node_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/hash_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/tree_state_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/tree_type.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/mtproof_dto.dart';

abstract class SMTRepository {
  Future<void> addLeaf({
    required NodeEntity leaf,
    required TreeType type,
    required String did,
    required String encryptionKey,
  });

  Future<NodeEntity> getNode({
    required HashEntity hash,
    required TreeType type,
    required String did,
    required String encryptionKey,
  });

  Future<void> addNode({
    required HashEntity hash,
    required NodeEntity node,
    required TreeType type,
    required String did,
    required String encryptionKey,
  });

  Future<HashEntity> getRoot({
    required TreeType type,
    required String did,
    required String encryptionKey,
  });

  Future<void> setRoot({
    required HashEntity root,
    required TreeType type,
    required String did,
    required String encryptionKey,
  });

  /// TODO: use this through an UC
  Future<MTProofEntity> generateProof({
    required HashEntity key,
    required TreeType type,
    required String did,
    required String encryptionKey,
  });

  Future<void> createSMT({
    required int maxLevels,
    required TreeType type,
    required String did,
    required String encryptionKey,
  });

  Future<void> removeSMT({
    required TreeType type,
    required String did,
    required String encryptionKey,
  });

  Future<String> hashState({
    required String claims,
    required String revocation,
    required String roots,
  });

  Future<Map<String, dynamic>> convertState({
    required TreeStateEntity state,
  });
}
