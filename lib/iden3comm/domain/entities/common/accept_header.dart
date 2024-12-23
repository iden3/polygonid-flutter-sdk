import 'package:collection/collection.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/media_type.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/constants.dart';

const _mediaTypePrefix = 'env=';
const _circuitIdPrefix = 'circuitId=';
const _algorithmPrefix = 'alg=';

class AcceptProfile {
  final ProtocolVersion protocolVersion;
  final MediaType mediaType;
  final List<AcceptAuthCircuits>? circuits;
  final List<AcceptAlgorithm>? alg;

  const AcceptProfile({
    required this.protocolVersion,
    required this.mediaType,
    this.circuits,
    this.alg,
  });

  static const defaultProfile = AcceptProfile(
    protocolVersion: ProtocolVersion.V1,
    mediaType: MediaType.ZKPMessage,
    circuits: [AcceptAuthCircuits.AuthV2],
    alg: [AcceptJwzAlgorithms.Groth16],
  );

  factory AcceptProfile.fromJson(String json) {
    final params = json.split(";");

    if (params.length < 2) {
      throw Exception("Invalid accept profile");
    }

    /// protocolVersion
    final protocolVersion = ProtocolVersion.values.firstWhere(
      (e) => e.name == params[0],
      orElse: () => throw Exception("Invalid protocol version"),
    );

    /// mediaType
    final mediaTypeRaw = params
        .firstWhere((e) => e.startsWith(_mediaTypePrefix))
        .replaceFirst(_mediaTypePrefix, '');
    final mediaType = MediaType.fromJson(mediaTypeRaw);

    /// circuits
    final circuitsIdx = params.indexWhere((i) => i.contains(_circuitIdPrefix));
    if (mediaType != MediaType.ZKPMessage && circuitsIdx > 0) {
      throw Exception("Circuits not supported for env '$mediaType'");
    }

    final circuitId = params
        .firstWhereOrNull((e) => e.startsWith(_circuitIdPrefix))
        ?.replaceFirst(_circuitIdPrefix, '')
        .split(',')
        .map((e) => AcceptAuthCircuits.values.firstWhere((c) => c.name == e))
        .toList();

    /// alg
    final algorithm = params
        .firstWhereOrNull((e) => e.startsWith(_algorithmPrefix))
        ?.replaceFirst(_algorithmPrefix, '')
        .split(',')
        .map<AcceptAlgorithm>((e) {
      if (mediaType == MediaType.ZKPMessage) {
        return AcceptJwzAlgorithms.values.firstWhere(
          (c) => c.name == e,
          orElse: () => throw Exception("Invalid algorithm for $mediaTypeRaw"),
        );
      } else if (mediaType == MediaType.SignedMessage) {
        return AcceptJwsAlgorithms.values.firstWhere(
          (c) => c.name == e,
          orElse: () => throw Exception("Invalid algorithm for $mediaTypeRaw"),
        );
      } else {
        throw Exception("Invalid media type");
      }
    }).toList();

    return AcceptProfile(
      protocolVersion: protocolVersion,
      mediaType: mediaType,
      circuits: circuitId,
      alg: algorithm,
    );
  }

  String toJson() {
    final circuits = this.circuits;
    final alg = this.alg;
    return [
      protocolVersion,
      _mediaTypePrefix + mediaType.name,
      if (circuits != null) _circuitIdPrefix + circuits.join(','),
      if (alg != null) _algorithmPrefix + alg.join(','),
    ].join(";");
  }
}
