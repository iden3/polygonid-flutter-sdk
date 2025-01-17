import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:hex/hex.dart';

import 'uint8_list_utils.dart';

class HexUtils {
  static Uint8List hexToBytes(String hexStr) {
    final bytes = HEX.decode(strip0x(hexStr));
    if (bytes is Uint8List) return bytes;

    return Uint8List.fromList(bytes);
  }

  static BigInt hexToInt(String hex) {
    return BigInt.parse(strip0x(hex), radix: 16);
  }

  static String bytesToHex(
    List<int> bytes, {
    bool include0x = false,
    int? forcePadLength,
    bool padToEvenLength = false,
  }) {
    var encoded = HEX.encode(bytes);

    if (forcePadLength != null) {
      assert(forcePadLength >= encoded.length);

      final padding = forcePadLength - encoded.length;
      encoded = ('0' * padding) + encoded;
    }

    if (padToEvenLength && encoded.length % 2 != 0) {
      encoded = '0$encoded';
    }

    return (include0x ? '0x' : '') + encoded;
  }

  static String strip0x(String hex) {
    if (hex.startsWith('0x')) return hex.substring(2);
    return hex;
  }

  /// Get API bjj compressed data format
  ///
  /// @param [String] bjjCompressedHex - bjj compressed address encoded as hex string
  /// @returns [String] API adapted bjj compressed address
  static String hexToBase64BJJ(String bjjCompressedHex) {
    BigInt bjjScalar = hexToInt(bjjCompressedHex);
    Uint8List littleEndianBytes = Uint8ArrayUtils.bigIntToBytes(bjjScalar);
    String bjjSwap = bytesToHex(littleEndianBytes,
        forcePadLength: 64, padToEvenLength: false);
    Uint8List bjjSwapBuffer = hexToBytes(bjjSwap);

    var sum = 0;
    for (var i = 0; i < bjjSwapBuffer.length; i++) {
      sum += bjjSwapBuffer[i];
      sum = sum % (pow(2, 8) as int);
    }

    final BytesBuilder finalBuffBjj = BytesBuilder();
    finalBuffBjj.add(bjjSwapBuffer.toList());
    finalBuffBjj.addByte(sum);

    return 'hez:${base64Url.encode(finalBuffBjj.toBytes())}';
  }
}
