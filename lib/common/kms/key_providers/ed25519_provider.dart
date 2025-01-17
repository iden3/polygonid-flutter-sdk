import 'dart:typed_data';

import 'package:polygonid_flutter_sdk/common/kms/keys/private_key.dart';
import 'package:polygonid_flutter_sdk/common/kms/keys/public_key.dart';
import 'package:polygonid_flutter_sdk/common/kms/kms.dart';
import 'package:polygonid_flutter_sdk/common/kms/store/abstract_key_store.dart';
import 'package:polygonid_flutter_sdk/common/kms/keys/types.dart';
import 'package:web3dart/crypto.dart';
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed25519;

/// Provider for Ed25519 keys
/// @public
/// @class Ed25519Provider
/// @implements IKeyProvider interface
class Ed25519Provider implements IKeyProvider {
  final KeyType keyType;
  final AbstractPrivateKeyStore _keyStore;

  /// Creates an instance of Ed25519Provider.
  /// @param {KmsKeyType} keyType - kms key type
  /// @param {AbstractPrivateKeyStore} keyStore - key store for kms
  Ed25519Provider(this.keyType, this._keyStore);

  /// generates a ed25519 key from a seed phrase
  /// @param {Uint8List} seed - byte array seed
  /// @returns {Future<KmsKeyId>} kms key identifier
  @override
  Future<KeyId> newPrivateKeyFromSeed(Uint8List seed) async {
    if (seed.length != 32) {
      throw Exception('Seed should be 32 bytes');
    }
    final edPrivateKey = ed25519.newKeyFromSeed(seed);
    final privateKey = Ed25519PrivateKey(edPrivateKey);

    final publicKey = privateKey.publicKey();

    await _keyStore.importKey(
      alias: publicKey.keyId.id,
      key: bytesToHex(edPrivateKey.bytes),
    );

    return publicKey.keyId;
  }

  /// Gets public key by kmsKeyId
  /// @param {KmsKeyId} keyId - key identifier
  /// @returns {Future<String>} Public key as a hex String
  @override
  Future<PublicKey> publicKey(KeyId keyId) async {
    final privateKey = await _privateKey(keyId);

    return privateKey.publicKey();
  }

  /// signs prepared payload of size,
  /// with a key id
  /// @param {KmsKeyId} keyId  - key identifier
  /// @param {Uint8List} digest - data to sign (32 bytes)
  /// @returns {Future<Uint8List>} signature
  @override
  Future<Uint8List> sign(
    KeyId keyId,
    Uint8List digest, [
    Map<String, dynamic>? opts,
  ]) async {
    final privateKey = await _privateKey(keyId);
    return privateKey.sign(digest);
  }

  /// Verifies a signature for the given message and key identifier.
  /// @param digest - The message to verify the signature against.
  /// @param signatureHex - The signature to verify, as a hexadecimal String.
  /// @param keyId - The key identifier to use for verification.
  /// @returns A Future that resolves to a boolean indicating whether the signature is valid.
  Future<bool> verify(
      Uint8List digest, String signatureHex, KeyId keyId) async {
    final publicKey = await this.publicKey(keyId);
    final edPublicKey = ed25519.PublicKey(hexToBytes(publicKey.hex));

    return ed25519.verify(
      edPublicKey,
      digest,
      hexToBytes(signatureHex),
    );
  }

  @override
  Future<PrivateKey> privateKey(KeyId keyId) async {
    return _privateKey(keyId);
  }

  /// Retrieves the private key for a given keyId from the key store.
  /// @param {KmsKeyId} keyId - The identifier of the key to retrieve.
  /// @returns {Future<String>} The private key associated with the keyId.
  Future<Ed25519PrivateKey> _privateKey(KeyId keyId) async {
    final privateKeyHex = await _keyStore.get(alias: keyId.id);

    return Ed25519PrivateKey(ed25519.PrivateKey(hexToBytes(privateKeyHex)));
  }
}

class Ed25519PublicKey extends PublicKey {
  final ed25519.PublicKey publicKey;

  Ed25519PublicKey(this.publicKey) : super(hex: bytesToHex(publicKey.bytes));

  @override
  KeyType get keyType => KeyType.Ed25519;
}

class Ed25519PrivateKey extends PrivateKey {
  final ed25519.PrivateKey privateKey;

  Ed25519PrivateKey(this.privateKey) : super(hex: bytesToHex(privateKey.bytes));

  @override
  PublicKey publicKey() {
    return Ed25519PublicKey(ed25519.public(privateKey));
  }

  @override
  Uint8List sign(Uint8List message) {
    return ed25519.sign(privateKey, message);
  }
}
