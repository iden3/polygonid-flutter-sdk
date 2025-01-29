class SelfIssuedCredentialParams {
  final int revocationNonce;
  final String credentialStatusID;
  final String issuerDid;
  final String publicKey;
  final int nullifierSeed;
  final int signalHash;

  SelfIssuedCredentialParams({
    required this.revocationNonce,
    required this.credentialStatusID,
    required this.issuerDid,
    required this.publicKey,
    required this.nullifierSeed,
    required this.signalHash,
  });

  SelfIssuedCredentialParams.fromJson(Map<String, dynamic> json)
      : revocationNonce = json["credentialStatusRevocationNonce"],
        credentialStatusID = json["credentialStatusID"],
        issuerDid = json["issuerID"],
        publicKey = json["pubKey"],
        nullifierSeed = json["nullifierSeed"],
        signalHash = json["signalHash"];

  Map<String, dynamic> toJson() => {
        "credentialStatusRevocationNonce": revocationNonce,
        "credentialStatusID": credentialStatusID,
        "issuerID": issuerDid,
        "pubKey": publicKey,
        "nullifierSeed": nullifierSeed,
        "signalHash": signalHash,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelfIssuedCredentialParams &&
          runtimeType == other.runtimeType &&
          revocationNonce == other.revocationNonce &&
          credentialStatusID == other.credentialStatusID &&
          issuerDid == other.issuerDid &&
          publicKey == other.publicKey &&
          nullifierSeed == other.nullifierSeed &&
          signalHash == other.signalHash;

  @override
  int get hashCode =>
      revocationNonce.hashCode ^
      credentialStatusID.hashCode ^
      issuerDid.hashCode ^
      publicKey.hashCode ^
      nullifierSeed.hashCode ^
      signalHash.hashCode;
}
