import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/private_identity_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/add_identity_use_case.dart';

import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';

class AddNewIdentityUseCase
    extends FutureUseCase<String?, PrivateIdentityEntity> {
  final IdentityRepository _identityRepository;
  final AddIdentityUseCase _addIdentityUseCase;
  final StacktraceManager _stacktraceManager;

  AddNewIdentityUseCase(
    this._identityRepository,
    this._addIdentityUseCase,
    this._stacktraceManager,
  );

  @override
  Future<PrivateIdentityEntity> execute({String? param}) {
    return Future(() async {
      final privateKey = await _identityRepository.getPrivateKey(secret: param);
      final publicKeys =
          await _identityRepository.getPublicKeys(bjjPrivateKey: privateKey);
      final identity = await _addIdentityUseCase.execute(
        param: AddIdentityParam(
          bjjPublicKey: publicKeys,
          encryptionKey: privateKey,
        ),
      );

      logger().i(
          "[AddNewIdentityUseCase] New Identity created and saved with did: ${identity.did}, for key $param");
      _stacktraceManager.addTrace(
          "[AddNewIdentityUseCase] New Identity created and saved with did: ${identity.did}, for key $param");

      return PrivateIdentityEntity(
        did: identity.did,
        publicKey: identity.publicKey,
        profiles: identity.profiles,
        privateKey: privateKey,
      );
    }).catchError((error) {
      logger().e("[AddNewIdentityUseCase] Error: $error");
      _stacktraceManager.addTrace("[AddNewIdentityUseCase] Error: $error");
      _stacktraceManager.addError("[AddNewIdentityUseCase] Error: $error");

      throw error;
    });
  }
}
