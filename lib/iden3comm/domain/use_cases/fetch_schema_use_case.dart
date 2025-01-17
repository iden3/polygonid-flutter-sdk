import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/repositories/iden3comm_credential_repository.dart';

class FetchSchemaUseCase extends FutureUseCase<String, Map<String, dynamic>> {
  final Iden3commCredentialRepository _iden3commCredentialRepository;

  FetchSchemaUseCase(this._iden3commCredentialRepository);

  @override
  Future<Map<String, dynamic>> execute({required String param}) {
    return _iden3commCredentialRepository.fetchSchema(url: param);
  }
}
