enum CircuitType {
  auth("authV2"),
  mtp("credentialAtomicQueryMTPV2"),
  sig("credentialAtomicQuerySigV2"),
  mtponchain("credentialAtomicQueryMTPV2OnChain"),
  sigonchain("credentialAtomicQuerySigV2OnChain"),
  circuitsV3("credentialAtomicQueryV3$currentCircuitBetaPostfix"),
  circuitsV3onchain("credentialAtomicQueryV3OnChain$currentCircuitBetaPostfix"),
  linkedMultyQuery10("linkedMultiQuery10$currentCircuitBetaPostfix"),
  unknown("");

  static const v3CircuitPrefix = "credentialAtomicQueryV3";
  static const currentCircuitBetaPostfix = "-beta.1";

  final String name;

  const CircuitType(this.name);

  static CircuitType fromString(String value) {
    for (var e in CircuitType.values) {
      if (e.name == value) {
        return e;
      }
    }
    return CircuitType.unknown;
  }
}
