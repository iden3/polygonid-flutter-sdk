import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/iden3_message_entity.dart';

/// Payment Message Entity
class PaymentMessageEntity extends Iden3MessageEntity<PaymentBody> {
  PaymentMessageEntity({
    required super.id,
    required super.typ,
    required super.type,
    required super.thid,
    required super.from,
    required super.to,
    required super.body,
  }) : super(messageType: Iden3MessageType.payment);

  factory PaymentMessageEntity.fromJson(Map<String, dynamic> json) {
    return PaymentMessageEntity(
      id: json['id'],
      typ: json['typ'],
      type: json['type'],
      thid: json['thid'],
      body: PaymentBody.fromJson(json['body']),
      from: json['from'],
      to: json['to'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'body': body.toJson(),
    };
  }
}

/// Payment Body
class PaymentBody {
  final List<Payment> payments;

  PaymentBody({
    required this.payments,
  });

  factory PaymentBody.fromJson(Map<String, dynamic> json) {
    return PaymentBody(
      payments:
          List<Payment>.from(json['payments'].map((x) => Payment.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payments': payments.map((e) => e.toJson()).toList(),
    };
  }
}

/// Abstract Payment class
abstract class Payment {
  final String type;
  final String? context;
  final PaymentData paymentData;

  Payment({
    required this.type,
    this.context,
    required this.paymentData,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    final String type = json['type'];

    switch (type) {
      case 'Iden3PaymentCryptoV1':
        return Iden3PaymentCryptoV1.fromJson(json);
      case 'Iden3PaymentRailsV1':
        return Iden3PaymentRailsV1.fromJson(json);
      case 'Iden3PaymentRailsERC20V1':
        return Iden3PaymentRailsERC20V1.fromJson(json);
      default:
        throw Exception('Unknown payment type: $type');
    }
  }

  Map<String, dynamic> toJson();
}

/// Iden3PaymentCryptoV1 Payment
class Iden3PaymentCryptoV1 extends Payment {
  final String id;

  Iden3PaymentCryptoV1({
    required this.id,
    String? context,
    required PaymentData paymentData,
  }) : super(
          type: "Iden3PaymentCryptoV1",
          context: context,
          paymentData: paymentData,
        );

  factory Iden3PaymentCryptoV1.fromJson(Map<String, dynamic> json) {
    String? id = json['id'];
    if (id == null) {
      throw Exception('Missing required field "id" for Iden3PaymentCryptoV1');
    }
    String? context = json['@context'];

    return Iden3PaymentCryptoV1(
      id: id,
      context: context,
      paymentData: Iden3PaymentCryptoV1Data.fromJson(json['paymentData']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      if (context != null) '@context': context,
      'paymentData': paymentData.toJson(),
    };
  }
}

/// Iden3PaymentRailsV1 Payment
class Iden3PaymentRailsV1 extends Payment {
  final String nonce;

  Iden3PaymentRailsV1({
    required this.nonce,
    String? context,
    required PaymentData paymentData,
  }) : super(
          type: "Iden3PaymentRailsV1",
          context: context,
          paymentData: paymentData,
        );

  factory Iden3PaymentRailsV1.fromJson(Map<String, dynamic> json) {
    String? nonce = json['nonce'];
    if (nonce == null) {
      throw Exception('Missing required field "nonce" for Iden3PaymentRailsV1');
    }
    String? context = json['@context'];

    return Iden3PaymentRailsV1(
      nonce: nonce,
      context: context,
      paymentData: Iden3PaymentRailsV1Data.fromJson(json['paymentData']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'nonce': nonce,
      'type': type,
      if (context != null) '@context': context,
      'paymentData': paymentData.toJson(),
    };
  }
}

/// Iden3PaymentRailsERC20V1 Payment
class Iden3PaymentRailsERC20V1 extends Payment {
  final String nonce;

  Iden3PaymentRailsERC20V1({
    required this.nonce,
    String? context,
    required PaymentData paymentData,
  }) : super(
          type: "Iden3PaymentRailsERC20V1",
          context: context,
          paymentData: paymentData,
        );

  factory Iden3PaymentRailsERC20V1.fromJson(Map<String, dynamic> json) {
    String? nonce = json['nonce'];
    if (nonce == null) {
      throw Exception(
          'Missing required field "nonce" for Iden3PaymentRailsERC20V1');
    }
    String? context = json['@context'];

    return Iden3PaymentRailsERC20V1(
      nonce: nonce,
      context: context,
      paymentData: Iden3PaymentRailsERC20V1Data.fromJson(json['paymentData']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'nonce': nonce,
      'type': type,
      if (context != null) '@context': context,
      'paymentData': paymentData.toJson(),
    };
  }
}

/// Abstract Payment Data
abstract class PaymentData {
  Map<String, dynamic> toJson();
}

/// Iden3PaymentCryptoV1 Data
class Iden3PaymentCryptoV1Data extends PaymentData {
  final String txId;

  Iden3PaymentCryptoV1Data({required this.txId});

  factory Iden3PaymentCryptoV1Data.fromJson(Map<String, dynamic> json) {
    return Iden3PaymentCryptoV1Data(txId: json['txId']);
  }

  @override
  Map<String, dynamic> toJson() {
    return {'txId': txId};
  }
}

/// Iden3PaymentRailsV1 Data
class Iden3PaymentRailsV1Data extends PaymentData {
  final String txId;
  final String chainId;

  Iden3PaymentRailsV1Data({required this.txId, required this.chainId});

  factory Iden3PaymentRailsV1Data.fromJson(Map<String, dynamic> json) {
    return Iden3PaymentRailsV1Data(
      txId: json['txId'],
      chainId: json['chainId'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'txId': txId,
      'chainId': chainId,
    };
  }
}

/// Iden3PaymentRailsERC20V1 Data
class Iden3PaymentRailsERC20V1Data extends PaymentData {
  final String txId;
  final String chainId;
  final String tokenAddress;

  Iden3PaymentRailsERC20V1Data({
    required this.txId,
    required this.chainId,
    required this.tokenAddress,
  });

  factory Iden3PaymentRailsERC20V1Data.fromJson(Map<String, dynamic> json) {
    return Iden3PaymentRailsERC20V1Data(
      txId: json['txId'],
      chainId: json['chainId'],
      tokenAddress: json['tokenAddress'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'txId': txId,
      'chainId': chainId,
      'tokenAddress': tokenAddress,
    };
  }
}
