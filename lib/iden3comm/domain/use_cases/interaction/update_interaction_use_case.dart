import 'package:polygonid_flutter_sdk/common/domain/error_exception.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/interaction/interaction_base_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/interaction/interaction_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/repositories/interaction_repository.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/interaction/add_interaction_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/get_identity_use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/profile/check_profile_validity_use_case.dart';

class UpdateInteractionParam {
  final String? genesisDid;
  final BigInt? profileNonce;
  final String? encryptionKey;
  final String id;
  final InteractionState? state;

  UpdateInteractionParam({
    this.genesisDid,
    this.profileNonce,
    this.encryptionKey,
    required this.id,
    this.state,
  });
}

class UpdateInteractionUseCase
    extends FutureUseCase<UpdateInteractionParam, InteractionBaseEntity> {
  final InteractionRepository _interactionRepository;
  final CheckProfileValidityUseCase _checkProfileValidityUseCase;
  final GetIdentityUseCase _getIdentityUseCase;
  final AddInteractionUseCase _addInteractionUseCase;

  UpdateInteractionUseCase(
    this._interactionRepository,
    this._checkProfileValidityUseCase,
    this._getIdentityUseCase,
    this._addInteractionUseCase,
  );

  @override
  Future<InteractionBaseEntity> execute({
    required UpdateInteractionParam param,
  }) async {
    final genesisDid = param.genesisDid;
    final profileNonce = param.profileNonce;
    final encryptionKey = param.encryptionKey;

    // we check if profile is valid and identity exists
    if (genesisDid != null && profileNonce != null && encryptionKey != null) {
      await _checkProfileValidityUseCase.execute(
        param: CheckProfileValidityParam(profileNonce: profileNonce),
      );
      await _getIdentityUseCase.execute(
        param: GetIdentityParam(genesisDid: genesisDid, privateKey: null),
      );

      InteractionBaseEntity interactionToBeUpdated;
      try {
        // search if interaction is in base
        interactionToBeUpdated =
            await _interactionRepository.getInteraction(id: param.id);
        await _interactionRepository.removeInteractions(ids: [param.id]);
      } catch (e) {
        interactionToBeUpdated = await _interactionRepository.getInteraction(
          id: param.id,
          genesisDid: param.genesisDid,
          encryptionKey: param.encryptionKey,
        );
      }

      InteractionEntity updatedInteraction = InteractionEntity(
        id: interactionToBeUpdated.id,
        from: interactionToBeUpdated.from,
        genesisDid: param.genesisDid!,
        profileNonce: param.profileNonce!,
        type: interactionToBeUpdated.type,
        timestamp: interactionToBeUpdated.timestamp,
        message: interactionToBeUpdated.message,
        state: param.state ?? interactionToBeUpdated.state,
        to: interactionToBeUpdated.to,
      );
      return _addInteractionUseCase.execute(
        param: AddInteractionParam(
          genesisDid: genesisDid,
          encryptionKey: encryptionKey,
          interaction: updatedInteraction,
        ),
      );
    } else {
      throw PolygonIdSDKException(
        errorMessage:
            "GenesisDid and PrivateKey are required to add an interaction",
      );
    }
  }
}
