import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/env_config_entity.dart';
import 'package:polygonid_flutter_sdk/common/libs/polygonidcore/pidcore_base.dart';
import 'package:polygonid_flutter_sdk/common/utils/hex_utils.dart';
import 'package:polygonid_flutter_sdk/identity/libs/bjj/bjj.dart';

import 'polygonidcore_mocks.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  PolygonIdCore.setEnvConfig(EnvConfigEntity(ipfsNodeUrl: ""));

  final lib = BabyjubjubLib();

  group('Test point compress/uncompress', () {
    const pointX =
        "1213174356443492223913701748605807399689671830803048423391713277352597320264";
    const pointY =
        "7302787176091879756002280810960328852823951595761559038108460949327195887723";

    const compressedPoint =
        "6B58E72B1BB6DD8C2B20CB62E90F1AE7F7F054C059B962382643721B273B2510";

    testWidgets('Compress point', (WidgetTester tester) async {
      final compressedPoint = lib.compressPoint(pointX, pointY);

      expect(
        compressedPoint,
        equals(compressedPoint),
      );
    });

    testWidgets('Uncompress point', (WidgetTester tester) async {
      final uncompressedPoint = lib.uncompressPoint(compressedPoint);

      expect(uncompressedPoint, isNotNull);
      expect(uncompressedPoint[0], equals(pointX));
      expect(uncompressedPoint[1], equals(pointY));
    });
  });

  group("Message sign and signature verify", () {
    const privateKey =
        "85612f904a52e7eb2e0ab742ab1ae3de36561497fea24f1fc4619a5efc73eae8";
    const message =
        "6841496992415663132898117430955063618911128754688221768758387076131201387307";

    const signature =
        "740942df0bffc2f386d9d7e4e30be0981d54a2c16af82e85af1978459b489eafe0ab5d8e12f724f93998827f02a1624705d0ea22f92fd769901a1df7bfc87401";

    testWidgets("Sign", (WidgetTester tester) async {
      final signature = lib.signPoseidon(
        privateKey,
        message,
      );

      expect(signature, equals(signature));
    });

    testWidgets("Verify signature", (WidgetTester tester) async {
      final publicKey = lib.prv2pub(privateKey);

      final valid = lib.verifyPoseidon(
        publicKey,
        signature,
        message,
      );

      expect(valid, isTrue);
    });
  });

  group("Private key to public key test", () {
    const privateKey =
        "85612f904a52e7eb2e0ab742ab1ae3de36561497fea24f1fc4619a5efc73eae8";

    const expectedX =
        "10642469561299443157177646279099633166785806044568900244804593097533061888748";
    const expectedY =
        "7588418921868074418607355872196117318956729766890665605182116638798290735907";

    testWidgets("Private key to public", (WidgetTester tester) async {
      final publicKeyHex = lib.prv2pub(privateKey);

      final points = lib.uncompressPoint(publicKeyHex);

      expect(points[0], equals(expectedX));
      expect(points[1], equals(expectedY));
    });
  });
}
