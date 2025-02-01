import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/update_identity_use_case.dart';

class RestoreProfilesParam {
  final String genesisDid;
  final String encryptionKey;

  RestoreProfilesParam({
    required this.genesisDid,
    required this.encryptionKey,
  });
}

class RestoreProfilesUseCase extends FutureUseCase<RestoreProfilesParam, void> {
  final IdentityRepository _identityRepository;
  final UpdateIdentityUseCase _updateIdentityUseCase;

  RestoreProfilesUseCase(
    this._identityRepository,
    this._updateIdentityUseCase,
  );

  @override
  Future<void> execute({required RestoreProfilesParam param}) async {
    final restoredProfiles = await _identityRepository.getProfiles(
      did: param.genesisDid,
      encryptionKey: param.encryptionKey,
    );

    await _updateIdentityUseCase.execute(
        param: UpdateIdentityParam(
      genesisDid: param.genesisDid,
      profiles: restoredProfiles,
      encryptionKey: param.encryptionKey,
    ));
  }
}
