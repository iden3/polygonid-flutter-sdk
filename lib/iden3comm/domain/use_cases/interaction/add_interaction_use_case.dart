import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/error_exception.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/interaction/interaction_base_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/repositories/interaction_repository.dart';

class AddInteractionParam {
  final InteractionBaseEntity interaction;
  final String genesisDid;
  final String encryptionKey;

  AddInteractionParam({
    required this.interaction,
    required this.genesisDid,
    required this.encryptionKey,
  });
}

class AddInteractionUseCase
    extends FutureUseCase<AddInteractionParam, InteractionBaseEntity> {
  final InteractionRepository _interactionRepository;
  final StacktraceManager _stacktraceManager;

  AddInteractionUseCase(
    this._interactionRepository,
    this._stacktraceManager,
  );

  @override
  Future<InteractionBaseEntity> execute({
    required AddInteractionParam param,
  }) async {
    try {
      // we add the interaction and return it
      final addedInteraction = await _interactionRepository.addInteraction(
        interaction: param.interaction,
        genesisDid: param.genesisDid,
        encryptionKey: param.encryptionKey,
      );

      logger().i("[AddInteractionUseCase] Interaction: $addedInteraction");
      _stacktraceManager
          .addTrace("[AddInteractionUseCase] Interaction: $addedInteraction");

      return addedInteraction;
    } on PolygonIdSDKException catch (_) {
      rethrow;
    } catch (error) {
      logger().e("[AddInteractionUseCase] Error: $error");
      throw PolygonIdSDKException(
          errorMessage: "Error adding interaction $error");
    }
  }
}
