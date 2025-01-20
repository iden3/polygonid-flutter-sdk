import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:injectable/injectable.dart';
import 'package:polygonid_flutter_sdk/common/domain/error_exception.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';

import 'package:polygonid_flutter_sdk/common/libs/polygonidcore/native_polygonidcore.dart';
import 'package:polygonid_flutter_sdk/common/libs/polygonidcore/pidcore_base.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/generate_inputs_response.dart';

@injectable
class PolygonIdCoreProof extends PolygonIdCore {
  final StacktraceManager _stacktraceManager;

  PolygonIdCoreProof(this._stacktraceManager);

  String proofFromSmartContract(String input) {
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
        .PLGNProofFromSmartContract(response, in1, status);

    // res 0 means error
    if (res == 0) {
      final ConsumedStatusResult consumedStatus = consumeStatus(status);
      freeAllocatedMemory();
      _trackError(consumedStatus, "PLGNProofFromSmartContract");
      throw CoreLibraryException(
        coreLibraryName: "libpolygonid",
        methodName: "PLGNProofFromSmartContract",
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

  GenerateInputsResponse generateInputs(String input, String? config) {
    return callGenericCoreFunction(
      input: () => input,
      config: config,
      function: PolygonIdCore.nativePolygonIdCoreLib.PLGNAGenerateInputs,
      parse: (result) {
        return GenerateInputsResponse.fromJson(jsonDecode(result));
      },
    );
  }

  void _trackError(ConsumedStatusResult consumedStatus, String methodName) {
    _stacktraceManager.addTrace(
        "libpolygonid - $methodName: [${consumedStatus.statusCode}] - ${consumedStatus.message}");
    _stacktraceManager.addError(
        "libpolygonid - $methodName: [${consumedStatus.statusCode}] - ${consumedStatus.message}");
  }
}
