import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/media_type.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/authorization/request/auth_request_iden3_message_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/iden3_message_entity.dart';

import '../../../common/common_mocks.dart';
import '../../../common/iden3comm_mocks.dart';

var json = jsonDecode(Iden3commMocks.authRequestJson);

void main() {
  group("AuthIden3MessageEntity", () {
    test(
      "fromJson",
      () {
        var authRequest = AuthIden3MessageEntity.fromJson(json);
        expect(authRequest.id, "4dd6479b-99b6-405c-ba9e-c7b18d251a5e");
        expect(authRequest.thid, "4dd6479b-99b6-405c-ba9e-c7b18d251a5e");
        expect(authRequest.from, CommonMocks.did);
        expect(authRequest.typ, MediaType.PlainMessage.name);
        expect(authRequest.messageType, Iden3MessageType.authRequest);
        expect(authRequest.body.reason, "test flow");
        expect(authRequest.body.message, "");
        expect(authRequest.body.callbackUrl, CommonMocks.url);
        expect(authRequest.body.scope?[0].id, 1);
        expect(
            authRequest.body.scope?[0].circuitId, "credentialAtomicQuerySig");
        expect(authRequest.body.scope?[0].optional, false);
        expect(authRequest.body.scope?[0].query.allowedIssuers?[0], "*");
        expect(authRequest.body.scope?[0].query.type, "KYCAgeCredential");
        expect(authRequest.body.scope?[0].query.context,
            "https://raw.githubusercontent.com/iden3/claim-schema-vocab/main/schemas/json-ld/kyc-v3.json-ld");
        expect(authRequest.body.url, "theUrl");
        expect(authRequest.body.credentials?[0].id, "27887");
        expect(authRequest.body.credentials?[0].description,
            "Authenticating with iden3");
      },
    );
  });
}
