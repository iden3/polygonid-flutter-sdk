import 'dart:typed_data';

import 'package:polygonid_flutter_sdk/common/domain/entities/media_type.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/iden3_message_entity.dart';

abstract interface class Packer {
  /// Packs the given payload and returns a promise that resolves to the packed data.
  /// @param payload - The payload to be packed.
  /// @param param - The packing parameters.
  /// @returns A future that resolves to the packed data as a Uint8List.
  Future<Uint8List> pack(Uint8List payload, PackerParams param);

  /// Packs the given message and returns a promise that resolves to the packed data.
  /// @param msg - The message to be packed.
  /// @param param - The packing parameters.
  /// @returns A future that resolves to the packed data as a Uint8List.
  Future<Uint8List> packMessage(Iden3MessageEntity msg, PackerParams param);

  /// Unpacks the given envelope and returns a promise that resolves to the unpacked message.
  /// @param envelope - The envelope to be unpacked.
  /// @returns A future that resolves to the unpacked message as a BasicMessage.
  Future<Iden3MessageEntity> unpack(Uint8List envelope);

  /// Returns the media type associated with the packer.
  /// @returns The media type as a MediaType.
  MediaType mediaType();

  /// gets packer envelope (supported profiles) with options
  ///
  /// @returns {string}
  List<String> getSupportedProfiles();

  /// returns true if profile is supported by packer
  ///
  /// @param {string} profile
  /// @returns {boolean}
  bool isProfileSupported(String profile);
}

///  parameters for any packer
class PackerParams {
  // PackerParams can accept String key and any value as stored values
  // [key in string]: any;
}

///  parameters for zkp packer
class ZKPPackerParams extends PackerParams {
  // DID senderDID;
  String senderDID;

  /// @deprecated
  num? profileNonce;
  ProvingMethodAlg provingMethodAlg;

  ZKPPackerParams({
    required this.senderDID,
    this.profileNonce,
    required this.provingMethodAlg,
  });
}

class ProvingMethodAlg {
  final String alg;
  final String circuitId;

  ProvingMethodAlg({
    required this.alg,
    required this.circuitId,
  });

  @override
  String toString() {
    return 'ProvingMethodAlg{alg: $alg, circuitId: $circuitId}';
  }
}
