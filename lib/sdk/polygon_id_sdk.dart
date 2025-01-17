import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/chain_config_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/env_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/repositories/config_repository.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_cases/get_env_use_case.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_cases/get_selected_chain_use_case.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_cases/set_env_use_case.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_cases/set_selected_chain_use_case.dart';
import 'package:polygonid_flutter_sdk/common/kms/kms.dart';
import 'package:polygonid_flutter_sdk/sdk/di/injector.dart';
import 'package:polygonid_flutter_sdk/sdk/error_handling.dart';
import 'package:polygonid_flutter_sdk/sdk/polygonid_flutter_channel.dart';

import 'credential.dart';
import 'iden3comm.dart';
import 'identity.dart';
import 'proof.dart';

class PolygonIsSdkNotInitializedException implements Exception {
  String message;

  PolygonIsSdkNotInitializedException(this.message);
}

class PolygonIdSdk {
  static PolygonIdSdk? _ref;

  static PolygonIdSdk get I {
    if (_ref == null) {
      throw PolygonIsSdkNotInitializedException(
          "The PolygonID SDK has not been initialized,"
          "please call and await PolygonIdSDK.init()");
    }

    return _ref!;
  }

  /// Initializes the PolygonId SDK
  /// Pass [env] to set the environment that contains pushUrl, ipfsUrl, chainConfigs, didMethods
  /// Set [newIdentity] param to use a new identity creation and private key handling mechanisms
  static Future<void> init({
    EnvEntity? env,
    bool newIdentity = false,
  }) async {
    // As [PolygonIdSdk] uses path_provider plugin, we need to ensure the
    // platform is initialized
    WidgetsFlutterBinding.ensureInitialized();

    String? stacktraceEncryptionKey = env?.stacktraceEncryptionKey;
    if (stacktraceEncryptionKey != null &&
        stacktraceEncryptionKey.isNotEmpty &&
        utf8.encode(stacktraceEncryptionKey).length == 32) {
      await Hive.initFlutter();
      await Hive.openBox(
        'stacktrace',
        encryptionCipher: HiveAesCipher(utf8.encode(stacktraceEncryptionKey)),
      );
    }

    // Init injection
    await configureInjection(newIdentity);
    await getItSdk.allReady();

    // Set env
    if (env != null) {
      await getItSdk
          .getAsync<SetEnvUseCase>()
          .then((instance) => instance.execute(param: env));
    }
    if (env?.chainConfigs.entries.isNotEmpty ?? false) {
      await getItSdk.getAsync<SetSelectedChainUseCase>().then(
          (instance) => instance.execute(param: env!.chainConfigs.keys.first));
    }

    // SDK singleton
    _ref = PolygonIdSdk._();
    _ref!.identity = await getItSdk.getAsync<Identity>();
    _ref!.credential = await getItSdk.getAsync<Credential>();
    _ref!.proof = await getItSdk.getAsync<Proof>();
    _ref!.iden3comm = await getItSdk.getAsync<Iden3comm>();
    _ref!.errorHandling = getItSdk.get<ErrorHandling>();
    _ref!.kms = getItSdk.get<KMS>();

    // Channel
    getItSdk<PolygonIdFlutterChannel>();

    // Logging
    Domain.logger = getItSdk<PolygonIdSdkLogger>();
  }

  late Identity identity;
  late Credential credential;
  late Proof proof;
  late Iden3comm iden3comm;
  late ErrorHandling errorHandling;
  late KMS kms;

  PolygonIdSdk._();

  Future<void> setEnv({required EnvEntity env}) {
    return getItSdk
        .getAsync<SetEnvUseCase>()
        .then((instance) => instance.execute(param: env));
  }

  Future<EnvEntity> getEnv() {
    return getItSdk
        .getAsync<GetEnvUseCase>()
        .then((instance) => instance.execute());
  }

  Future<ChainConfigEntity> getSelectedChain() {
    return getItSdk
        .getAsync<GetSelectedChainUseCase>()
        .then((instance) => instance.execute());
  }

  Future<String?> getSelectedChainId() {
    return getItSdk
        .getAsync<ConfigRepository>()
        .then((instance) => instance.getSelectedChainId());
  }

  Future<void> setSelectedChain({required String chainConfigId}) {
    return getItSdk
        .getAsync<SetSelectedChainUseCase>()
        .then((instance) => instance.execute(param: chainConfigId));
  }

  Future<void> switchLog({required bool enabled}) async {
    Domain.logEnabled = enabled;
  }
}
