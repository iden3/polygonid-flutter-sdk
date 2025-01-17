import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/identity/data/data_sources/storage_smt_data_source.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/hash_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/node_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/exceptions/smt_exceptions.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/mtproof_dto.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/node_aux_entity.dart';
import 'package:poseidon/poseidon.dart';

class SMTDataSource {
  final StorageSMTDataSource _storageSMTDataSource;

  SMTDataSource(
    this._storageSMTDataSource,
  );

  Future<void> createSMT({
    required int maxLevels,
    required String storeName,
    required String did,
    required String encryptionKey,
  }) async {
    await _storageSMTDataSource
        .getRoot(storeName: storeName, did: did, encryptionKey: encryptionKey)
        .then((root) async => await _storageSMTDataSource.removeSMT(
            storeName: storeName, did: did, encryptionKey: encryptionKey))
        .catchError((error) {});
    await _storageSMTDataSource.setRoot(
        root: HashEntity.zero(),
        storeName: storeName,
        did: did,
        encryptionKey: encryptionKey);
    await _storageSMTDataSource.setMaxLevels(
        maxLevels: maxLevels,
        storeName: storeName,
        did: did,
        encryptionKey: encryptionKey);
  }

  Future<void> removeSMT(
      {required String storeName,
      required String did,
      required String encryptionKey}) async {
    return _storageSMTDataSource.removeSMT(
        storeName: storeName, did: did, encryptionKey: encryptionKey);
  }

  Future<void> removeRoot(
      {required String storeName,
      required String did,
      required String encryptionKey}) async {
    return _storageSMTDataSource.setRoot(
        root: HashEntity.zero(),
        storeName: storeName,
        did: did,
        encryptionKey: encryptionKey);
  }

  Future<HashEntity> getRoot({
    required String storeName,
    required String did,
    required String encryptionKey,
  }) async {
    return _storageSMTDataSource.getRoot(
      storeName: storeName,
      did: did,
      encryptionKey: encryptionKey,
    );
  }

  Future<HashEntity> addLeaf({
    required NodeEntity newNodeLeaf,
    required String storeName,
    required String did,
    required String encryptionKey,
  }) async {
    int maxLevels = await _storageSMTDataSource.getMaxLevels(
        storeName: storeName, did: did, encryptionKey: encryptionKey);
    final root = await _storageSMTDataSource.getRoot(
        storeName: storeName, did: did, encryptionKey: encryptionKey);
    final path = _getPath(maxLevels, newNodeLeaf.children[0]);
    final newRoot = await _addLeaf(
        newNodeLeaf, root, 0, path, storeName, did, encryptionKey);
    await _storageSMTDataSource.setRoot(
        root: newRoot,
        storeName: storeName,
        did: did,
        encryptionKey: encryptionKey);
    return newRoot;
  }

  Future<HashEntity> _addLeaf(
      NodeEntity newLeaf,
      HashEntity key,
      int level,
      List<bool> path,
      String storeName,
      String did,
      String encryptionKey) async {
    int maxLevels = await _storageSMTDataSource.getMaxLevels(
        storeName: storeName, did: did, encryptionKey: encryptionKey);
    if (level > maxLevels - 1) {
      throw ArgumentError("level must be less than maxLevels");
    }

    logger().i("add leaf under key ${key.string()} at level $level");

    final node = await _storageSMTDataSource.getNode(
        key: key, storeName: storeName, did: did, encryptionKey: encryptionKey);
    switch (node.type) {
      case NodeType.empty:
        return _addNode(newLeaf, storeName, did, encryptionKey);
      case NodeType.leaf:
      case NodeType.state: //???
        final nKey = node.children[0];
        // Check if leaf node found contains the leaf node we are
        // trying to add
        final newLeafKey = newLeaf.children[0];
        if (newLeafKey == nKey) {
          throw SMTEntryIndexAlreadyExistsException(
            errorMessage: "Leaf node already exists",
          );
        }
        final pathOldLeaf = _getPath(maxLevels, nKey);
        // We need to push newLeaf down until its path diverges from
        // n's path
        return _pushLeaf(newLeaf, node, level, path, pathOldLeaf, storeName,
            did, encryptionKey);
      case NodeType.middle:
        // We need to go deeper, continue traversing the tree, left or
        // right depending on path
        late final NodeEntity newNodeMiddle;
        if (path[level]) {
          // go right
          final nextKey = await _addLeaf(newLeaf, node.children[1], level + 1,
              path, storeName, did, encryptionKey);
          final newNodeChildren = [node.children[0], nextKey];
          final nodeHashData = poseidon2([
            node.children[0].toBigInt(),
            nextKey.toBigInt(),
          ]);
          final nodeHash = HashEntity.fromBigInt(nodeHashData);
          newNodeMiddle = NodeEntity(
              children: newNodeChildren, hash: nodeHash, type: NodeType.middle);
        } else {
          // go left
          final nextKey = await _addLeaf(newLeaf, node.children[0], level + 1,
              path, storeName, did, encryptionKey);

          final newNodeChildren = [nextKey, node.children[1]];
          final nodeHashData = poseidon2([
            nextKey.toBigInt(),
            node.children[1].toBigInt(),
          ]);
          final nodeHash = HashEntity.fromBigInt(nodeHashData);
          newNodeMiddle = NodeEntity(
              children: newNodeChildren, hash: nodeHash, type: NodeType.middle);
        }
        return _addNode(newNodeMiddle, storeName, did, encryptionKey);
      default:
        throw SMTInvalidNodeFoundException(
          errorMessage: "Invalid node type found",
        );
    }
  }

