import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:polygonid_flutter_sdk/common/kms/index.dart';
import 'package:polygonid_flutter_sdk/common/kms/keys/types.dart';
import 'package:polygonid_flutter_sdk/common/kms/kms.dart';
import 'package:polygonid_flutter_sdk/common/kms/store/memory_key_store.dart';
import 'package:polygonid_flutter_sdk/common/utils/big_int_extension.dart';
import 'package:web3dart/crypto.dart';

Future<void> testFlow(IKeyProvider provider) async {
  final seed1 = getRandomBytes(32);
  final seed2 = getRandomBytes(32);
  expect(seed1, isNot(seed2));
  // expect(seed1).to.not.deep.equal(seed2);

  var dataToSign1 = getRandomBytes(32);
  var dataToSign2 = getRandomBytes(32);
  if (provider is BjjProvider) {
    // because challenge should be in the finite field of Constant.Q
    dataToSign1 = (BigIntQ.Q - BigInt.one).toBytes();
    dataToSign2 = (BigIntQ.Q - BigInt.parse('100')).toBytes();
  }

  final keyId1 = await provider.newPrivateKeyFromSeed(seed1);
  final keyId2 = await provider.newPrivateKeyFromSeed(seed2);
  final keyId3 = await provider.newPrivateKeyFromSeed(seed1);

  final signature1 = await provider.sign(keyId1, dataToSign1);
  final signature2 = await provider.sign(keyId2, dataToSign2);
  final signature3 = await provider.sign(keyId3, dataToSign1);

  final isPublicKey1Valid =
      await provider.verify(dataToSign1, bytesToHex(signature1), keyId1);
  final isPublicKey2Valid =
      await provider.verify(dataToSign2, bytesToHex(signature2), keyId2);
  final isPublicKey3Valid =
      await provider.verify(dataToSign1, bytesToHex(signature3), keyId3);

  // expect(signature1).to.not.deep.equal(signature2);
  // expect(signature1).to.deep.equal(signature3);

  expect(isPublicKey1Valid, true);
  expect(isPublicKey2Valid, true);
  expect(isPublicKey3Valid, true);
}

void main() {
  test(
    "should signatures be valid and equal for the same data and private key",
    () async {
      final keyStore = InMemoryPrivateKeyStore();
      final ed25519Provider = Ed25519Provider(KeyType.Ed25519, keyStore);
      final secp256k1Provider = Sec256k1Provider(KeyType.Secp256k1, keyStore);

      // BJJ uses platform based implementation
      // ignore: unused_local_variable
      final bjjProvider = BjjProvider(KeyType.BabyJubJub, keyStore);
      await Future.wait([
        // testFlow(bjjProvider),
        testFlow(ed25519Provider),
        testFlow(secp256k1Provider)
      ]);
    },
  );
}

Uint8List getRandomBytes(int length) {
  final random = Random();

  final result = Uint8List(length);
  for (var i = 0; i < length; i++) {
    result[i] = random.nextInt(256);
  }
  return result;
}
