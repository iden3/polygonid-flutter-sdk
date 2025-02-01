import 'dart:typed_data';

import 'package:polygonid_flutter_sdk/common/kms/keys/public_key.dart';

abstract class PrivateKey {
  final String hex;

  const PrivateKey({
    required this.hex,
  });

  /// Make a public key from the private key, returning nil if this is unsuccessful
  PublicKey publicKey();

  /// Sign a message using this private key
  Uint8List sign(Uint8List message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrivateKey &&
          runtimeType == other.runtimeType &&
          hex == other.hex;

  @override
  int get hashCode => hex.hashCode;

  @override
  String toString() {
    final display = hex.substring(0, 4) + '...' + hex.substring(hex.length - 4);
    return 'PrivateKey { hex: $display }';
  }
}
