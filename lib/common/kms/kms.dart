import 'dart:math';
import 'dart:typed_data';

import 'package:polygonid_flutter_sdk/common/kms/keys/private_key.dart';
import 'package:polygonid_flutter_sdk/common/kms/keys/public_key.dart';
import 'package:polygonid_flutter_sdk/common/kms/keys/types.dart';
import 'package:meta/meta.dart';

/// KeyProvider is responsible for signing and creation of the keys
///
/// @public
/// @interface   IKeyProvider
abstract class IKeyProvider {
  /// property to store key type
  ///
  /// @type {KmsKeyType}
  KeyType get keyType;

  /// gets public key by key id
  ///
  /// @param {KmsKeyId} keyID - kms key identifier
  /// @returns 'Promise<PublicKey>'
  Future<PublicKey> publicKey(KeyId keyID);

  /// sign data with kms key
  ///
  /// @param {KmsKeyId} keyId - key identifier
  /// @param {Uint8Array} data  - bytes payload
  /// @param {{ [key: string]: unknown }} opts  - additional options for signing
  /// @returns 'Promise<Uint8Array>'
  Future<Uint8List> sign(
    KeyId keyId,
    Uint8List data, [
    Map<String, dynamic>? opts,
  ]);

  /// creates new key pair from given seed
  ///
  /// @param {Uint8Array} seed - seed
  /// @returns 'Promise<KmsKeyId>'
  Future<KeyId> newPrivateKeyFromSeed(Uint8List seed);

  /// Verifies a message signature using the provided key ID.
  ///
  /// @param message - The message bytes to verify.
  /// @param signatureHex - The signature in hexadecimal format.
  /// @param keyId - The KMS key ID used to verify the signature.
  /// @returns A promise that resolves to a boolean indicating whether the signature is valid.
  Future<bool> verify(Uint8List message, String signatureHex, KeyId keyId);

  // TODO: Maybe use other annotation
  // ignore: invalid_internal_annotation
  @internal
  Future<PrivateKey> privateKey(KeyId keyId);
}

/// Key management system class contains different key providers.
/// allows to register custom provider, create key, get public key and sign
///
/// @public
/// @class KMS - class
class KMS {
  final _registry = <KeyType, IKeyProvider>{};

  /// register key provider in the KMS
  ///
  /// @param {KmsKeyType} keyType - kms key type
  /// @param {IKeyProvider} keyProvider - key provider implementation
  void registerKeyProvider(KeyType keyType, IKeyProvider keyProvider) {
    if (_registry.containsKey(keyType)) {
      throw Exception('present keyType');
    }
    _registry[keyType] = keyProvider;
  }

  /// generates a new key and returns it kms key id
  ///
  /// @param {KmsKeyType} keyType
  /// @param {Uint8Array} bytes
  /// @returns kms key id
  Future<KeyId> createKey(KeyType keyType) async {
    final keyProvider = _registry[keyType];
    if (keyProvider == null) {
      throw Exception('keyProvider not found for: $keyType');
    }

    final random = Random.secure();
    final seedBytes = _generateSeedBytes(random);

    return keyProvider.newPrivateKeyFromSeed(seedBytes);
  }

  /// generates a new key and returns it kms key id
  ///
  /// @param {KmsKeyType} keyType
  /// @param {Uint8Array} bytes
  /// @returns kms key id
  Future<KeyId> createKeyFromSeed(KeyType keyType, Uint8List bytes) async {
    final keyProvider = _registry[keyType];
    if (keyProvider == null) {
      throw Exception('keyProvider not found for: $keyType');
    }
    return keyProvider.newPrivateKeyFromSeed(bytes);
  }

  /// gets public key for key id
  ///
  /// @param {KmsKeyId} keyId -- key id
  /// @returns public key
  Future<PublicKey> publicKey(KeyId keyId) async {
    final keyProvider = _registry[keyId.type];
    if (keyProvider == null) {
      throw Exception('keyProvider not found for: ${keyId.type}');
    }

    return keyProvider.publicKey(keyId);
  }

  /// gets private key for key id
  ///
  /// @param {KmsKeyId} keyId -- key id
  /// @returns private key
  // TODO: Maybe use other annotation
  // ignore: invalid_internal_annotation
  @internal
  Future<PrivateKey> privateKey(KeyId keyId) async {
    final keyProvider = _registry[keyId.type];
    if (keyProvider == null) {
      throw Exception('keyProvider not found for: ${keyId.type}');
    }

    return keyProvider.privateKey(keyId);
  }

  /// sign Uint8Array with giv KmsKeyIden
  ///
  /// @param {KmsKeyId} keyId - key id
  /// @param {Uint8Array} data - prepared data bytes
  /// @returns 'Promise<Uint8Array>' - return signature
  Future<Uint8List> sign(
    KeyId keyId,
    Uint8List data, [
    Map<String, dynamic> opts = const {},
  ]) async {
    final keyProvider = _registry[keyId.type];
    if (keyProvider == null) {
      throw Exception('keyProvider not found for: ${keyId.type}');
    }

    return keyProvider.sign(keyId, data, opts);
  }

  /// Verifies a signature against the provided data and key ID.
  ///
  /// @param data - The data to verify the signature against.
  /// @param signatureHex - The signature to verify, in hexadecimal format.
  /// @param keyId - The key ID to use for verification.
  /// @returns A promise that resolves to a boolean indicating whether the signature is valid.
  Future<bool> verify(Uint8List data, String signatureHex, KeyId keyId) async {
    final keyProvider = _registry[keyId.type];
    if (keyProvider == null) {
      throw Exception('keyProvider not found for: ${keyId.type}');
    }
    return keyProvider.verify(data, signatureHex, keyId);
  }
}

Uint8List _generateSeedBytes(Random random) {
  final seedBytes = Uint8List(32);
  for (var i = 0; i < seedBytes.length; i++) {
    seedBytes[i] = random.nextInt(256);
  }
  return seedBytes;
}
