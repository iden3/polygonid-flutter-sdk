import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/payment/response/payment_rails_erc20_request_v1_data.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/payment/response/payment_rails_request_v1_data.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/payment/response/payment_request_crypto_v1_data.dart';

/*
https://iden3-communication.io/credentials/0.1/payment-request

{
  "id": "36f9e851-d713-4b50-8f8d-8a9382f138ca",
  "thid": "36f9e851-d713-4b50-8f8d-8a9382f138ca",
  "typ": "application/iden3comm-plain-json",
  "type": "https://iden3-communication.io/credentials/0.1/payment-request",
  "body": {
     "payments": [
      {
       "credentials": [
        {
         "type": "AML",
         "context": "http://test.com"
        }
       ],
       "type": "PaymentRequest",
       "data": {
	       "type": "Iden3PaymentCryptoV1",
	       "amount": 10,
	       "id": "ox",
	       "address": "0xpay1",
	       "signature": "sig"
       },
       "agent": "https://issuer.com",
       "expiration": "timestamp",
       "description": "you can pass the verification on our KYC provider by following the next link"
     }
	  ]
  },
  "to": "did:polygonid:polygon:mumbai:2qJUZDSCFtpR8QvHyBC4eFm6ab9sJo5rqPbcaeyGC4",
  "from": "did:iden3:polygon:mumbai:x3HstHLj2rTp6HHXk2WczYP7w3rpCsRbwCMeaQ2H2"
}
*/
class PaymentRequestEntity extends Iden3MessageEntity<PaymentRequestBody> {
  PaymentRequestEntity({
    required super.id,
    required super.typ,
    required super.type,
    required super.thid,
    required super.from,
    required super.to,
    required super.body,
  }) : super(messageType: Iden3MessageType.paymentRequest);

  factory PaymentRequestEntity.fromJson(Map<String, dynamic> json) {
    return PaymentRequestEntity(
      id: json['id'],
      typ: json['typ'],
      type: json['type'],
      thid: json['thid'],
      body: PaymentRequestBody.fromJson(json['body']),
      from: json['from'],
      to: json['to'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      "body": body.toJson(),
    };
  }
}

class PaymentRequestBody {
  final String agent;
  final List<PaymentRequest> payments;

  PaymentRequestBody({
    required this.agent,
    required this.payments,
  });

  factory PaymentRequestBody.fromJson(Map<String, dynamic> json) {
    return PaymentRequestBody(
      agent: json['agent'],
      payments: (json['payments'] as List<dynamic>)
          .map((x) => PaymentRequest.fromJson(x))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "agent": agent,
      "payments": payments.map((e) => e.toJson()).toList(),
    };
  }
}

class PaymentRequest {
  final List<CredentialInfo> credentials;
  final List<PaymentRequestData> data;
  final String description;

  PaymentRequest({
    required this.credentials,
    required this.data,
    required this.description,
  });

  factory PaymentRequest.fromJson(Map<String, dynamic> json) {
    return PaymentRequest(
      description: json['description'],
      credentials: (json['credentials'] as List<dynamic>)
          .map((x) => CredentialInfo.fromJson(x))
          .toList(),
      data: json['data'] is List
          ? (json['data'] as List<dynamic>)
              .map((x) => PaymentRequestDataFactory.fromJson(x))
              .toList()
          : json['data'] is Map<String, dynamic>
              ? [PaymentRequestDataFactory.fromJson(json['data'])]
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "description": description,
      "credentials": credentials.map((e) => e.toJson()).toList(),
      "data": data.map((e) => e.toJson()).toList(),
    };
  }
}

enum PaymentRequestDataType {
  cryptoV1,
  railsV1,
  railsERC20V1,
}

class PaymentRequestDataFactory {
  static PaymentRequestData fromJson(Map<String, dynamic> json) {
    String type = json['type'];

    switch (type) {
      case 'Iden3PaymentRequestCryptoV1':
        return Iden3PaymentRequestCryptoV1Data.fromJson(json);
      case 'Iden3PaymentRailsRequestV1':
        return Iden3PaymentRailsRequestV1Data.fromJson(json);
      case 'Iden3PaymentRailsERC20RequestV1':
        return Iden3PaymentRailsERC20RequestV1Data.fromJson(json);
      default:
        throw Exception('Unknown payment request data type: $type');
    }
  }
}

/*
"proposals": [{
			"credentials": [{
				"type": "AnimaProofOfLife",
				"context": "https://raw.githubusercontent.com/anima-protocol/claims-polygonid/main/schemas/json-ld/pol-v1.json-ld"
			}],
			"type": "SynapsCredentialProposal",
			"url": "https://synaps-backend-test.polygonid.me/verification?session={{sessionID}}&did={{holderDid}}",
			"description": "Synaps credential proposal"
		}]
*/

class CredentialInfo {
  final String type;
  final String context;

  CredentialInfo({
    required this.type,
    required this.context,
  });

  factory CredentialInfo.fromJson(Map<String, dynamic> json) {
    return CredentialInfo(
      type: json['type'],
      context: json['context'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "context": context,
    };
  }
}

abstract class PaymentRequestData {
  String get type;

  PaymentRequestDataType get paymentRequestDataType;

  Map<String, dynamic> toJson();
}
