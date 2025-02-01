import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/repositories/did_profile_info_repository.dart';

class RemoveDidProfileInfoParam {
  final String genesisDid;
  final String interactedWithDid;
  final String encryptionKey;

  RemoveDidProfileInfoParam({
    required this.genesisDid,
    required this.interactedWithDid,
    required this.encryptionKey,
  });
}

class RemoveDidProfileInfoUseCase
    extends FutureUseCase<RemoveDidProfileInfoParam, void> {
  final DidProfileInfoRepository _didProfileInfoRepository;

  RemoveDidProfileInfoUseCase(
    this._didProfileInfoRepository,
  );

  @override
  Future<void> execute({required RemoveDidProfileInfoParam param}) {
    return _didProfileInfoRepository.removeDidProfileInfo(
      interactedDid: param.interactedWithDid,
      genesisDid: param.genesisDid,
      encryptionKey: param.encryptionKey,
    );
  }
}
