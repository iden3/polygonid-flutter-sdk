import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/repositories/interaction_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/get_identity_use_case.dart';

class RemoveInteractionsParam {
  final String? genesisDid;
  final String? encryptionKey;
  final List<String> ids;

  RemoveInteractionsParam({
    this.genesisDid,
    this.encryptionKey,
    required this.ids,
  });
}

class RemoveInteractionsUseCase
    extends FutureUseCase<RemoveInteractionsParam, void> {
  final InteractionRepository _interactionRepository;
  final GetIdentityUseCase _getIdentityUseCase;

  RemoveInteractionsUseCase(
    this._interactionRepository,
    this._getIdentityUseCase,
  );

  @override
  Future<void> execute({required RemoveInteractionsParam param}) async {
    // we check if identity exists
    if (param.genesisDid != null && param.encryptionKey != null) {
      await _getIdentityUseCase.execute(
        param: GetIdentityParam(
          genesisDid: param.genesisDid!,
          privateKey: null,
        ),
      );
    }
    return _interactionRepository
        .removeInteractions(
          ids: param.ids,
          genesisDid: param.genesisDid,
          encryptionKey: param.encryptionKey,
        )
        .then((_) => logger().i(
            "[RemoveInteractionUseCase] Interactions with ids ${param.ids} have been removed"))
        .catchError((error) {
      logger().e("[RemoveInteractionUseCase] Error: $error");
      throw error;
    });
  }
}
