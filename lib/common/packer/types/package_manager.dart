import 'dart:typed_data';

import 'package:polygonid_flutter_sdk/common/domain/entities/media_type.dart';
import 'package:polygonid_flutter_sdk/common/packer/types/packer.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/iden3_message_entity.dart';

/// Interface for defining the registry of packers
///
/// @public
/// @interface   IPackageManager
abstract interface class PackageManager {
  /// Map of packers key is media type, value is packer implementation
  ///
  /// @type {Map<MediaType, IPacker>}
  Map<MediaType, Packer> get packers;

  /// registers new packer in the manager
  ///
  /// @param {Array<IPacker>} packers
  void registerPackers(List<Packer> packers);

  /// packs payload with a packer that is assigned to media type
  /// forwards packer params to implementation
  ///
  /// @param {MediaType} mediaType
  /// @param {Uint8List} payload
  /// @param {PackerParams} params
  /// @returns `Future<Uint8List>`
  Future<Uint8List> pack(
    MediaType mediaType,
    Uint8List payload,
    PackerParams params,
  );

  /// packs payload with a packer that is assigned to media type
  /// forwards packer params to implementation
  ///
  /// @param {MediaType} mediaType
  /// @param {BasicMessage} protocolMessage
  /// @param {PackerParams} params
  /// @returns `Future<Uint8List>`
  Future<Uint8List> packMessage(
    MediaType mediaType,
    Iden3MessageEntity protocolMessage,
    PackerParams params,
  );

  /// unpacks packed envelope to basic protocol message and returns media type of the envelope
  ///
  /// @param {Uint8List} envelope - bytes envelope
  /// @returns `Future<{ unpackedMessage: BasicMessage; unpackedMediaType: MediaType }`
  Future<({Iden3MessageEntity unpackedMessage, MediaType unpackedMediaType})>
      unpack(
    Uint8List envelope,
  );

  /// unpacks an envelope with a known media type
  ///
  /// @param {MediaType} mediaType
  /// @param {Uint8List} envelope
  /// @returns `Future<BasicMessage>`
  Future<Iden3MessageEntity> unpackWithType(
    MediaType mediaType,
    Uint8List envelope,
  );

  /// gets media type from an envelope
  ///
  /// @param {string} envelope
  /// @returns MediaType
  MediaType getMediaType(String envelope);

  /// gets supported media types by packer manager
  ///
  /// @returns MediaType[]
  List<MediaType> getSupportedMediaTypes();

  /// returns true if media type and algorithms supported by packer manager
  ///
  /// @param {MediaType} mediaType
  /// @param {string} profile
  /// @returns {boolean}
  bool isProfileSupported(MediaType mediaType, String profile);
}
