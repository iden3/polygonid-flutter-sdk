import 'dart:ffi' as ffi;
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:injectable/injectable.dart';
import 'package:polygonid_flutter_sdk/common/domain/error_exception.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/common/libs/polygonidcore/pidcore_base.dart';

import 'package:polygonid_flutter_sdk/common/libs/polygonidcore/native_polygonidcore.dart';

@injectable
class PolygonIdCoreIdentity extends PolygonIdCore {
  final StacktraceManager _stacktraceManager;

  PolygonIdCoreIdentity(this._stacktraceManager);

  /// PLGNNewGenesisID returns the genesis ID
  String calculateGenesisId(String input, String config) {
    ffi.Pointer<ffi.Char> in1 = input.toNativeUtf8().cast<ffi.Char>();
    ffi.Pointer<ffi.Char> cfg = config.toNativeUtf8().cast<ffi.Char>();
    ffi.Pointer<ffi.Pointer<ffi.Char>> response =
        malloc<ffi.Pointer<ffi.Char>>();
    ffi.Pointer<ffi.Pointer<PLGNStatus>> status =
        malloc<ffi.Pointer<PLGNStatus>>();

    freeAllocatedMemory() {
      malloc.free(response);
      malloc.free(status);
    }

    int res = PolygonIdCore.nativePolygonIdCoreLib
        .PLGNNewGenesisID(response, in1, cfg, status);

    if (res == PLGNStatusCode.PLGNSTATUSCODE_ERROR.value) {
      final ConsumedStatusResult consumedStatus = consumeStatus(status);
      freeAllocatedMemory();
      _trackError(consumedStatus, "PLGNNewGenesisID");
      throw CoreLibraryException(
        coreLibraryName: "libpolygonid",
        methodName: "PLGNNewGenesisID",
        errorMessage: consumedStatus.message,
        statusCode: consumedStatus.statusCode,
      );
    }

    // parse the response
    String result = "";
    ffi.Pointer<ffi.Char> jsonResponse = response.value;
    ffi.Pointer<Utf8> jsonString = jsonResponse.cast<Utf8>();
    if (jsonString != ffi.nullptr) {
      result = jsonString.toDartString();
    }

    freeAllocatedMemory();
    return result;
  }

  /// PLGNNewGenesisIDFromEth returns the genesis ID from an Ethereum address
  String calculateGenesisIdFromEth(String input, String config) {
    ffi.Pointer<ffi.Char> in1 = input.toNativeUtf8().cast<ffi.Char>();
    ffi.Pointer<ffi.Char> cfg = config.toNativeUtf8().cast<ffi.Char>();
    ffi.Pointer<ffi.Pointer<ffi.Char>> response =
        malloc<ffi.Pointer<ffi.Char>>();
    ffi.Pointer<ffi.Pointer<PLGNStatus>> status =
        malloc<ffi.Pointer<PLGNStatus>>();

    freeAllocatedMemory() {
      malloc.free(response);
      malloc.free(status);
    }

    int res = PolygonIdCore.nativePolygonIdCoreLib
        .PLGNNewGenesisIDFromEth(response, in1, cfg, status);

    if (res == PLGNStatusCode.PLGNSTATUSCODE_ERROR.value) {
      final ConsumedStatusResult consumedStatus = consumeStatus(status);
      freeAllocatedMemory();
      _trackError(consumedStatus, "PLGNNewGenesisIDFromEth");
      throw CoreLibraryException(
        coreLibraryName: "libpolygonid",
        methodName: "PLGNNewGenesisIDFromEth",
        errorMessage: consumedStatus.message,
        statusCode: consumedStatus.statusCode,
      );
    }

    // parse the response
    String result = "";
    ffi.Pointer<ffi.Char> jsonResponse = response.value;
    ffi.Pointer<Utf8> jsonString = jsonResponse.cast<Utf8>();
    if (jsonString != ffi.nullptr) {
      result = jsonString.toDartString();
    }

    freeAllocatedMemory();
    return result;
  }

