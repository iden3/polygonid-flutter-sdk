import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:sembast/sembast.dart';

enum EncryptType { salsa20, aes, fernet }

class _EncryptEncoder extends Converter<Map<String, dynamic>, String> {
  final String key;
  final EncryptType signature;

  _EncryptEncoder(this.key, this.signature);

  @override
  String convert(Map<String, dynamic> input) {
    String encoded;
    switch (signature) {
      case EncryptType.salsa20:
        encoded = Encrypter(Salsa20(Key.fromUtf8(key)))
            .encrypt(json.encode(input), iv: IV.allZerosOfLength(8))
            .base64;
        break;
      case EncryptType.aes:
        encoded = Encrypter(AES(Key.fromUtf8(key)))
            .encrypt(json.encode(input), iv: IV.allZerosOfLength(16))
            .base64;
        break;
      case EncryptType.fernet:
        encoded = Encrypter(
                Fernet(Key.fromUtf8(base64Url.encode(Key.fromUtf8(key).bytes))))
            .encrypt(json.encode(input), iv: IV.allZerosOfLength(16))
            .base64;
        break;
      default:
        throw FormatException('invalid $signature');
    }
    return encoded;
  }
}

class _EncryptDecoder extends Converter<String, Map<String, dynamic>> {
  final String key;
  final EncryptType signature;

  _EncryptDecoder(this.key, this.signature);

  @override
  Map<String, dynamic> convert(String input) {
    var decoded;
    switch (signature) {
      case EncryptType.salsa20:
        decoded = json.decode(Encrypter(Salsa20(Key.fromUtf8(key)))
            .decrypt64(input, iv: IV.allZerosOfLength(8)));
        break;
      case EncryptType.aes:
        decoded = json.decode(Encrypter(AES(Key.fromUtf8(key)))
            .decrypt64(input, iv: IV.allZerosOfLength(16)));
        break;
      case EncryptType.fernet:
        decoded = json.decode(Encrypter(
                Fernet(Key.fromUtf8(base64Url.encode(Key.fromUtf8(key).bytes))))
            .decrypt64(input, iv: IV.allZerosOfLength(16)));
        break;
      default:
        break;
    }
    if (decoded is Map) {
      return decoded.cast<String, dynamic>();
    }
    throw FormatException('invalid input $input');
  }
}

class _EncryptCodec extends Codec<Map<String, dynamic>, String> {
  final EncryptType signature;
  late _EncryptEncoder _encoder;
  late _EncryptDecoder _decoder;

  _EncryptCodec(String password, this.signature) {
    _encoder = _EncryptEncoder(password, signature);
    _decoder = _EncryptDecoder(password, signature);
  }

  @override
  Converter<String, Map<String, dynamic>> get decoder => _decoder;

  @override
  Converter<Map<String, dynamic>, String> get encoder => _encoder;
}

// Salsa20 (16 length key required) or AES (32 length key required)
SembastCodec getEncryptSembastCodec({
  required String encryptionKey,
  EncryptType signature = EncryptType.salsa20,
}) {
  return SembastCodec(
    signature: signature.toString(),
    codec: _EncryptCodec(encryptionKey, signature),
  );
}
