import 'package:polygonid_flutter_sdk/common/domain/domain_constants.dart';
import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/filter_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/error_exception.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/interaction/interaction_base_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/interaction/interaction_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/exceptions/interaction_exception.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/repositories/interaction_repository.dart';

class GetInteractionsParam {
  final String? genesisDid;
  final BigInt? profileNonce;
  final String? privateKey;
  final List<InteractionType>? types;
  final List<InteractionState>? states;
  final List<FilterEntity>? filters;

  GetInteractionsParam({
    this.genesisDid,
    this.profileNonce,
    this.privateKey,
    this.types,
    this.states,
    this.filters,
  });
}

class GetInteractionsUseCase
    extends FutureUseCase<GetInteractionsParam, List<InteractionBaseEntity>> {
  final InteractionRepository _interactionRepository;
  final StacktraceManager _stacktraceManager;

  GetInteractionsUseCase(
    this._interactionRepository,
    this._stacktraceManager,
  );

  @override
  Future<List<InteractionBaseEntity>> execute({
    required GetInteractionsParam param,
  }) async {
    try {
      List<InteractionBaseEntity> interactions =
          await _interactionRepository.getInteractions(
        filters: param.filters,
        genesisDid: param.genesisDid,
        encryptionKey: param.privateKey,
      );

      /// Shortcut to filter by type
      if (param.types != null) {
        interactions = interactions
            .where((interaction) => param.types!.contains(interaction.type))
            .toList();
      }

      /// Shortcut to filter by state
      if (param.states != null) {
        interactions = interactions
            .where((interaction) => param.states!.contains(interaction.state))
            .toList();
      }

      /// Shortcut to filter by profile
      if (param.profileNonce != null &&
          param.profileNonce! > GENESIS_PROFILE_NONCE) {
        interactions = interactions
            .where((interaction) =>
                param.profileNonce ==
                (interaction as InteractionEntity).profileNonce)
            .toList();
      }

      logger().i("[GetInteractionsUseCase] Interactions: $interactions");

      return interactions;
    } on PolygonIdSDKException catch (_) {
      rethrow;
    } catch (error) {
      logger().e("[GetInteractionsUseCase] Error: $error");
      _stacktraceManager.addTrace("[GetInteractionsUseCase] Error: $error");
      throw InteractionsNotFoundException(
        errorMessage: "Error getting interactions $error",
      );
    }
  }
}
