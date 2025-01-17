import 'package:polygonid_flutter_sdk/identity/domain/entities/hash_entity.dart';

class TreeStateEntity {
  final String hash;
  final HashEntity claimsTree;
  final HashEntity revocationTree;
  final HashEntity rootsTree;

  TreeStateEntity(
      this.hash, this.claimsTree, this.revocationTree, this.rootsTree);

  @override
  String toString() =>
      "[TreeStateEntity] {claimsTree: $claimsTree, revocationTree: $revocationTree, rootsTree: $rootsTree}";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreeStateEntity &&
          runtimeType == other.runtimeType &&
          claimsTree == other.claimsTree &&
          revocationTree == other.revocationTree &&
          rootsTree == other.rootsTree;

  @override
  int get hashCode => runtimeType.hashCode;

  Map<String, dynamic> toJson() {
    return {
      "state": hash,
      "claimsRoot": claimsTree.string(),
      "revocationRoot": revocationTree.string(),
      "rootOfRoots": rootsTree.string(),
    };
  }
}
