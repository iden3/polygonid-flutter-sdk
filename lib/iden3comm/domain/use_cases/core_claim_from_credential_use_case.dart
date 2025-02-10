import 'dart:convert';

import 'package:polygonid_flutter_sdk/common/domain/entities/env_config_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/credential/domain/repositories/credential_repository.dart';

class CoreClaimFromCredentialParam {
  final ClaimEntity credential;
  final EnvConfigEntity? config;

  CoreClaimFromCredentialParam({
    required this.credential,
    this.config,
  });
}

class CoreClaimFromCredentialUseCase
    extends FutureUseCase<CoreClaimFromCredentialParam, String> {
  final CredentialRepository _credentialRepository;

  CoreClaimFromCredentialUseCase(this._credentialRepository);

  @override
  Future<String> execute({
    required CoreClaimFromCredentialParam param,
  }) {
    String? config;
    if (param.config != null) {
      config = jsonEncode(param.config!.toJson());
    }

    param.credential.info.remove('id');
    String credential = jsonEncode(
      {
        "w3cCredential": param.credential.info,
        "coreClaimOptions": {
          "revNonce": 954548273, //TODO: get from somewhere
          "version": 0,
          "merklizedRootPosition": "index",
        },
      },
    );

    return _credentialRepository.coreClaimFromCredential(
      credential: credential,
      config: config,
    );
  }
}