  Future<HashEntity> _addNode(
    NodeEntity node,
    String storeName,
    String did,
    String encryptionKey,
  ) async {
    // print("add node $n");

    final key = node.hash;
    if (node.type == NodeType.empty) {
      return key;
    }

    //bool nodeFound = true;
    //try {
    bool nodeFound = await _storageSMTDataSource
        .getNode(
            key: key,
            storeName: storeName,
            did: did,
            encryptionKey: encryptionKey)
        .then((node) => node.type != NodeType.empty)
        .catchError((error) => false);
    /*} on SMTNotFoundException {
      nodeFound = false;
    }*/

    if (nodeFound) {
      throw SMTNodeKeyAlreadyExistsException(
        errorMessage: "Node key already exists",
      );
    }

    await _storageSMTDataSource.addNode(
      key: key,
      node: node,
      storeName: storeName,
      did: did,
      encryptionKey: encryptionKey,
    );
    return key;
  }

  // pushLeaf recursively pushes an existing oldLeaf down until its path diverges
  // from newLeaf, at which point both leafs are stored, all while updating the
  // path.
  Future<HashEntity> _pushLeaf(
    NodeEntity newLeaf,
    NodeEntity oldLeaf,
    int level,
    List<bool> pathNewLeaf,
    List<bool> pathOldLeaf,
    String storeName,
    String did,
    String encryptionKey,
  ) async {
    int maxLevels = await _storageSMTDataSource.getMaxLevels(
      storeName: storeName,
      did: did,
      encryptionKey: encryptionKey,
    );
    if (level > maxLevels - 2) {
      throw SMTReachedMaxLevelException(
        errorMessage: "Reached max level",
      );
    }

    if (pathNewLeaf[level] == pathOldLeaf[level]) {
      // We need to go deeper!
      final nextKey = await _pushLeaf(
        newLeaf,
        oldLeaf,
        level + 1,
        pathNewLeaf,
        pathOldLeaf,
        storeName,
        did,
        encryptionKey,
      );
      late final List<HashEntity> newNodeChildren;
      if (pathNewLeaf[level]) {
        // go right
        newNodeChildren = [HashEntity.zero(), nextKey];
      } else {
        // go left
        newNodeChildren = [nextKey, HashEntity.zero()];
      }
      final nodeHashData = poseidon2([
        newNodeChildren[0].toBigInt(),
        newNodeChildren[1].toBigInt(),
      ]);
      final nodeHash = HashEntity.fromBigInt(nodeHashData);
      final NodeEntity newNodeMiddle = NodeEntity(
        children: newNodeChildren,
        hash: nodeHash,
        type: NodeType.middle,
      );
      return _addNode(newNodeMiddle, storeName, did, encryptionKey);
    }

    final oldLeafKey = oldLeaf.hash;
    final newLeafKey = newLeaf.hash;
    late final List<HashEntity> newNodeChildren;
    if (pathNewLeaf[level]) {
      newNodeChildren = [oldLeafKey, newLeafKey];
    } else {
      newNodeChildren = [newLeafKey, oldLeafKey];
    }
    final nodeHashData = poseidon2([
      newNodeChildren[0].toBigInt(),
      newNodeChildren[1].toBigInt(),
    ]);
    final nodeHash = HashEntity.fromBigInt(nodeHashData);
    final NodeEntity newNodeMiddle = NodeEntity(
      children: newNodeChildren,
      hash: nodeHash,
      type: NodeType.middle,
    );
    await _addNode(newLeaf, storeName, did, encryptionKey);
    return _addNode(newNodeMiddle, storeName, did, encryptionKey);
  }

