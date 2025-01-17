import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:web3dart/crypto.dart';

import '../../../common/utils/uint8_list_utils.dart';

//part 'hash_dto.g.dart';

final _q = BigInt.parse(
    "21888242871839275222246405745257275088548364400416034343698204186575808495617");

/// Represents an identity state hash DTO.
//@JsonSerializable(explicitToJson: true)
class HashEntity extends Equatable {
  final Uint8List data; // hex string 64 chars - big int string 77 chars

  const HashEntity({required this.data});

  HashEntity.zero() : data = Uint8List(32);

  HashEntity.fromUint8List(this.data) {
    assert(data.length == 32);
  }

  HashEntity.fromBigInt(BigInt i) : data = Uint8List(32) {
    if (i < BigInt.from(0)) {
      throw ArgumentError("BigInt must be positive");
    }

    if (i >= _q) {
      throw ArgumentError("BigInt must be less than $_q");
    }

    int bytes = (i.bitLength + 7) >> 3;
    final b = BigInt.from(256);
    for (int j = 0; j < bytes; j++) {
      data[j] = i.remainder(b).toInt();
      i = i >> 8;
    }
  }

  HashEntity.fromHex(String h) : data = Uint8List(32) {
    if (h.length != 64) {
      throw ArgumentError("Hex string must be 64 characters long");
    }
    hexToBytes(h).asMap().forEach((i, b) {
      data[i] = b;
    });
  }

  factory HashEntity.fromJson(dynamic json) {
    if (json is String) {
      // if json is a String we can parse it directly
      return HashEntity.fromBigInt(BigInt.parse(json));
    } else if (json is Map<String, dynamic> && json.containsKey('data')) {
      return HashEntity.fromBigInt(BigInt.parse(json['data']));
    } else {
      throw Exception('invalid format');
    }
  }

  String toJson() => toBigInt().toString();

  BigInt toBigInt() {
    final b = BigInt.from(256);
    BigInt i = BigInt.from(0);
    for (int j = data.length - 1; j >= 0; j--) {
      i = i * b + BigInt.from(data[j]);
    }
    return i;
  }

  bool testBit(int n) {
    if (n < 0 || n >= data.length * 8) {
      throw ArgumentError("n must be in range [0, ${data.length * 8}]");
    }
    return data[n ~/ 8] & (1 << (n % 8)) != 0;
  }

  // TestBit tests whether the bit n in bitmap is 1.
  // ignore: unused_element
  bool _testBit(Uint8List byte, int n) {
    return data[n ~/ 8] & (1 << (n % 8)) != 0;
  }

  String string() => Uint8ArrayUtils.bytesToBigInt(data).toString();

  @override
  bool operator ==(Object other) {
    if (other is HashEntity) {
      if (data.length != other.data.length) {
        return false;
      }
      for (int i = 0; i < data.length; i++) {
        if (data[i] != other.data[i]) {
          return false;
        }
      }
      return true;
    }
    return false;
  }

  @override
  String toString() {
    return Uint8ArrayUtils.bytesToBigInt(data).toString();
  }

  @override
  int get hashCode => Object.hashAll(data);

  @override
  List<Object?> get props => [data];
}
