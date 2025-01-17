import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:polygonid_flutter_sdk/common/data/exceptions/network_exceptions.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';

import 'package:polygonid_flutter_sdk/constants.dart';
import 'package:polygonid_flutter_sdk/sdk/di/injector.dart';

Future<String> extractJSON(http.Response response) async {
  return response.body;
}

Future<http.Response> get(
  String baseAddress,
  String endpoint, {
  Map<String, String?>? queryParameters,
}) async {
  var response;
  try {
    Uri uri;
    if (endpoint.isEmpty) {
      uri = Uri.parse(baseAddress);
    } else {
      baseAddress = baseAddress.replaceFirst("https://", "");
      if (queryParameters != null) {
        uri = Uri.https(baseAddress, endpoint, queryParameters);
      } else {
        uri = Uri.https(baseAddress, endpoint);
      }
    }
    response = await http.get(
      uri,
      headers: {
        HttpHeaders.acceptHeader: 'application/json',
      },
    );

    return returnResponseOrThrowException(response);
  } on IOException {
    StacktraceManager _stacktraceManager = getItSdk.get<StacktraceManager>();
    _stacktraceManager.addError("network error with IO exception");
    throw NetworkException(
      errorMessage: "network error",
      statusCode: 0,
    );
  } catch (e) {
    return response;
  }
}

Future<http.Response> post(String baseAddress, String endpoint,
    {Map<String, dynamic>? body}) async {
  var response;
  try {
    Uri uri;
    baseAddress = baseAddress.replaceFirst("https://", "");
    uri = Uri.https(baseAddress, '$API_VERSION$endpoint');
    response = await http.post(
      uri,
      body: json.encode(body),
      headers: {
        HttpHeaders.acceptHeader: '*/*',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    return returnResponseOrThrowException(response);
  } on IOException {
    StacktraceManager _stacktraceManager = getItSdk.get<StacktraceManager>();
    _stacktraceManager.addError("network error with IO exception");
    throw NetworkException(
      errorMessage: "network error",
      statusCode: 0,
    );
  } catch (e) {
    return response;
  }
}

http.Response returnResponseOrThrowException(http.Response response) {
  int statusCode = response.statusCode;
  String responseBody = response.body;
  if (statusCode == 404) {
    // Not found
    throw ItemNotFoundException(errorMessage: "statusCode: 404\n$responseBody");
  } else if (statusCode == 500) {
    throw InternalServerErrorException(
        errorMessage: "statusCode: 500\n$responseBody");
  } else if (statusCode == 400) {
    throw BadRequestException(errorMessage: "statusCode: 400\n$responseBody");
  } else if (statusCode == 409) {
    throw ConflictErrorException(
        errorMessage: "statusCode: 409\n$responseBody");
  } else if (statusCode > 400) {
    throw UnknownApiException(
        httpCode: statusCode,
        errorMessage: "statusCode: $statusCode\n$responseBody");
  } else {
    return response;
  }
}
