import 'dart:ffi' as ffi;
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:injectable/injectable.dart';
import 'package:polygonid_flutter_sdk/common/domain/error_exception.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/common/libs/polygonidcore/native_polygonidcore.dart';
import 'package:polygonid_flutter_sdk/common/libs/polygonidcore/pidcore_base.dart';

@injectable
class PolygonIdCoreCredential extends PolygonIdCore {
  final StacktraceManager _stacktraceManager;

  PolygonIdCoreCredential(this._stacktraceManager);

  String createClaim(String input) {
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
        .PLGNCreateClaim(response, in1, status);

    // res 0 means error
    if (res == 0) {
      ConsumedStatusResult consumedStatus = consumeStatus(status);
      freeAllocatedMemory();
      _trackError(consumedStatus, "PLGNCreateClaim");
      throw CoreLibraryException(
        coreLibraryName: "libpolygonid",
        methodName: "PLGNCreateClaim",
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

  bool cacheCredentials(String input, String? config) {
    ffi.Pointer<ffi.Char> in1 = input.toNativeUtf8().cast<ffi.Char>();
    ffi.Pointer<ffi.Char> cfg = ffi.nullptr;
    if (config != null) {
      cfg = config.toNativeUtf8().cast<ffi.Char>();
    }
    ffi.Pointer<ffi.Pointer<PLGNStatus>> status =
        malloc<ffi.Pointer<PLGNStatus>>();
    int res = PolygonIdCore.nativePolygonIdCoreLib
        .PLGNCacheCredentials(in1, cfg, status);

    // it means success
    if (res != 0) {
      malloc.free(status);
      return true;
    }

    // in case of error throw exception with error message and status code
    ConsumedStatusResult consumedStatus = consumeStatus(status);
    malloc.free(status);
    _trackError(consumedStatus, "PLGNCacheCredentials");
    throw CoreLibraryException(
      coreLibraryName: "libpolygonid",
      methodName: "PLGNCacheCredentials",
      errorMessage: consumedStatus.message,
      statusCode: consumedStatus.statusCode,
    );
  }

  String w3cCredentialsFromOnchainHex(String input, String? config) {
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
        .PLGNW3CCredentialFromOnchainHex(response, in1, cfg, status);

    // res 0 means error
    if (res == 0) {
      final ConsumedStatusResult consumedStatus = consumeStatus(status);
      freeAllocatedMemory();
      _trackError(consumedStatus, "PLGNW3CCredentialFromOnchainHex");
      throw CoreLibraryException(
        coreLibraryName: "libpolygonid",
        methodName: "PLGNW3CCredentialFromOnchainHex",
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

  String createCredentialFromAnonAadhaarInputs(String input, String? config) {
    return callGenericCoreFunction(
      input: () => input,
      function: PolygonIdCore
          .nativePolygonIdCoreLib.PLGNW3CCredentialFromAnonAadhaarInputs,
      parse: (o) => o,
    );
  }

  void _trackError(ConsumedStatusResult consumedStatus, String methodName) {
    _stacktraceManager.addTrace(
        "libpolygonid - $methodName: [${consumedStatus.statusCode}] - ${consumedStatus.message}");
    _stacktraceManager.addError(
        "libpolygonid - $methodName: [${consumedStatus.statusCode}] - ${consumedStatus.message}");
  }
}
