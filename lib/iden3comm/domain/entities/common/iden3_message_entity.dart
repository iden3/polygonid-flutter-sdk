enum Iden3MessageType {
  authRequest("https://iden3-communication.io/authorization/1.0/request"),
  authResponse("https://iden3-communication.io/authorization/1.0/response"),
  credentialOffer("https://iden3-communication.io/credentials/1.0/offer"),
  onchainCredentialOffer(
      "https://iden3-communication.io/credentials/1.0/onchain-offer"),
  credentialIssuanceResponse(
      "https://iden3-communication.io/credentials/1.0/issuance-response"),
  proofContractInvokeRequest(
      "https://iden3-communication.io/proofs/1.0/contract-invoke-request"),
  proofContractInvokeResponse(
      "https://iden3-communication.io/proofs/1.0/contract-invoke-response"),
  credentialRefresh("https://iden3-communication.io/credentials/1.0/refresh"),
  credentialProposalRequest(
      "https://iden3-communication.io/credentials/0.1/proposal-request"),
  credentialProposal("https://iden3-communication.io/credentials/0.1/proposal"),
  credentialStatusUpdate(
      "https://iden3-communication.io/credentials/1.0/status-update"),
  paymentRequest(
      "https://iden3-communication.io/credentials/0.1/payment-request"),
  payment("https://iden3-communication.io/credentials/0.1/payment"),
  problemReport("https://didcomm.org/report-problem/2.0/problem-report"),
  unknown("");

  final String type;

  const Iden3MessageType(this.type);

  factory Iden3MessageType.fromType(String type) {
    return Iden3MessageType.values.firstWhere(
      (element) => element.type == type,
      orElse: () => Iden3MessageType.unknown,
    );
  }
}

/// Represents an iden3 message.
abstract class Iden3MessageEntity<T> {
  final String id;
  final String typ;
  final String type;
  final Iden3MessageType messageType;
  final String thid;
  final T body;
  final String from;
  final String? to;
  final Map<String, dynamic>? nextRequest;

  const Iden3MessageEntity({
    required this.id,
    required this.typ,
    required this.type,
    this.messageType = Iden3MessageType.unknown,
    required this.thid,
    required this.from,
    this.to,
    this.nextRequest,
    required this.body,
  });

  @override
  String toString() =>
      "[Iden3MessageEntity] {id: $id, typ: $typ, type: $type, messageType: $messageType, thid: $thid, body: $body, from: $from, to: $to, nextRequest: $nextRequest}";

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'typ': typ,
        'type': type,
        'messageType': messageType.name,
        'thid': thid,
        'body': (body as dynamic).toJson(),
        'from': from,
        'to': to,
        'nextRequest': nextRequest,
      }..removeWhere(
          (dynamic key, dynamic value) => key == null || value == null);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Iden3MessageEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          typ == other.typ &&
          type == other.type &&
          messageType == other.messageType &&
          thid == other.thid &&
          body == other.body &&
          from == other.from &&
          to == other.to &&
          nextRequest == other.nextRequest;

  @override
  int get hashCode => runtimeType.hashCode;
}
