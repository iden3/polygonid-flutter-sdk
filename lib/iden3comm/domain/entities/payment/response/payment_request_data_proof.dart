class PaymentRequestDataProof {
  final String type;
  final String proofPurpose;
  final String proofValue;
  final String verificationMethod;
  final String created;
  final EIP712 eip712;

  PaymentRequestDataProof({
    required this.type,
    required this.proofPurpose,
    required this.proofValue,
    required this.verificationMethod,
    required this.created,
    required this.eip712,
  });

  factory PaymentRequestDataProof.fromJson(Map<String, dynamic> json) {
    return PaymentRequestDataProof(
      type: json['type'],
      proofPurpose: json['proofPurpose'],
      proofValue: json['proofValue'],
      verificationMethod: json['verificationMethod'],
      created: json['created'],
      eip712: EIP712.fromJson(json['eip712']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "proofPurpose": proofPurpose,
      "proofValue": proofValue,
      "verificationMethod": verificationMethod,
      "created": created,
      "eip712": eip712.toJson(),
    };
  }
}

class EIP712 {
  final String types;
  final String primaryType;
  final Domain domain;

  EIP712({
    required this.types,
    required this.primaryType,
    required this.domain,
  });

  factory EIP712.fromJson(Map<String, dynamic> json) {
    return EIP712(
      types: json['types'],
      primaryType: json['primaryType'],
      domain: Domain.fromJson(json['domain']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "types": types,
      "primaryType": primaryType,
      "domain": domain.toJson(),
    };
  }
}

class Domain {
  final String name;
  final String version;
  final String chainId;
  final String verifyingContract;
  final String? salt;

  Domain({
    required this.name,
    required this.version,
    required this.chainId,
    required this.verifyingContract,
    this.salt,
  });

  factory Domain.fromJson(Map<String, dynamic> json) {
    return Domain(
      name: json['name'],
      version: json['version'],
      chainId: json['chainId'],
      verifyingContract: json['verifyingContract'],
      salt: json['salt'],
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      "name": name,
      "version": version,
      "chainId": chainId,
      "verifyingContract": verifyingContract,
    };
    if (salt != null) {
      json['salt'] = salt!;
    }
    return json;
  }
}
