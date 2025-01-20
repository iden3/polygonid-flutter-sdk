import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:polygonid_flutter_sdk/common/data/exceptions/network_exceptions.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/credential/data/dtos/claim_dto.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/data_sources/remote_iden3comm_data_source.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/dtos/credential/response/fetch_claim_response_dto.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/exceptions/iden3comm_exceptions.dart';

import '../../../common/common_mocks.dart';
import '../dtos/fetch_claim_response_dto_test.dart';
import 'remote_iden3comm_data_source_test.mocks.dart';

//DATA
const token = "theToken";
const url = "theUrl";
const identifier = "theIdentifier";
Response dioResponse = Response(
    data: jsonDecode(mockFetchClaim),
    statusCode: 200,
    requestOptions: RequestOptions(path: url));
Response dioErrorResponse = Response(
    data: 'Error message',
    statusCode: 444,
    requestOptions: RequestOptions(path: url));
Response otherTypeResponse = Response(
    data: jsonDecode(mockOtherTypeFetchClaim),
    statusCode: 200,
    requestOptions: RequestOptions(path: url));
final exception = Exception();

/// We assume [FetchClaimResponseDTO] has been tested
final fetchClaimDTO =
    FetchClaimResponseDTO.fromJson(jsonDecode(mockFetchClaim));
final claim = ClaimDTO(
  id: fetchClaimDTO.credential.id,
  issuer: fetchClaimDTO.from,
  did: identifier,
  expiration: fetchClaimDTO.credential.expirationDate,
  type: fetchClaimDTO.credential.credentialSubject.type,
  info: fetchClaimDTO.credential,
  credentialRawValue: jsonEncode(jsonDecode(mockFetchClaim)),
);

//DEPENDENCIES
MockDio dio = MockDio();
MockStacktraceManager stacktraceStreamManager = MockStacktraceManager();

RemoteIden3commDataSource dataSource = RemoteIden3commDataSource(
  dio,
  stacktraceStreamManager,
);

@GenerateMocks([
  Dio,
  http.Client,
  StacktraceManager,
])
void main() {
  group("Authenticate with token", () {
    test(
        "Given token and authRequest, when called authWithToken, then I expect statusCode 200 response",
        () async {
      //
      when(
        dio.post(
          any,
          data: anyNamed("data"),
          options: anyNamed("options"),
        ),
      ).thenAnswer((realInvocation) => Future.value(dioResponse));

      //
      expect(
        await dataSource.authWithToken(
          url: CommonMocks.url,
          token: CommonMocks.token,
        ),
        dioResponse,
      );

      //
      var captured = verify(dio.post(
        captureAny,
        data: captureAnyNamed('data'),
        options: captureAnyNamed('options'),
      )).captured;

      expect(captured[0], CommonMocks.url);
      expect(captured[1], CommonMocks.token);

      expect(
        captured[2].headers,
        {
          HttpHeaders.acceptHeader: '*/*',
          HttpHeaders.contentTypeHeader: 'text/plain',
        },
      );
    });

    test(
      "Given token and authRequest, when I call authWithToken and a server error occurred with status code 450, then I expect a DioException to be thrown",
      () async {
        // Arrange
        when(
          dio.post(
            any,
            data: anyNamed('data'),
            options: anyNamed('options'),
          ),
        ).thenAnswer(
          (_) => Future.value(dioErrorResponse),
        );

        // Act & Assert
        await expectLater(
          dataSource.authWithToken(
            url: CommonMocks.url,
            token: CommonMocks.token,
          ),
          throwsA(isA<NetworkException>()),
        );

        // Verify
        var captured = verify(
          dio.post(
            captureAny,
            data: captureAnyNamed('data'),
            options: captureAnyNamed('options'),
          ),
        ).captured;

        expect(captured[0], CommonMocks.url);
        expect(captured[1], CommonMocks.token);
        expect(
          captured[2].headers,
          {
            HttpHeaders.acceptHeader: '*/*',
            HttpHeaders.contentTypeHeader: 'text/plain',
          },
        );
      },
    );
  });

  group("Fetch credential", () {
    test(
        "Given parameters, when I call fetchClaim, then I expect a Claim to be returned",
        () async {
      // Given
      when(dio.post(any, data: anyNamed('data'), options: anyNamed('options')))
          .thenAnswer((realInvocation) => Future.value(dioResponse));

      // When
      expect(
          await dataSource.fetchClaim(
              authToken: token, url: url, did: identifier),
          claim);

      // Then
      var captured = verify(dio.post(captureAny,
              data: captureAnyNamed('data'),
              options: captureAnyNamed('options')))
          .captured;

      expect(captured[0], url);
      expect(captured[1], token);
      expect(captured[2].headers, {
        HttpHeaders.acceptHeader: '*/*',
        HttpHeaders.contentTypeHeader: 'text/plain',
      });
    });

    test(
        "Given parameters, when I call fetchClaim and a server error occurred, then I expect an NetworkException to be thrown",
        () async {
      // Given
      when(dio.post(any, data: anyNamed('data'), options: anyNamed('options')))
          .thenAnswer((realInvocation) => Future.value(dioErrorResponse));

      // When
      await expectLater(
          dataSource.fetchClaim(authToken: token, url: url, did: identifier),
          throwsA(isA<NetworkException>()));

      // Then
      var captured = verify(dio.post(captureAny,
              data: captureAnyNamed('data'),
              options: captureAnyNamed('options')))
          .captured;

      expect(captured[0], url);
      expect(captured[1], token);
      expect(captured[2].headers, {
        HttpHeaders.acceptHeader: '*/*',
        HttpHeaders.contentTypeHeader: 'text/plain',
      });
    });

    test(
        "Given parameters, when I call fetchClaim and an unsupported FetchClaimResponseType is returned, then I expect an UnsupportedFetchClaimTypeException to be thrown",
        () async {
      // Given
      when(dio.post(any, data: anyNamed('data'), options: anyNamed('options')))
          .thenAnswer((realInvocation) => Future.value(otherTypeResponse));

      // When
      await dataSource
          .fetchClaim(authToken: token, url: url, did: identifier)
          .then((_) => expect(true, false)) // Be sure we don't succeed
          .catchError((error) {
        expect(error, (isA<UnsupportedFetchClaimTypeException>()));
        expect(error.error, null);
      });

      // Then
      var captured = verify(dio.post(captureAny,
              data: captureAnyNamed('data'),
              options: captureAnyNamed('options')))
          .captured;

      expect(captured[0], url);
      expect(captured[1], token);
      expect(captured[2].headers, {
        HttpHeaders.acceptHeader: '*/*',
        HttpHeaders.contentTypeHeader: 'text/plain',
      });
    });

    test(
        "Given parameters, when I call fetchClaim and an error occurred, then I expect an exception to be thrown",
        () async {
      // Given
      when(dio.post(any, data: anyNamed('data'), options: anyNamed('options')))
          .thenAnswer((realInvocation) => Future.error(exception));

      // When
      await expectLater(
          dataSource.fetchClaim(authToken: token, url: url, did: identifier),
          throwsA(exception));

      // Then
      var captured = verify(dio.post(captureAny,
              data: captureAnyNamed('data'),
              options: captureAnyNamed('options')))
          .captured;

      expect(captured[0], url);
      expect(captured[1], token);
      expect(captured[2].headers, {
        HttpHeaders.acceptHeader: '*/*',
        HttpHeaders.contentTypeHeader: 'text/plain',
      });
    });
  });
}
