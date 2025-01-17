import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/payment/response/payment_rails_request_v1_data.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/payment/response/payment_request_data_proof.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/payment/response/payment_request_message_entity.dart';

class Iden3PaymentRailsERC20RequestV1Data
    extends Iden3PaymentRailsRequestV1Data {
  final String tokenAddress;
  final List<String>? features;

  @override
  PaymentRequestDataType get paymentRequestDataType =>
      PaymentRequestDataType.railsERC20V1;

  Iden3PaymentRailsERC20RequestV1Data({
    required String type,
    required List<String> context,
    required String recipient,
    required String amount,
    required String expirationDate,
    required String nonce,
    required String metadata,
    required List<PaymentRequestDataProof> proof,
    required this.tokenAddress,
    this.features,
  }) : super(
          type: type,
          context: context,
          recipient: recipient,
          amount: amount,
          expirationDate: expirationDate,
          nonce: nonce,
          metadata: metadata,
          proof: proof,
        );

  factory Iden3PaymentRailsERC20RequestV1Data.fromJson(
      Map<String, dynamic> json) {
    return Iden3PaymentRailsERC20RequestV1Data(
      type: json['type'],
      context: List<String>.from(json['@context']),
      tokenAddress: json['tokenAddress'],
      recipient: json['recipient'],
      amount: json['amount'],
      expirationDate: json['expirationDate'],
      nonce: json['nonce'],
      metadata: json['metadata'],
      features:
          json['features'] != null ? List<String>.from(json['features']) : null,
      proof: (json['proof'] as List<dynamic>)
          .map((e) => PaymentRequestDataProof.fromJson(e))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['tokenAddress'] = tokenAddress;
    if (features != null) {
      json['features'] = features!;
    }
    return json;
  }
}
