import 'dart:typed_data';

import 'package:hex/hex.dart';
import 'package:poseidon/poseidon.dart';
import 'package:polygonid_flutter_sdk/common/kms/keys/types.dart';
import 'package:web3dart/crypto.dart';

import '../../../common/utils/hex_utils.dart';
import '../../../common/utils/uint8_list_utils.dart';
import 'bjj.dart';

typedef Point = ({BigInt x, BigInt y});

/// Class representing EdDSA Baby Jub signature
class BjjSignature {
  late Point r8;
  late BigInt s;

  /// Create a Signature with the R8 point and S scalar
  /// @param {List[BigInt]} r8 - R8 point
  /// @param {BigInt} s - BigInt
  BjjSignature(this.r8, this.s);

  /// Create a Signature from a compressed Signature Buffer
  /// @param {Uint8List} buf - Buffer containing a signature
  /// @returns {Signature} Object signature
  static BjjSignature newFromCompressed(Uint8List buf) {
    if (buf.length != 64) {
      throw ArgumentError('buf must be 64 bytes');
    }
    BabyjubjubLib bjjLib = BabyjubjubLib();

    final pointsSublist = buf.sublist(0, 32);
    // uncompressPoint is used to unpack R8 X and Y
    final unpackedPoint =
        bjjLib.uncompressPoint(HEX.encode(pointsSublist.toList()));

    final x = BigInt.parse(unpackedPoint[0]);
    final y = BigInt.parse(unpackedPoint[1]);

    // S is decoded manually
    BigInt s = Uint8ArrayUtils.beBuff2int(
        Uint8List.fromList(buf.sublist(32, 64).reversed.toList()));
    return BjjSignature((x: x, y: y), s);
  }

  /// Compress the Signature
  /// @returns {Uint8List} - signature compressed into a buffer
  Uint8List compress() {
    final r8 = HexUtils.hexToBytes(
      BabyjubjubLib().compressPoint(this.r8.x.toString(), this.r8.y.toString()),
    );
    final s = Uint8ArrayUtils.beInt2Buff(this.s, 32);
    return Uint8List.fromList([...r8, ...s]);
  }
}

/// Class representing a EdDSA Baby Jub public key
class BjjPublicKey extends PublicKey {
  final String hex;
  final Point p;

  /// Create a PublicKey from a curve point p
  /// @param {String} hex - hex representation
  /// @param {List[BigInt]} p - curve point
  BjjPublicKey._(this.hex, this.p);

  factory BjjPublicKey.hex(String hex) {
    BabyjubjubLib bjjLib = BabyjubjubLib();
    final p = bjjLib.uncompressPoint(hex);
    BigInt x = BigInt.parse(p[0]);
    BigInt y = BigInt.parse(p[1]);

    return PublicKey._(hex, (x: x, y: y));
  }

  /// Compress the PublicKey
  /// @returns {Uint8List} - point compressed into a buffer
  Uint8List compress() {
    BabyjubjubLib bjjLib = BabyjubjubLib();
    return HexUtils.hexToBytes(
      bjjLib.compressPoint(p.x.toString(), p.y.toString()),
    );
  }

  bool verify(String messageHash, Signature signature) {
    BabyjubjubLib bjjLib = BabyjubjubLib();
    return bjjLib.verifyPoseidon(
      hex,
      Uint8ArrayUtils.uint8ListToString(signature.compress()),
      messageHash,
    );
  }
}

/// Class representing EdDSA Baby Jub private key
class BjjPrivateKey extends PrivateKey {
  late Uint8List sk;

  /// Create a PrivateKey from a 32 byte Buffer
  /// @param {Uint8List} buf - private key
  BjjPrivateKey(Uint8List bytes) : super(hex: bytesToHex(bytes)) {
    if (bytes.length != 32) {
      throw ArgumentError('buf must be 32 bytes');
    }
    sk = bytes;
  }

  /// Retrieve PublicKey of the PrivateKey
  /// @returns {PublicKey} PublicKey derived from PrivateKey
  BjjPublicKey publicKey() {
    BabyjubjubLib bjjLib = BabyjubjubLib();
    String publicKeyHex = bjjLib.prv2pub(HexUtils.bytesToHex(sk));
    return BjjPublicKey.hex(publicKeyHex);
  }

  String sign(BigInt messageHash) {
    BabyjubjubLib bjjLib = BabyjubjubLib();
    String signature = bjjLib.signPoseidon(
      HexUtils.bytesToHex(sk),
      messageHash.toString(),
    );
    return signature;
  }

    return Uint8ArrayUtils.uint8ListfromString(signature);
  }
}

String hashPoseidon(
  String claimsTreeRoot,
  String revocationTree,
  String rootsTreeRoot,
) {
  return poseidon3([
    BigInt.parse(claimsTreeRoot),
    BigInt.parse(revocationTree),
    BigInt.parse(rootsTreeRoot),
  ]).toString();
}
