import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/env_config_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/error_exception.dart';
import 'package:polygonid_flutter_sdk/common/utils/collection_utils.dart';

import 'native_polygonidcore.dart';

typedef ConsumedStatusResult = ({PLGNStatusCode statusCode, String message});

typedef GenericPolygonIdFunction = int Function(
  ffi.Pointer<ffi.Pointer<ffi.Char>>,
  ffi.Pointer<ffi.Char>,
  ffi.Pointer<ffi.Char>,
  ffi.Pointer<ffi.Pointer<PLGNStatus>>,
);

ConsumedStatusResult _createConsumedStatusResult(
    PLGNStatusCode statusCode, String message) {
  return (statusCode: statusCode, message: message);
}

@injectable
class PolygonIdCore {
  static late String _envConfigJson;

  static NativePolygonIdCoreLib? _nativePolygonIdCoreLib;

  static NativePolygonIdCoreLib get nativePolygonIdCoreLib {
    final instance = _nativePolygonIdCoreLib;
    if (instance != null) {
      return instance;
    }

    _nativePolygonIdCoreLib = Platform.isAndroid
        ? NativePolygonIdCoreLib(ffi.DynamicLibrary.open("libpolygonid.so"))
        : NativePolygonIdCoreLib(ffi.DynamicLibrary.process());

    return _nativePolygonIdCoreLib!;
  }

  static void setEnvConfig(EnvConfigEntity envConfig) {
    _envConfigJson = jsonEncode(envConfig.toJson());
  }

  PolygonIdCore();

  T callGenericCoreFunction<T>({
    required String Function() input,
    String? config,
    required GenericPolygonIdFunction function,
    void Function(PLGNStatusCode)? statusCodeHandler,
    required T Function(String) parse,
  }) {
    final response = malloc<ffi.Pointer<ffi.Char>>();
    final status = malloc<ffi.Pointer<PLGNStatus>>();
    freeAllocatedMemory() {
      malloc.free(response);
      malloc.free(status);
    }

    final inputPointer = input().toNativeUtf8().cast<ffi.Char>();
    final cfgPointer =
        (config ?? _envConfigJson).toNativeUtf8().cast<ffi.Char>();

    final res = function(response, inputPointer, cfgPointer, status);

    final PLGNStatusCode? statusCode =
        PLGNStatusCode.values.firstWhereOrNull((e) => e.value == res);

    /// Handle error status codes
    if (statusCode == PLGNStatusCode.PLGNSTATUSCODE_ERROR) {
      final consumedStatus = consumeStatus(status);
      freeAllocatedMemory();
      // TODO Should we track this here?
      // _trackError(consumedStatus, "callCoreFunction");
      throw CoreLibraryException(
        coreLibraryName: "libpolygonid",
        methodName: "callCoreFunction",
        errorMessage: consumedStatus.message,
        statusCode: consumedStatus.statusCode,
      );
    } else if (statusCode != null && statusCodeHandler != null) {
      statusCodeHandler(statusCode);
    }

    /// Parse the response
    T result;
    ffi.Pointer<ffi.Char> jsonResponse = response.value;
    ffi.Pointer<Utf8> jsonString = jsonResponse.cast<Utf8>();
    if (jsonString != ffi.nullptr) {
      result = parse(jsonString.toDartString());
    } else {
      throw CoreLibraryException(
        coreLibraryName: "libpolygonid",
        methodName: "callCoreFunction",
        errorMessage: "Unable to parse response",
        statusCode: PLGNStatusCode.PLGNSTATUSCODE_ERROR,
      );
    }

    freeAllocatedMemory();
    return result;
  }

  ConsumedStatusResult consumeStatus(
      ffi.Pointer<ffi.Pointer<PLGNStatus>> status) {
    if (status == ffi.nullptr || status.value == ffi.nullptr) {
      _logError("unable to allocate status");

      return _createConsumedStatusResult(
        PLGNStatusCode.PLGNSTATUSCODE_ERROR,
        "unable to allocate status",
      );
    }

    String errorMessage = status.value.ref.status.toString();
    PLGNStatusCode statusCode = status.value.ref.status;

    if (status.value.ref.error_msg == ffi.nullptr) {
      _logError(status.value.ref.status.toString());
    } else {
      ffi.Pointer<ffi.Char> json = status.value.ref.error_msg;
      ffi.Pointer<Utf8> jsonString = json.cast<Utf8>();
      try {
        errorMessage = jsonString.toDartString();
        _logError(
            "${status.value.ref.status.toString()} - Error: $errorMessage");
      } catch (e) {
        _logError(status.value.ref.status.toString());
      }
    }
    _freeStatus(status);
    return _createConsumedStatusResult(statusCode, errorMessage);
  }

  void _freeStatus(ffi.Pointer<ffi.Pointer<PLGNStatus>> status) {
    nativePolygonIdCoreLib.PLGNFreeStatus(status.value);
  }

  void _logError(String message) {
    if (kDebugMode) {
      logger().e(message);
    }
  }
}
