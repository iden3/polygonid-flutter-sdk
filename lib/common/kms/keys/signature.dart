import 'dart:typed_data';

abstract class Signature {
  final Uint8List bytes;

  Signature({required this.bytes});
}
