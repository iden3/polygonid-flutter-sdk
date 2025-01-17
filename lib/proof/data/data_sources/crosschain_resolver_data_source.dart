import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/universal_resolver_entity.dart';

class ResolverDataSource {
  Future<ResolverResponse> getDidResolution({
    required String universalResolverUrl,
    required String did,
    String? gist,
    String? state,
  }) async {
    final params = _getCallParamsForLog(did, gist, state);
    logger().i("Getting resolver response for: $params");

    var requestUrl = "$universalResolverUrl/1.0/identifiers/$did";
    requestUrl += "?signature=EthereumEip712Signature2021";
    if (gist != null) {
      requestUrl += "&gist=$gist";
    }
    if (state != null) {
      requestUrl += "&state=$state";
    }

    final dio = Dio();
    final response = await dio.get(
      requestUrl,
    );
    try {
      final resolverResponse = ResolverResponse.fromJson(response.data);

      return resolverResponse;
    } catch (e) {
      logger().e("Failed to get resolver response for url $requestUrl", e);
      logger().e("Response is ${response.data}");

      rethrow;
    }
  }
}

String _getCallParamsForLog(String did, String? gist, String? state) {
  final params = {
    "did": did,
    "gist": gist,
    "state": state,
  };

  return jsonEncode(params);
}
