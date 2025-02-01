import 'package:flutter/foundation.dart';
import 'package:polygonid_flutter_sdk/constants.dart';
import 'package:polygonid_flutter_sdk/sdk/di/injector.dart';
import 'package:sembast/sembast.dart';

abstract class SecureIdentityStorageDataSource {
  @protected
  Future<Database> getDatabase({
    required String did,
    required String encryptionKey,
  }) {
    return getItSdk.getAsync<Database>(
      instanceName: identityDatabaseName,
      param1: did,
      param2: encryptionKey,
    );
  }
}
