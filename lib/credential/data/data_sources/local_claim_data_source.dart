import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../../constants.dart';
import 'lib_pidcore_credential_data_source.dart';

@singleton
class LocalClaimDataSource {
  LibPolygonIdCoreCredentialDataSource _libPolygonIdCoreCredentialDataSource;

  final _cache = <String, List<String>>{};

  LocalClaimDataSource(this._libPolygonIdCoreCredentialDataSource);

  Future<List<String>> getAuthClaim({
    required List<String> publicKey,
    String? authClaimNonce,
  }) {
    final nonce = authClaimNonce ?? DEFAULT_AUTH_CLAIM_NONCE;

    final cacheKey = _cacheKey(publicKey.toString(), nonce);
    if (_cache.containsKey(cacheKey)) {
      return Future.value(_cache[cacheKey]!);
    }

    String authClaimSchema = AUTH_CLAIM_SCHEMA;
    String authClaim = _libPolygonIdCoreCredentialDataSource.issueClaim(
      schema: authClaimSchema,
      nonce: nonce,
      publicKey: publicKey,
    );
    List<String> children = List.from(jsonDecode(authClaim));

    _cache[cacheKey] = children;

    return Future.value(children);
  }

  Future<String> coreClaimFromCredential({
    required String credential,
    String? config,
  }) async {
    String coreClaim =
        _libPolygonIdCoreCredentialDataSource.coreClaimFromCredential(
      credential: credential,
      config: config,
    );
    return Future.value(coreClaim);
  }
}

String _cacheKey(String publicKey, String nonce) => publicKey + "_" + nonce;
