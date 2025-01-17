import "dart:typed_data";

import "package:encrypt/encrypt.dart";
import "package:flutter/foundation.dart";
import "package:polygonid_flutter_sdk/common/kms/index.dart";
import "package:polygonid_flutter_sdk/common/kms/keys/private_key.dart";
import "package:polygonid_flutter_sdk/common/kms/keys/public_key.dart";
import "package:polygonid_flutter_sdk/common/kms/keys/types.dart";
import "package:polygonid_flutter_sdk/common/kms/store/abstract_key_store.dart";
import "package:polygonid_flutter_sdk/common/utils/big_int_extension.dart";
import "package:polygonid_flutter_sdk/common/utils/uint8_list_utils.dart";
import "package:polygonid_flutter_sdk/identity/libs/bjj/eddsa_babyjub.dart";
import "package:web3dart/crypto.dart";

/// Provider for Baby Jub Jub keys
/// @public
/// @class BjjProvider
/// @implements implements IKeyProvider interface
class BjjProvider implements IKeyProvider {
  /// key type that is handled by BJJ Provider
  /// @type {KmsKeyType}
  KeyType get keyType => KeyType.BabyJubJub;

  AbstractPrivateKeyStore _keyStore;

  /// Creates an instance of BjjProvider.
  /// @param {KmsKeyType} keyType - kms key type
  /// @param {AbstractPrivateKeyStore} keyStore - key store for kms
  BjjProvider(KeyType keyType, this._keyStore) {
    if (keyType != KeyType.BabyJubJub) {
      throw Exception('Key type must be BabyJubJub');
    }
  }

  /// generates a baby jub jub key from a seed phrase
  /// @param {Uint8List} seed - byte array seed
  /// @returns kms key identifier
  @override
  Future<KeyId> newPrivateKeyFromSeed(Uint8List seed) async {
    final privateKey = BjjPrivateKey(seed);

    final publicKey = privateKey.publicKey();

    final kmsId = KeyId(
      type: keyType,
      id: keyPath(keyType, publicKey.hex),
    );
    await _keyStore.importKey(alias: publicKey.keyId.id, key: privateKey.hex);

    return kmsId;
  }

  /// Gets public key by kmsKeyId
  ///
  /// @param {KmsKeyId} keyId - key identifier
  @override
  Future<PublicKey> publicKey(KeyId keyId) async {
    final privateKey = await _privateKey(keyId);
    return privateKey.publicKey();
  }

  /// signs prepared payload of size,
  /// with a key id
  ///
  /// @param {KmsKeyId} keyId  - key identifier
  /// @param {Uint8List} data - data to sign (32 bytes)
  /// @returns Uint8List signature
  @override
  Future<Uint8List> sign(
    KeyId keyId,
    Uint8List data, [
    Map<String, dynamic>? opts,
  ]) async {
    if (data.length != 32) {
      throw Exception('data to sign is too large');
    }

    final i = bytesToUnsignedInt(data);
    if (!i.checkBigIntInField()) {
      throw Exception('data to sign is too large');
    }
    final privateKey = await _privateKey(keyId);

    final signature = privateKey.sign(data);

    return signature;
  }

  @override
  Future<bool> verify(
    Uint8List message,
    String signatureHex,
    KeyId keyId,
  ) async {
    final publicKey = (await this.publicKey(keyId)) as BjjPublicKey;

    return publicKey.verify(
      Uint8ArrayUtils.uint8ListToString(message),
      BjjSignature.newFromCompressed(hexToBytes(signatureHex)),
    );
  }

  @override
  Future<PrivateKey> privateKey(KeyId keyId) async {
    return _privateKey(keyId);
  }

  Future<BjjPrivateKey> _privateKey(KeyId keyId) async {
    final privateKeyHex = await _keyStore.get(alias: keyId.id);

    return BjjPrivateKey(decodeHexString(privateKeyHex));
  }
}
