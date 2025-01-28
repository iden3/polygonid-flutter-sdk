import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/payment/response/payment_request_message_entity.dart';

/// https://iden3-communication.io/credentials/0.1/payment-request/#:~:text=Iden3PaymentRequestCryptoV1%20iss
class Iden3PaymentRequestCryptoV1Data extends PaymentRequestData {
  @override
  final String id;
  final String type;
  final PaymentRequestDataType paymentRequestDataType =
      PaymentRequestDataType.cryptoV1;
  final String chainId;
  final String address;
  final String amount;
  final String currency;
  final String? expiration; // historical backward compatibility

  Iden3PaymentRequestCryptoV1Data({
    required this.id,
    required this.type,
    required this.chainId,
    required this.address,
    required this.amount,
    required this.currency,
    this.expiration,
  });

  factory Iden3PaymentRequestCryptoV1Data.fromJson(Map<String, dynamic> json) {
    return Iden3PaymentRequestCryptoV1Data(
      id: json['id'],
      type: json['type'],
      chainId: json['chainId'],
      address: json['address'],
      amount: json['amount'],
      currency: json['currency'],
      expiration: json['expiration'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": type,
      "chainId": chainId,
      "address": address,
      "amount": amount,
      "currency": currency,
      "expiration": expiration,
    };
  }
}
