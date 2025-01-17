import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/exceptions/iden3comm_exceptions.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_iden3message_use_case.dart';

import '../../../common/iden3comm_mocks.dart';
import 'get_iden3_message_use_case_test.mocks.dart';

final unknown = jsonEncode({
  'type': 'unknown',
  'body': 'unknown',
});

// Data
final messages = [
  Iden3commMocks.authRequestJson,
  Iden3commMocks.offerRequestJson,
  Iden3commMocks.fetchRequestJson,
  Iden3commMocks.contractFunctionCallRequestJson
];
final expectations = [
  Iden3commMocks.authRequest,
  Iden3commMocks.offerRequest,
  Iden3commMocks.fetchRequest,
  Iden3commMocks.contractFunctionCallRequest
];
const types = [
  Iden3MessageType.authRequest,
  Iden3MessageType.credentialOffer,
  Iden3MessageType.credentialIssuanceResponse,
  Iden3MessageType.proofContractInvokeRequest
];

// Dependencies
MockStacktraceManager stacktraceManager = MockStacktraceManager();

// Tested instance
GetIden3MessageUseCase useCase = GetIden3MessageUseCase(
  stacktraceManager,
);

@GenerateMocks([
  StacktraceManager,
])
void main() {
  test(
    'Given a string, when I call execute, I expect a Iden3MessageType to be returned',
    () async {
      for (int i = 0; i < types.length; i++) {
        // When
        expect(await useCase.execute(param: messages[i]), expectations[i]);
      }
    },
  );

  test(
    'Given a string with an unknown type, when I call execute, I expect a UnsupportedIden3MsgTypeException to be thrown',
    () async {
      // When
      await useCase
          .execute(param: unknown)
          .then((_) => expect(true, false))
          .catchError((error) {
        expect(error, isA<UnsupportedIden3MsgTypeException>());
        expect(error.type, Iden3MessageType.unknown);
      });
    },
  );

  test(
    'Given a string, when I call execute and an error occured, I expect that exception to be thrown',
    () async {
      // When
      await useCase
          .execute(param: unknown)
          .then((_) => expect(true, false))
          .catchError((error) {
        expect(error, isA<UnsupportedIden3MsgTypeException>());
      });
    },
  );
}
