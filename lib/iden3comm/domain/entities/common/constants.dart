enum ProtocolVersion {
  V1('iden3comm/v1');

  final String name;

  const ProtocolVersion(this.name);
}

enum AcceptAuthCircuits {
  AuthV2('authV2'),
  AuthV3('authV3');

  final String name;

  const AcceptAuthCircuits(this.name);
}

abstract interface class AcceptAlgorithm {
  String get name;
}

enum AcceptJwzAlgorithms implements AcceptAlgorithm {
  Groth16('groth16');

  final String name;

  const AcceptJwzAlgorithms(this.name);
}

enum AcceptJwsAlgorithms implements AcceptAlgorithm {
  ES256K('ES256K'),
  ES256KR('ES256K-R');

  final String name;

  const AcceptJwsAlgorithms(this.name);
}
