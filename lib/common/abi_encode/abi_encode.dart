import 'package:flutter/foundation.dart';

import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

/// An object that can be encoded to ABI.
abstract interface class AbiEncodable {
  /// Serialize the object to a list of arguments that can be passed to the ABI encoder.
  /// Example class represented by the object:
  /// {
  ///   a: "c",
  ///   b: "d",
  /// }
  /// should return
  /// ["c", 896314698613489613]
  List toAbiEncodeArgs();

  /// The ABI type of the object.
  /// Should be retrieved from actual contract ABI.
  /// Example:
  /// {
  ///   a: "c",
  ///   b: 896314698613489613,
  /// }
  /// should return
  /// [StringType(), UintType()]
  AbiType get abiType;
}

extension EncodableExtension on AbiEncodable {
  /// Encode the object to a byte array.
  Uint8List encode() {
    final buffer = LengthTrackingByteSink();

    abiType.encode(
      toAbiEncodeArgs(),
      buffer,
    );

    return buffer.asBytes();
  }

  /// Encode the object to a hex string.
  String encodeToHex() {
    return bytesToHex(encode());
  }
}

/// An extension on [Iterable] of [AbiEncodable] objects.
extension EncodableIterable<T extends AbiEncodable> on Iterable<T> {
  /// Encode the list of objects to a byte array.
  AbiType getAbiType(AbiType elementType) {
    return TupleType([
      DynamicLengthArray(
        type: elementType,
      ),
    ]);
  }

  Uint8List encode() {
    if (isEmpty) {
      // TODO Check that this is correct
      return Uint8List(0);
    }

    final type = getAbiType(first.abiType);

    final buffer = LengthTrackingByteSink();

    type.encode(
      [
        map((m) => m.toAbiEncodeArgs()).toList(),
      ],
      buffer,
    );

    return buffer.asBytes();
  }

  String encodeToHex() => bytesToHex(encode());
}

extension HexEncodable on AbiType {
  String encodeToHex(List<dynamic> params) {
    final buffer = LengthTrackingByteSink();
    encode(params, buffer);

    final result = bytesToHex(buffer.asBytes());

    return result;
  }
}
