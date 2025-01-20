import 'dart:convert';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/authorization/request/auth_request_iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/authorization/response/auth_response_iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/response/problem_report_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/credential/request/credential_proposal_request.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/credential/request/credential_refresh_iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/credential/request/offer_iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/credential/request/onchain_offer_iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/credential/response/credential_proposal_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/credential/response/credential_status_update_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/credential/response/fetch_iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/payment/response/payment_request_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/payment/payment_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/proof/request/contract_iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/exceptions/iden3comm_exceptions.dart';

class GetIden3MessageUseCase extends FutureUseCase<String, Iden3MessageEntity> {
  final StacktraceManager _stacktraceManager;

  GetIden3MessageUseCase(
    this._stacktraceManager,
  );

  @override
  Future<Iden3MessageEntity> execute({required String param}) async {
    try {
      Map<String, dynamic> json = jsonDecode(param);

      final rawType = json['type'] ?? '';
      final type = Iden3MessageType.fromType(rawType);

      switch (type) {
        case Iden3MessageType.authRequest:
          return AuthIden3MessageEntity.fromJson(json);
        case Iden3MessageType.authResponse:
          return AuthResponseIden3MessageEntity.fromJson(json);
        case Iden3MessageType.credentialOffer:
          return OfferIden3MessageEntity.fromJson(json);
        case Iden3MessageType.onchainCredentialOffer:
          return OnchainOfferIden3MessageEntity.fromJson(json);
        case Iden3MessageType.credentialIssuanceResponse:
          return FetchIden3MessageEntity.fromJson(json);
        case Iden3MessageType.proofContractInvokeRequest:
          return ContractIden3MessageEntity.fromJson(json);
        case Iden3MessageType.credentialRefresh:
          return CredentialRefreshIden3MessageEntity.fromJson(json);
        case Iden3MessageType.credentialStatusUpdate:
          return CredentialStatusUpdateMessageEntity.fromJson(json);
        case Iden3MessageType.credentialProposalRequest:
          return CredentialProposalRequest.fromJson(json);
        case Iden3MessageType.credentialProposal:
          return CredentialProposal.fromJson(json);
        case Iden3MessageType.problemReport:
          return ProblemReportMessageEntity.fromJson(json);
        case Iden3MessageType.paymentRequest:
          return PaymentRequestEntity.fromJson(json);
        case Iden3MessageType.payment:
          return PaymentMessageEntity.fromJson(json);
        case Iden3MessageType.unknown:
          throw UnsupportedIden3MsgTypeException(
            type: Iden3MessageType.unknown,
            errorMessage: "Unsupported message type: $type",
          );
      }
    } catch (error) {
      _stacktraceManager.addTrace("[GetIden3MessageUseCase] error: $error");
      _stacktraceManager.addError("[GetIden3MessageUseCase] error: $error");
      return Future.error(error);
    }
  }
}
