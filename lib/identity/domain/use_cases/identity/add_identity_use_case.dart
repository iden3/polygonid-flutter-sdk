import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/identity_entity.dart';

import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/exceptions/identity_exceptions.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/smt/create_identity_state_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/create_identity_use_case.dart';

class AddIdentityParam {
  final List<String> bjjPublicKey;
  final String encryptionKey;
  final List<BigInt> profiles;
  final String? genesisDid;

  AddIdentityParam({
    required this.bjjPublicKey,
    required this.encryptionKey,
    this.profiles = const [],
    this.genesisDid,
  });
}

class AddIdentityUseCase
    extends FutureUseCase<AddIdentityParam, IdentityEntity> {
  final IdentityRepository _identityRepository;
  final CreateIdentityUseCase _createIdentityUseCase;
  final CreateIdentityStateUseCase _createIdentityStateUseCase;
  final StacktraceManager _stacktraceManager;

  AddIdentityUseCase(
    this._identityRepository,
    this._createIdentityUseCase,
    this._createIdentityStateUseCase,
    this._stacktraceManager,
  );

  @override
  Future<IdentityEntity> execute({
    required AddIdentityParam param,
  }) async {
    // Create the [IdentityEntity]
    IdentityEntity identity = await _createIdentityUseCase.execute(
      param: CreateIdentityParam(
        bjjPublicKey: param.bjjPublicKey,
        profiles: param.profiles,
      ),
    );
    try {
      // Check if identity is already stored (already added)
      await _identityRepository.getIdentity(genesisDid: identity.did);

      // If there is already one, we throw
      throw IdentityAlreadyExistsException(
        did: identity.did,
        errorMessage: "Identity already exists with did: ${identity.did}",
      );
    } on UnknownIdentityException {
      // If identity doesn't exist, we save it
      await _identityRepository.storeIdentity(identity: identity);

      // create identity state for each profile did
      for (String profileDid in identity.profiles.values) {
        await _createIdentityStateUseCase.execute(
          param: CreateIdentityStateParam(
            did: profileDid,
            bjjPublicKey: param.bjjPublicKey,
            encryptionKey: param.encryptionKey,
          ),
        );
      }
    } catch (error) {
      logger().e("[AddIdentityUseCase] Error: $error");
      _stacktraceManager.addTrace("[AddIdentityUseCase] Error: $error");
      _stacktraceManager.addError("[AddIdentityUseCase] Error: $error");
      rethrow;
    }

    logger().i(
        "[AddIdentityUseCase] Identity created and saved with did: ${identity.did}, for key ${param.bjjPublicKey}");
    _stacktraceManager.addTrace(
        "[AddIdentityUseCase] Identity created and saved with did: ${identity.did}, for key ${param.bjjPublicKey}");

    return identity;
  }
}
