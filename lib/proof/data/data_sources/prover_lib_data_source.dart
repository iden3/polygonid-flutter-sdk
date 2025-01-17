import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rapidsnark/flutter_rapidsnark.dart';

class ProveParam {
  final String zKeyPath;
  final Uint8List wtns;
  final RootIsolateToken rootToken;

  ProveParam(
    this.zKeyPath,
    this.wtns,
    this.rootToken,
  );
}

class ProverLibDataSource {
  ProverLibDataSource();

  ///
  Future<Map<String, dynamic>?> prove(
    String zKeyPath,
    Uint8List wtnsBytes,
  ) async {
    final rootToken = RootIsolateToken.instance!;

    return compute(
      _computeProof,
      ProveParam(zKeyPath, wtnsBytes, rootToken),
    );
  }
}

///
Future<Map<String, dynamic>?> _computeProof(ProveParam param) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(param.rootToken);

  final result = await Rapidsnark().groth16Prove(
    zkeyPath: param.zKeyPath,
    witness: param.wtns,
  );

  return {
    'proof': jsonDecode(result.proof),
    'pub_signals': jsonDecode(result.publicSignals),
  };
}
