class ResolverResponse {
  final String context;
  final dynamic didDocument;
  final DidResolutionMetadata didResolutionMetadata;
  final dynamic didDocumentMetadata;

  ResolverResponse({
    required this.context,
    required this.didDocument,
    required this.didResolutionMetadata,
    required this.didDocumentMetadata,
  });

  factory ResolverResponse.fromJson(Map<String, dynamic> json) {
    return ResolverResponse(
      context: json['@context'],
      didDocument: json['didDocument'],
      didResolutionMetadata:
          DidResolutionMetadata.fromJson(json['didResolutionMetadata']),
      didDocumentMetadata: json['didDocumentMetadata'],
    );
  }
}

class DidResolutionMetadata {
  final List<String> context;
  final String contentType;
  final String retrieved;
  final String type;
  final List<DidResolutionProof> proof;

  DidResolutionMetadata({
    required this.context,
    required this.contentType,
    required this.retrieved,
    required this.type,
    required this.proof,
  });

  factory DidResolutionMetadata.fromJson(Map<String, dynamic> json) {
    return DidResolutionMetadata(
      context: List<String>.from(json['@context']),
      contentType: json['contentType'],
      retrieved: json['retrieved'],
      type: json['type'],
      proof: List<DidResolutionProof>.from(
          json['proof'].map((x) => DidResolutionProof.fromJson(x))),
    );
  }
}

class DidResolutionProof {
  final String type;
  final String proofPurpose;
  final String proofValue;
  final String verificationMethod;
  final String created;
  final EIP712Entity eip712;

  DidResolutionProof({
    required this.type,
    required this.proofPurpose,
    required this.proofValue,
    required this.verificationMethod,
    required this.created,
    required this.eip712,
  });

  factory DidResolutionProof.fromJson(Map<String, dynamic> json) =>
      DidResolutionProof(
        type: json['type'],
        proofPurpose: json['proofPurpose'],
        proofValue: json['proofValue'],
        verificationMethod: json['verificationMethod'],
        created: json['created'],
        eip712: EIP712Entity.fromJson(json['eip712']),
      );
}

class EIP712Entity {
  final dynamic types;
  final String primaryType;
  final dynamic domain;
  final BaseEIP712Message message;

  EIP712Entity({
    required this.types,
    required this.primaryType,
    required this.domain,
    required this.message,
  });

  factory EIP712Entity.fromJson(Map<String, dynamic> json) => EIP712Entity(
        types: json['types'],
        primaryType: json['primaryType'],
        domain: json['domain'],
        message: BaseEIP712Message.fromJson(json['message']),
      );
}

abstract class BaseEIP712Message {
  final String replacedAtTimestamp;
  final String timestamp;

  BaseEIP712Message({
    required this.replacedAtTimestamp,
    required this.timestamp,
  });

  factory BaseEIP712Message.fromJson(Map<String, dynamic> json) {
    // TODO Refactor
    if (json['idType'] != null) {
      return GlobalStateEIP712Message.fromJson(json);
    } else {
      return IdentityStateEIP712Message.fromJson(json);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'replacedAtTimestamp': replacedAtTimestamp,
      'timestamp': timestamp,
    };
  }
}

class GlobalStateEIP712Message extends BaseEIP712Message {
  final String idType;
  final String root;

  GlobalStateEIP712Message({
    required this.idType,
    required super.replacedAtTimestamp,
    required this.root,
    required super.timestamp,
  });

  factory GlobalStateEIP712Message.fromJson(Map<String, dynamic> json) =>
      GlobalStateEIP712Message(
        idType: json['idType'],
        replacedAtTimestamp: json['replacedAtTimestamp'],
        root: json['root'],
        timestamp: json['timestamp'],
      );

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'idType': idType,
      'root': root,
    };
  }
}

class IdentityStateEIP712Message extends BaseEIP712Message {
  final String id;
  final String state;

  IdentityStateEIP712Message({
    required this.id,
    required super.replacedAtTimestamp,
    required this.state,
    required super.timestamp,
  });

  factory IdentityStateEIP712Message.fromJson(Map<String, dynamic> json) =>
      IdentityStateEIP712Message(
        id: json['id'],
        replacedAtTimestamp: json['replacedAtTimestamp'],
        state: json['state'],
        timestamp: json['timestamp'],
      );

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'id': id,
      'state': state,
    };
  }
}
