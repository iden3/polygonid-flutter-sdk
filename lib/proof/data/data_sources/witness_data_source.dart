import 'package:circom_witnesscalc/circom_witnesscalc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class WitnessParam {
  final String inputsJson;
  final Uint8List circuitGraphFile;
  final RootIsolateToken rootToken;

  WitnessParam(
    this.inputsJson,
    this.circuitGraphFile,
    this.rootToken,
  );
}

class WitnessDataSource {
  WitnessDataSource();

  Future<Uint8List?> computeWitness({
    required String inputsJson,
    required Uint8List circuitGraphFile,
  }) {
    final rootToken = RootIsolateToken.instance!;

    return compute(
      _computeWitness,
      WitnessParam(
        inputsJson,
        circuitGraphFile,
        rootToken,
      ),
    );
  }
}

/// As this is running in a separate thread, we cannot inject [WitnessAuthLib]
Future<Uint8List?> _computeWitness(WitnessParam param) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(param.rootToken);

  final result = await CircomWitnesscalc().calculateWitness(
    inputs: param.inputsJson,
    graphData: param.circuitGraphFile,
  );

  return result;
}
