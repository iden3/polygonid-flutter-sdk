import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/credential/libs/polygonidcore/pidcore_credential.dart';
import 'package:polygonid_flutter_sdk/identity/libs/polygonidcore/pidcore_identity.dart';
import 'package:polygonid_flutter_sdk/proof/libs/polygonidcore/pidcore_proof.dart';

import 'polygonidcore_mocks.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final stacktraceManager = StacktraceManager();

  group('Test polygonId core lib identity functions', () {
    final pidCoreIdentity = PolygonIdCoreIdentity(stacktraceManager);

    testWidgets('PolygonIdCoreIdentity calculate genesis Id',
        (WidgetTester tester) async {
      expect(
        pidCoreIdentity.calculateGenesisId(
          PolygonIdCoreMocks.calculateGenesisIdInputJson,
          PolygonIdCoreMocks.environmentConfigJson,
        ),
        equals(PolygonIdCoreMocks.calculateGenesisIdOutputJson),
      );
    });

    testWidgets('PolygonIdCoreIdentity calculate profile Id',
        (WidgetTester tester) async {
      expect(
        pidCoreIdentity.calculateProfileId(
          PolygonIdCoreMocks.calculateProfileIdInputJson,
        ),
        equals(PolygonIdCoreMocks.calculateProfileIdOutputJson),
      );
    });

    testWidgets('PolygonIdCoreIdentity convert id to big int',
        (WidgetTester tester) async {
      expect(
        pidCoreIdentity.convertIdToBigInt(
          jsonEncode(PolygonIdCoreMocks.idToIntInput),
        ),
        equals(jsonEncode(PolygonIdCoreMocks.idToIntOutput)),
      );
    });
  });

  group('Test polygonId core lib credential functions', () {
    final pidCoreCredential = PolygonIdCoreCredential(stacktraceManager);

    testWidgets('PolygonIdCoreIdentity create claim',
        (WidgetTester tester) async {
      expect(
        pidCoreCredential.createClaim(PolygonIdCoreMocks.createClaimInputJson),
        equals(PolygonIdCoreMocks.createClaimOutput),
      );
    });

    testWidgets('PolygonIdCoreIdentity create claim all fields 1',
        (WidgetTester tester) async {
      expect(
        pidCoreCredential.createClaim(
          PolygonIdCoreMocks.createClaimAllFields1InputJson,
        ),
        equals(PolygonIdCoreMocks.createClaimAllFields1Output),
      );
    });

    testWidgets('PolygonIdCoreIdentity create claim all fields 2',
        (WidgetTester tester) async {
      expect(
        pidCoreCredential.createClaim(
          PolygonIdCoreMocks.createClaimAllFields2InputJson,
        ),
        equals(PolygonIdCoreMocks.createClaimAllFields2Output),
      );
    });
  });
}
