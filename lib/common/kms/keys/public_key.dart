import 'package:polygonid_flutter_sdk/common/kms/keys/types.dart';
import 'package:polygonid_flutter_sdk/common/kms/provider_helpers.dart';

abstract class PublicKey {
  final String hex;

  const PublicKey({
    required this.hex,
  });

  /// The public key compressed
  BigInt get compressed => BigInt.parse(hex, radix: 16);

  KeyType get keyType;

  /// The key ID derived from this public key
  KeyId get keyId {
    return KeyId(type: keyType, id: keyPath(keyType, hex));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PublicKey &&
          runtimeType == other.runtimeType &&
          keyId == other.keyId;

  @override
  int get hashCode => keyId.hashCode;
}
