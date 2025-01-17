import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/payment/response/payment_request_message_entity.dart';

class Iden3PaymentRequestCryptoV1Data extends PaymentRequestData {
  @override
  final String type;
  final PaymentRequestDataType paymentRequestDataType =
      PaymentRequestDataType.cryptoV1;
  final String amount;
  final String id;
  final String chainId;
  final String address;
  final String currency;
  final String? signature;
  final String? expiration;

  Iden3PaymentRequestCryptoV1Data({
    required this.type,
    required this.amount,
    required this.id,
    required this.chainId,
    required this.address,
    required this.currency,
    this.signature,
    this.expiration,
  });

  factory Iden3PaymentRequestCryptoV1Data.fromJson(Map<String, dynamic> json) {
    return Iden3PaymentRequestCryptoV1Data(
      type: json['type'],
      amount: json['amount'],
      id: json['id'],
      chainId: json['chainId'],
      address: json['address'],
      currency: json['currency'],
      signature: json['signature'],
      expiration: json['expiration'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "amount": amount,
      "id": id,
      "chainId": chainId,
      "address": address,
      "currency": currency,
      "signature": signature,
      "expiration": expiration,
    };
  }
}