  _getPath(int numLevel, HashEntity h) {
    final path = List<bool>.filled(numLevel, false);
    for (int i = 0; i < numLevel; i++) {
      path[i] = h.testBit(i);
    }
    return path;
  }

  // TODO: MTProofDTO from proof, not identity
  Future<MTProofEntity> generateProof({
    required HashEntity key,
    required String storeName,
    required String did,
    required String encryptionKey,
  }) async {
    int maxLevels = await _storageSMTDataSource.getMaxLevels(
        storeName: storeName, did: did, encryptionKey: encryptionKey);
    final path = _getPath(maxLevels, key);
    var siblings = <HashEntity>[];
    final root = await _storageSMTDataSource.getRoot(
        storeName: storeName, did: did, encryptionKey: encryptionKey);
    var nextKey = root;
    for (int depth = 0; depth < maxLevels; depth++) {
      final node = await _storageSMTDataSource.getNode(
          key: nextKey,
          storeName: storeName,
          did: did,
          encryptionKey: encryptionKey);

      switch (node.type) {
        case NodeType.empty:
          return MTProofEntity(existence: false, siblings: siblings);
        case NodeType.leaf:
          if (node.hash == key) {
            return MTProofEntity(existence: true, siblings: siblings);
          }
          // We found a leaf whose entry didn't match key
          return MTProofEntity(
              existence: false,
              siblings: siblings,
              nodeAux: NodeAuxEntity(
                key: node.children[0].toString(),
                value: node.children[1].toString(),
              ));
        case NodeType.middle:
          if (path[depth]) {
            nextKey = node.children[1];
            siblings.add(node.children[0]);
          } else {
            nextKey = node.children[0];
            siblings.add(node.children[1]);
          }
          break;
        default:
          throw SMTInvalidNodeFoundException(
            errorMessage: "Invalid node type found",
          );
      }
    }
    throw SMTKeyNotFoundException(
      errorMessage: "Key not found",
    );
  }

  Future<HashEntity> getProofTreeRoot(
      {required MTProofEntity proof, required NodeEntity node}) async {
    assert(node.type == NodeType.leaf);
    HashEntity midKey;
    if (proof.existence) {
      midKey = node.hash;
    } else {
      if (proof.nodeAux == null) {
        midKey = HashEntity.zero();
      } else {
        if (node.children[0] ==
            HashEntity.fromBigInt(BigInt.parse(proof.nodeAux!.key))) {
          throw Exception(
              "Non-existence proof being checked against hIndex equal to nodeAux");
        }
        midKey = HashEntity.fromBigInt(BigInt.parse(proof.nodeAux!.key));
      }
    }

    final path = _getPath(proof.siblings.length, node.children[0]);

    for (int level = proof.siblings.length - 1; level >= 0; level--) {
      late final List<HashEntity> newNodeChildren;
      if (path[level]) {
        newNodeChildren = [proof.siblings[level], midKey];
      } else {
        newNodeChildren = [midKey, proof.siblings[level]];
      }
      final nodeHashData = poseidon2([
        newNodeChildren[0].toBigInt(),
        newNodeChildren[1].toBigInt(),
      ]);
      midKey = HashEntity.fromBigInt(nodeHashData);
    }

    return Future.value(midKey);
  }

  Future<bool> verifyProof({
    required MTProofEntity proof,
    required NodeEntity node,
    required HashEntity treeRoot,
  }) async {
    return getProofTreeRoot(proof: proof, node: node)
        .then((proofTreeRoot) => proofTreeRoot == treeRoot);
  }
}
