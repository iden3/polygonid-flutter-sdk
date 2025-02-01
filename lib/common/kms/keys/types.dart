/// Key type that can be used in the key management system
///
/// @enum {number}
enum KeyType {
  BabyJubJub('BJJ'),
  Secp256k1('Secp256k1'),
  Ed25519('Ed25519');

  final String name;

  const KeyType(this.name);
}

/// ID of the key that describe contain key type
///
/// @public
/// @interface   KeyId
class KeyId {
  final KeyType type;
  final String id;

  KeyId({required this.type, required this.id});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeyId &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id;

  @override
  int get hashCode => type.hashCode ^ id.hashCode;
}
