import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:polygonid_flutter_sdk/common/domain/error_exception.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/common/utils/pinata_gateway_utils.dart';
import 'package:polygonid_flutter_sdk/identity/data/mappers/node_type_entity_mapper.dart';
import 'package:polygonid_flutter_sdk/identity/data/mappers/state_identifier_mapper.dart';

import 'package:polygonid_flutter_sdk/common/data/exceptions/network_exceptions.dart';
import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/utils/uint8_list_utils.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/rhs_node_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/exceptions/identity_exceptions.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/hash_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/node_entity.dart';

class RemoteIdentityDataSource {
  final StacktraceManager _stacktraceManager;

  RemoteIdentityDataSource(this._stacktraceManager);

  Future<RhsNodeEntity> fetchStateRoots({required String url}) async {
    try {
      //fetch rhs state and save it
      String rhsId = url;
      String rhsUrl = rhsId;
      if (rhsId.toLowerCase().startsWith("ipfs://")) {
        String fileHash = rhsId.toLowerCase().replaceFirst("ipfs://", "");

        String? pinataGatewayUrl =
            await PinataGatewayUtils().retrievePinataGatewayUrlFromEnvironment(
          fileHash: fileHash,
        );

        if (pinataGatewayUrl != null) {
          rhsUrl = pinataGatewayUrl;
        } else {
          rhsUrl = "https://ipfs.io/ipfs/$fileHash";
        }
      }

      var rhsUri = Uri.parse(rhsUrl);
      var rhsResponse = await get(rhsUri);
      if (rhsResponse.statusCode == 200) {
        Map<String, dynamic> rhsNode = json.decode(rhsResponse.body);
        rhsNode['node']['children'] =
            (rhsNode['node']['children'] as List<dynamic>)
                .map((e) => HashEntity.fromHex(e as String).toJson())
                .toList();
        rhsNode['node']['hash'] =
            HashEntity.fromHex((rhsNode['node']['hash'] as String)).toJson();
        rhsNode['node']['type'] = "unknown";
        rhsNode['node']['type'] = NodeTypeEntityMapper()
            .mapFrom(NodeEntity.fromJson(rhsNode['node']))
            .name;
        final rhsNodeResponse = RhsNodeEntity.fromJson(rhsNode);
        logger().d('rhs node: ${rhsNodeResponse.toString()}');
        return rhsNodeResponse;
      } else {
        _stacktraceManager.addError(
            "Error fetching state roots with error: ${rhsResponse.statusCode} ${rhsResponse.body}");
        throw NetworkException(
          statusCode: rhsResponse.statusCode,
          errorMessage: rhsResponse.body,
        );
      }
    } on PolygonIdSDKException catch (_) {
      rethrow;
    } catch (error) {
      logger().e('state roots error: $error');
      throw FetchStateRootsException(
        errorMessage: "Error fetching state roots with error: $error",
        error: error,
      );
    }
  }

  Future<Map<String, dynamic>> getNonRevocationProof(
    String identityState,
    BigInt revNonce,
    String rhsBaseUrl,
    Map<String, dynamic>? cachedNonRevProof,
  ) async {
    try {
      /// FIXME: this 2 lines should go to a DS and be called in a repo
      // 1. Fetch state roots from RHS
      final rhsNode =
          await fetchStateRoots(url: rhsBaseUrl + "/" + identityState);
      final rhsNodeType = rhsNode.node.type;
      StateIdentifierMapper identifierMapper = StateIdentifierMapper();

      Map<String, dynamic>? issuer;
      String revTreeRootHash =
          "0000000000000000000000000000000000000000000000000000000000000000";
      if (rhsNodeType == NodeType.state) {
        revTreeRootHash = rhsNode.node.children[1].toString();
        issuer = {
          "state": identifierMapper.mapTo(rhsNode.node.hash.toString()),
          "rootOfRoots":
              identifierMapper.mapTo(rhsNode.node.children[2].toString()),
          "claimsTreeRoot":
              identifierMapper.mapTo(rhsNode.node.children[0].toString()),
          "revocationTreeRoot":
              identifierMapper.mapTo(rhsNode.node.children[1].toString()),
        };
      }

      // 2. Check if cached proof is valid and return it
      if (issuer != null &&
          cachedNonRevProof != null &&
          cachedNonRevProof.isNotEmpty &&
          cachedNonRevProof['issuer']['revocationTreeRoot'] ==
              issuer['revocationTreeRoot']) {
        Map<String, dynamic> result = {};
        result["issuer"] = issuer;
        result["mtp"] = cachedNonRevProof["mtp"];
        return result;
      }

      //3. walk rhs
      bool exists = false;
      List<String> siblings = <String>[];
      String nextKey = revTreeRootHash;
      Uint8List key = Uint8ArrayUtils.bigIntToBytes(revNonce);

      for (int depth = 0; depth < (key.length * 8); depth++) {
        if (BigInt.parse(nextKey) != BigInt.zero) {
          // rev root is not empty
          RhsNodeEntity revNode = await fetchStateRoots(
            url: rhsBaseUrl + "/" + identifierMapper.mapTo(nextKey),
          );
          final nodeType = revNode.node.type;

          if (nodeType == NodeType.middle) {
            if (_testBit(key, depth)) {
              nextKey = revNode.node.children[1].toString();
              siblings.add(revNode.node.children[0].toString());
            } else {
              nextKey = revNode.node.children[0].toString();
              siblings.add(revNode.node.children[1].toString());
            }
          } else if (nodeType == NodeType.leaf) {
            if (Uint8ArrayUtils.leBuff2int(key).toString() ==
                revNode.node.children[0].toString()) {
              exists = true;
              return _mkProof(issuer, exists, siblings, null);
            }
            // We found a leaf whose entry didn't match hIndex
            Map<String, String> nodeAux = {
              "key": revNode.node.children[0].toString(),
              "value": revNode.node.children[1].toString(),
            };
            return _mkProof(issuer, exists, siblings, nodeAux);
          }
        } else {
          return _mkProof(issuer, exists, siblings, null);
        }
      }
      return _mkProof(issuer, false, <String>[], null);
    } catch (error) {
      logger().e("[NonRevProof] Error: $error");
      rethrow;
    }
  }

  // TestBit tests whether the bit n in bitmap is 1.
  bool _testBit(Uint8List byte, int n) {
    return byte[n ~/ 8] & (1 << (n % 8)) != 0;
  }

  Map<String, dynamic> _mkProof(Map<String, dynamic>? issuer, bool exists,
      List<String> siblings, Map<String, String>? nodeAux) {
    Map<String, dynamic> result = {};

    if (issuer != null) {
      result["issuer"] = issuer;
    }

    Map<String, dynamic> mtp = {
      "existence": exists,
      "siblings": siblings,
    };
    if (nodeAux != null) {
      mtp["nodeAux"] = nodeAux;
    }
    result["mtp"] = mtp;

    return result;
  }
}
