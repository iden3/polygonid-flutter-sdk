import 'dart:convert';

import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';

import '../../libs/polygonidcore/pidcore_identity.dart';

class LibPolygonIdCoreIdentityDataSource {
  final PolygonIdCoreIdentity _polygonIdCoreIdentity;

  LibPolygonIdCoreIdentityDataSource(
    this._polygonIdCoreIdentity,
  );

  String calculateGenesisId({
    required String claimsTreeRoot,
    required String blockchain,
    required String network,
    required Map<String, dynamic> config,
    String? method,
  }) {
    String input = jsonEncode({
      "claimsTreeRoot": claimsTreeRoot,
      "blockchain": blockchain,
      "network": network,
      if (method != null) "method": method,
    });

    String cfg = jsonEncode(config);

    String output = _polygonIdCoreIdentity.calculateGenesisId(input, cfg);
    logger().d("calculateGenesisId: $output");

    return jsonDecode(output)["did"];
  }

  String calculateGenesisIdFromEth({
    required String ethAddress,
    required String blockchain,
    required String network,
    required Map<String, dynamic> config,
    String? method,
  }) {
    String input = jsonEncode({
      "ethAddress": ethAddress,
      "blockchain": blockchain,
      "network": network,
      if (method != null) "method": method,
    });

    String cfg = jsonEncode(config);

    String output =
        _polygonIdCoreIdentity.calculateGenesisIdFromEth(input, cfg);
    logger().d("calculateGenesisId: $output");

    return jsonDecode(output)["did"];
  }

  String calculateProfileId(String genesisDid, BigInt profileNonce) {
    String input = jsonEncode({
      "genesisDID": genesisDid,
      "nonce": profileNonce.toString(),
    });

    String output = _polygonIdCoreIdentity.calculateProfileId(input);
    logger().d("calculateProfileId: $output");
    // {"profileDID":"did:iden3:polygon:mumbai:x42d3rxWAC6mGS8AmCVWFUz7Tnndm2QCy1KzksG2R"}

    return jsonDecode(output)["profileDID"];
  }

  String genesisIdToBigInt(String genesisId) {
    String input = jsonEncode(genesisId);
    String output = _polygonIdCoreIdentity.convertIdToBigInt(input);
    String idAsInt = jsonDecode(output);
    logger().d("genesisIdToBigInt: $idAsInt");
    return idAsInt;
  }

  String describeId({
    String? idAsInt,
    String? id,
    String? config,
  }) {
    return _polygonIdCoreIdentity.describeId(
      jsonEncode({
        if (idAsInt != null) "idAsInt": idAsInt,
        if (id != null) "id": id,
      }),
      config,
    );
  }
}
