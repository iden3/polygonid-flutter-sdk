import 'dart:convert';
import 'dart:typed_data';

import 'package:polygonid_flutter_sdk/common/domain/entities/media_type.dart';
import 'package:polygonid_flutter_sdk/common/packer/types/package_manager.dart';
import 'package:polygonid_flutter_sdk/common/packer/types/packer.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/iden3_message_entity.dart';

const _byteEncoder = Utf8Encoder();
const _byteDecoder = Utf8Decoder();

/// Basic package manager for iden3 communication protocol
///
/// @public
/// @class PackageManager
/// @implements implements IPackageManager interface
class PackageManagerImpl implements PackageManager {
  @override
  final packers = <MediaType, Packer>{};

  /// Creates an instance of PackageManager.
  PackageManagerImpl();

  /// {@inheritDoc IPackageManager.isProfileSupported}
  @override
  bool isProfileSupported(MediaType mediaType, String profile) {
    final p = packers[mediaType];
    if (p == null) {
      return false;
    }

    return p.isProfileSupported(profile);
  }

  /// {@inheritDoc IPackageManager.getSupportedMediaTypes}
  @override
  List<MediaType> getSupportedMediaTypes() {
    return [...packers.keys];
  }

  /// {@inheritDoc IPackageManager.registerPackers}
  @override
  void registerPackers(List<Packer> packers) {
    for (var p in packers) {
      this.packers[p.mediaType()] = p;
    }
  }

  /// {@inheritDoc IPackageManager.pack}
  @override
  Future<Uint8List> pack(
      MediaType mediaType, Uint8List payload, PackerParams params) async {
    final p = packers[mediaType];
    if (p == null) {
      throw Exception('packer for media type $mediaType not found');
    }

    return await p.pack(payload, params);
  }

  /// Packs a protocol message using the specified media type and packer parameters.
  ///
  /// @param mediaType - The media type to use for packing the message.
  /// @param protocolMessage - The protocol message to pack.
  /// @param params - The packer parameters.
  /// @returns A promise that resolves to the packed message as a Uint8List.
  /// @throws An error if the packer for the specified media type is not found.
  @override
  Future<Uint8List> packMessage(
    MediaType mediaType,
    Iden3MessageEntity protocolMessage,
    PackerParams params,
  ) async {
    final p = packers[mediaType];
    if (p == null) {
      throw Exception("packer for media type $mediaType not found");
    }

    return p.packMessage(protocolMessage, params);
  }

  /// {@inheritDoc IPackageManager.unpack}
  @override
  Future<({Iden3MessageEntity unpackedMessage, MediaType unpackedMediaType})>
      unpack(
    Uint8List envelope,
  ) async {
    final decodedStr = _byteDecoder.convert(envelope);
    final safeEnvelope = decodedStr.trim();
    final mediaType = getMediaType(safeEnvelope);
    return (
      unpackedMessage: await _unpackWithSafeEnvelope(
        mediaType,
        _byteEncoder.convert(safeEnvelope),
      ),
      unpackedMediaType: mediaType
    );
  }

  /// {@inheritDoc IPackageManager.unpackWithType}
  @override
  Future<Iden3MessageEntity> unpackWithType(
    MediaType mediaType,
    Uint8List envelope,
  ) async {
    final decodedStr = _byteDecoder.convert(envelope);
    final safeEnvelope = decodedStr.trim();
    return await _unpackWithSafeEnvelope(
      mediaType,
      _byteEncoder.convert(safeEnvelope),
    );
  }

  Future<Iden3MessageEntity> _unpackWithSafeEnvelope(
    MediaType mediaType,
    Uint8List envelope,
  ) async {
    final p = packers[mediaType];
    if (p == null) {
      throw Exception("packer for media type $mediaType not found");
    }
    final msg = await p.unpack(envelope);
    return msg;
  }

  /// {@inheritDoc IPackageManager.getMediaType}
  @override
  MediaType getMediaType(String envelope) {
    // check if envelope is a json string
    if (envelope[0] == '{') {
      final envelopeStub = jsonDecode(envelope);
      return MediaType.fromJson(envelopeStub['typ']);
    }
    // Envelope is base64 string
    final header = envelope.split('.')[0];
    Uint8List base64HeaderBytes = base64Decode(header);

    final headerStr = _byteDecoder.convert(base64HeaderBytes);
    final headerStub = jsonDecode(headerStr);

    return headerStub['typ'];
  }
}