  /// PLGNProfileID returns the profile ID from genesis ID and profile nonce
  String calculateProfileId(String input) {
    ffi.Pointer<ffi.Char> in1 = input.toNativeUtf8().cast<ffi.Char>();
    ffi.Pointer<ffi.Pointer<ffi.Char>> response =
        malloc<ffi.Pointer<ffi.Char>>();
    ffi.Pointer<ffi.Pointer<PLGNStatus>> status =
        malloc<ffi.Pointer<PLGNStatus>>();

    freeAllocatedMemory() {
      malloc.free(response);
      malloc.free(status);
    }

    int res = PolygonIdCore.nativePolygonIdCoreLib
        .PLGNProfileID(response, in1, status);

    if (res == PLGNStatusCode.PLGNSTATUSCODE_ERROR.value) {
      final ConsumedStatusResult consumedStatus = consumeStatus(status);
      freeAllocatedMemory();
      _trackError(consumedStatus, "PLGNProfileID");
      throw CoreLibraryException(
        coreLibraryName: "libpolygonid",
        methodName: "PLGNProfileID",
        errorMessage: consumedStatus.message,
        statusCode: consumedStatus.statusCode,
      );
    }

    // parse the response
    String result = "";
    ffi.Pointer<ffi.Char> jsonResponse = response.value;
    ffi.Pointer<Utf8> jsonString = jsonResponse.cast<Utf8>();
    if (jsonString != ffi.nullptr) {
      result = jsonString.toDartString();
    }

    freeAllocatedMemory();
    return result;
  }

  /// PLGNIDToInt returns the ID as a big int string
  /// Input should be a valid JSON object: string enclosed by double quotes.
  /// Output is a valid JSON object too: string enclosed by double quotes.
  String convertIdToBigInt(String input) {
    ffi.Pointer<ffi.Char> in1 = input.toNativeUtf8().cast<ffi.Char>();
    ffi.Pointer<ffi.Pointer<ffi.Char>> response =
        malloc<ffi.Pointer<ffi.Char>>();
    ffi.Pointer<ffi.Pointer<PLGNStatus>> status =
        malloc<ffi.Pointer<PLGNStatus>>();

    freeAllocatedMemory() {
      malloc.free(response);
      malloc.free(status);
    }

    int res =
        PolygonIdCore.nativePolygonIdCoreLib.PLGNIDToInt(response, in1, status);

    if (res == PLGNStatusCode.PLGNSTATUSCODE_ERROR.value) {
      final ConsumedStatusResult consumedStatus = consumeStatus(status);
      freeAllocatedMemory();
      _trackError(consumedStatus, "PLGNIDToInt");
      throw CoreLibraryException(
        coreLibraryName: "libpolygonid",
        methodName: "PLGNIDToInt",
        errorMessage: consumedStatus.message,
        statusCode: consumedStatus.statusCode,
      );
    }

    // parse the response
    String result = "";
    ffi.Pointer<ffi.Char> jsonResponse = response.value;
    ffi.Pointer<Utf8> jsonString = jsonResponse.cast<Utf8>();
    if (jsonString != ffi.nullptr) {
      result = jsonString.toDartString();
    }

    freeAllocatedMemory();
    return result;
  }

  /// PLGNDescribeID
  String describeId(String input, String? config) {
    ffi.Pointer<ffi.Char> in1 = input.toNativeUtf8().cast<ffi.Char>();
    ffi.Pointer<ffi.Char> cfg = ffi.nullptr;
    if (config != null) {
      cfg = config.toNativeUtf8().cast<ffi.Char>();
    }
    ffi.Pointer<ffi.Pointer<ffi.Char>> response =
        malloc<ffi.Pointer<ffi.Char>>();
    ffi.Pointer<ffi.Pointer<PLGNStatus>> status =
        malloc<ffi.Pointer<PLGNStatus>>();

    freeAllocatedMemory() {
      malloc.free(response);
      malloc.free(status);
    }

    int res = PolygonIdCore.nativePolygonIdCoreLib
        .PLGNDescribeID(response, in1, cfg, status);

    if (res == PLGNStatusCode.PLGNSTATUSCODE_ERROR.value) {
      final ConsumedStatusResult consumedStatus = consumeStatus(status);
      freeAllocatedMemory();
      _trackError(consumedStatus, "PLGNDescribeID");
      throw CoreLibraryException(
        coreLibraryName: "libpolygonid",
        methodName: "PLGNDescribeID",
        errorMessage: consumedStatus.message,
        statusCode: consumedStatus.statusCode,
      );
    }

    // parse the response
    String result = "";
    ffi.Pointer<ffi.Char> jsonResponse = response.value;
    ffi.Pointer<Utf8> jsonString = jsonResponse.cast<Utf8>();
    if (jsonString != ffi.nullptr) {
      result = jsonString.toDartString();
    }

    freeAllocatedMemory();
    return result;
  }

  void _trackError(ConsumedStatusResult consumedStatus, String methodName) {
    _stacktraceManager.addTrace(
        "libpolygonid - $methodName: [${consumedStatus.statusCode}] - ${consumedStatus.message}");
    _stacktraceManager.addError(
        "libpolygonid - $methodName: [${consumedStatus.statusCode}] - ${consumedStatus.message}");
  }
}
