import 'package:polygonid_flutter_sdk/common/domain/domain_constants.dart';
import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/did_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/identity_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/private_identity_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/exceptions/identity_exceptions.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_did_identifier_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_did_use_case.dart';

class GetIdentityParam {
  final String genesisDid;
  final String? privateKey;
  final List<String>? publicKey;

  GetIdentityParam({
    required this.genesisDid,
    this.privateKey,
    this.publicKey,
  });
}

class GetIdentityUseCase
    extends FutureUseCase<GetIdentityParam, IdentityEntity> {
  final IdentityRepository _identityRepository;
  final GetDidUseCase _getDidUseCase;
  final GetDidIdentifierUseCase _getDidIdentifierUseCase;
  final StacktraceManager _stacktraceManager;

  GetIdentityUseCase(
    this._identityRepository,
    this._getDidUseCase,
    this._getDidIdentifierUseCase,
    this._stacktraceManager,
  );

  @override
  Future<IdentityEntity> execute({
    required GetIdentityParam param,
  }) async {
    final bjjPrivateKey = param.privateKey;

    try {
      // Return [IdentityEntity] with no profiles and no checks
      if (bjjPrivateKey == null) {
        final identity = await _identityRepository.getIdentity(
          genesisDid: param.genesisDid,
        );
        logger().i("[GetIdentityUseCase] Identity: $identity");
        _stacktraceManager.addTrace(
            "[GetIdentityUseCase] Identity DID: ${identity.did}, public key: ${identity.publicKey}, profiles: ${identity.profiles}");

        return identity;
      }

      // Here we're checking genesis DID against DID generated from private key

      // Check if the did from param matches the did from the privateKey
      DidEntity did = await _getDidUseCase.execute(param: param.genesisDid);

      final List<String> publicKey;
      final pbKey = param.publicKey;
      if (pbKey != null) {
        publicKey = pbKey;
      } else {
        publicKey = await _identityRepository.getPublicKeys(
          bjjPrivateKey: bjjPrivateKey,
        );
      }

      String genesisDid = await _getDidIdentifierUseCase.execute(
        param: GetDidIdentifierParam(
          bjjPublicKey: publicKey,
          blockchain: did.blockchain,
          network: did.network,
          method: did.method,
          profileNonce: GENESIS_PROFILE_NONCE,
        ),
      );

      if (did.did != genesisDid) {
        throw InvalidPrivateKeyException(
          privateKey: bjjPrivateKey,
          errorMessage:
              "the did from the private key does not match the genesis did from the param",
        );
      }

      final publicIdentity = await _identityRepository.getIdentity(
        genesisDid: genesisDid,
      );

      // Get the [PrivateIdentityEntity]
      final identity = PrivateIdentityEntity(
        did: param.genesisDid,
        publicKey: publicIdentity.publicKey,
        profiles: publicIdentity.profiles,
        privateKey: bjjPrivateKey,
      );

      logger().i("[GetIdentityUseCase] Identity: $identity");
      _stacktraceManager.addTrace(
          "[GetIdentityUseCase] Identity DID: ${identity.did}, public key: ${identity.publicKey}, profiles: ${identity.profiles}");

      return identity;
    } catch (error) {
      logger().e("[GetIdentityUseCase] Error: $error");
      _stacktraceManager.addTrace("[GetIdentityUseCase] Error: $error");
      _stacktraceManager.addError("[GetIdentityUseCase] Error: $error");

      rethrow;
    }
  }
}
