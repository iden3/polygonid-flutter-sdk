import 'dart:convert';

import 'package:polygonid_flutter_sdk/common/domain/entities/env_config_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/credential/domain/repositories/credential_repository.dart';

class CacheCredentialParam {
  final ClaimEntity credential;
  final EnvConfigEntity? config;

  CacheCredentialParam({
    required this.credential,
    this.config,
  });
}

class CacheCredentialUseCase extends FutureUseCase<CacheCredentialParam, bool> {
  final CredentialRepository _credentialRepository;

  CacheCredentialUseCase(
    this._credentialRepository,
  );

  @override
  Future<bool> execute({
    required CacheCredentialParam param,
  }) {
    String? config;
    if (param.config != null) {
      config = jsonEncode(param.config!.toJson());
    }

    String credential = jsonEncode(
      {
        "verifiableCredentials": param.credential.info,
      },
    );

    return _credentialRepository.cacheCredential(
      credential: credential,
      config: config,
    );
  }
}
