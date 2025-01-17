import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/credential/domain/repositories/credential_repository.dart';

class GetCredentialByPartialIdParam {
  final String partialId;
  final String genesisDid;
  final String encryptionKey;

  GetCredentialByPartialIdParam({
    required this.partialId,
    required this.genesisDid,
    required this.encryptionKey,
  });
}

class GetCredentialByPartialIdUseCase
    extends FutureUseCase<GetCredentialByPartialIdParam, ClaimEntity> {
  final CredentialRepository _credentialRepository;

  GetCredentialByPartialIdUseCase(
    this._credentialRepository,
  );

  @override
  Future<ClaimEntity> execute({
    required GetCredentialByPartialIdParam param,
  }) async {
    return _credentialRepository.getCredentialByPartialId(
      partialId: param.partialId,
      genesisDid: param.genesisDid,
      encryptionKey: param.encryptionKey,
    );
  }
}
