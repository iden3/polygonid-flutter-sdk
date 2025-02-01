import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:polygonid_flutter_sdk/identity/data/data_sources/wallet_data_source.dart';
import 'package:polygonid_flutter_sdk/identity/libs/bjj/bjj_wallet.dart';

import '../../../common/common_mocks.dart';
import 'wallet_data_source_test.mocks.dart';

// Data
class FakeWallet extends Fake implements BjjWallet {
  @override
  Uint8List get privateKey => walletPrivateKey;

  @override
  List<String> get publicKey => CommonMocks.publicKey;
}

final walletPrivateKey =
    Uint8List.fromList(CommonMocks.walletPrivateKey.codeUnits);
var mockWallet = FakeWallet();
var exception = Exception();

// Dependencies
MockWalletLibWrapper walletLibWrapper = MockWalletLibWrapper();

// Tested instance
WalletDataSource dataSource = WalletDataSource(walletLibWrapper);

@GenerateMocks([WalletLibWrapper])
void main() {
  group("Create wallet", () {
    test(
        "Given a private key, when I call createWallet, then I expect an PrivadoIdWallet to be returned",
        () async {
      // Given
      when(walletLibWrapper.createWallet(secret: anyNamed('secret')))
          .thenAnswer((realInvocation) => Future.value(mockWallet));

      // When
      expect(
          await dataSource.createWallet(secret: walletPrivateKey), mockWallet);

      // Then
      var createCaptured = verify(
              walletLibWrapper.createWallet(secret: captureAnyNamed('secret')))
          .captured;
      expect(createCaptured[0], walletPrivateKey);
    });

    test(
        "Given a private key, when I call createWallet and an error occured, then I expect an exception to be thrown",
        () async {
      // Given
      when(walletLibWrapper.createWallet(secret: anyNamed('secret')))
          .thenAnswer((realInvocation) => Future.error(exception));

      // When
      await expectLater(dataSource.createWallet(secret: walletPrivateKey),
          throwsA(exception));

      // Then
      expect(
          verify(walletLibWrapper.createWallet(
                  secret: captureAnyNamed('secret')))
              .captured
              .first,
          walletPrivateKey);
    });
  });

  group("Sign message", () {
    setUp(() {
      when(walletLibWrapper.createWallet(secret: anyNamed('secret')))
          .thenAnswer((realInvocation) => Future.value(mockWallet));
    });

    test(
        "Given a private key and a message, when I call signMessage, then I expect a signature as a String to be returned",
        () async {
      // Given
      when(walletLibWrapper.signMessage(
              privateKey: anyNamed("privateKey"), message: anyNamed('message')))
          .thenAnswer((realInvocation) => Future.value(CommonMocks.signature));

      // When
      expect(
          await dataSource.signMessage(
              privateKey: walletPrivateKey, message: CommonMocks.message),
          CommonMocks.signature);

      // Then
      var capturedSign = verify(walletLibWrapper.signMessage(
              privateKey: captureAnyNamed("privateKey"),
              message: captureAnyNamed('message')))
          .captured;
      expect(capturedSign[0], walletPrivateKey);
      expect(capturedSign[1], CommonMocks.message);
    });

    test(
        "Given a private key and a message, when I call signMessage and an error occured, then I expect an exception to be thrown",
        () async {
      // Given
      when(walletLibWrapper.signMessage(
              privateKey: anyNamed("privateKey"), message: anyNamed('message')))
          .thenAnswer((realInvocation) => Future.error(exception));

      // When
      await expectLater(
          dataSource.signMessage(
              privateKey: walletPrivateKey, message: CommonMocks.message),
          throwsA(exception));

      // Then
      var capturedSign = verify(walletLibWrapper.signMessage(
              privateKey: captureAnyNamed("privateKey"),
              message: captureAnyNamed('message')))
          .captured;
      expect(capturedSign[0], walletPrivateKey);
      expect(capturedSign[1], CommonMocks.message);
    });
  });
}
