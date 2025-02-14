import 'package:polygonid_flutter_sdk/proof/data/data_sources/lib_pidcore_proof_data_source.dart';
import 'package:polygonid_flutter_sdk/sdk/di/injector.dart';

class ProofFromSmartContract {
  static final ProofFromSmartContract _instance =
      ProofFromSmartContract._internal();

  factory ProofFromSmartContract() {
    return _instance;
  }

  ProofFromSmartContract._internal();

  Future<String> getProofFromSmartContract({required String inputs}) async {
    final libPolygonIdProof = getItSdk<LibPolygonIdCoreProofDataSource>();
    final String proof = libPolygonIdProof.proofFromSC(inputs);
    return proof;
  }
}
