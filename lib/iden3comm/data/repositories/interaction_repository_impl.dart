import 'package:polygonid_flutter_sdk/common/data/data_sources/mappers/filters_mapper.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/filter_entity.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/data_sources/secure_storage_interaction_data_source.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/data_sources/storage_interaction_data_source.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/mappers/interaction_mapper.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/interaction/interaction_base_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/exceptions/interaction_exception.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/repositories/interaction_repository.dart';
import 'package:sembast/sembast.dart';

class InteractionRepositoryImpl implements InteractionRepository {
  final SecureStorageInteractionDataSource _secureStorageInteractionDataSource;
  final StorageInteractionDataSource _storageInteractionDataSource;
  final InteractionMapper _interactionMapper;
  final FiltersMapper _filtersMapper;
  final StacktraceManager _stacktraceManager;

  InteractionRepositoryImpl(
    this._secureStorageInteractionDataSource,
    this._storageInteractionDataSource,
    this._interactionMapper,
    this._filtersMapper,
    this._stacktraceManager,
  );

  @override
  Future<InteractionBaseEntity> addInteraction({
    required InteractionBaseEntity interaction,
    String? genesisDid,
    String? encryptionKey,
  }) {
    if (genesisDid != null && encryptionKey != null) {
      return _secureStorageInteractionDataSource.storeInteractions(
        interactions: [_interactionMapper.mapTo(interaction)],
        did: genesisDid,
        encryptionKey: encryptionKey,
      ).then((interactionDTOs) =>
          _interactionMapper.mapFrom(interactionDTOs.first));
    } else {
      return _storageInteractionDataSource.storeInteractions(
        interactions: [_interactionMapper.mapTo(interaction)],
      ).then((interactionDTOs) =>
          _interactionMapper.mapFrom(interactionDTOs.first));
    }
  }

  @override
  Future<List<InteractionBaseEntity>> getInteractions(
      {List<FilterEntity>? filters,
      String? genesisDid,
      String? encryptionKey}) {
    if (genesisDid != null && encryptionKey != null) {
      return _secureStorageInteractionDataSource
          .getInteractions(
              filter: filters == null ? null : _filtersMapper.mapTo(filters),
              did: genesisDid,
              encryptionKey: encryptionKey)
          .then((interactions) => interactions
              .map((interaction) => _interactionMapper.mapFrom(interaction))
              .toList());
    } else {
      return _storageInteractionDataSource
          .getInteractions(
              filter: filters == null ? null : _filtersMapper.mapTo(filters))
          .then((interactions) => interactions
              .map((interaction) => _interactionMapper.mapFrom(interaction))
              .toList());
    }
  }

  @override
  Future<InteractionBaseEntity> getInteraction({
    required String id,
    String? genesisDid,
    String? encryptionKey,
  }) async {
    if (genesisDid != null && encryptionKey != null) {
      List<Map<String, dynamic>> interactions =
          await _secureStorageInteractionDataSource.getInteractions(
        filter: Filter.equals('id', id),
        did: genesisDid,
        encryptionKey: encryptionKey,
      );
      if (interactions.isEmpty) {
        _stacktraceManager.addError("Interaction not found");
        throw InteractionNotFoundException(
          id: id,
          errorMessage: "Interaction not found",
        );
      } else {
        Map<String, dynamic> interaction = interactions.first;
        InteractionBaseEntity interactionBaseEntity =
            _interactionMapper.mapFrom(interaction);
        return interactionBaseEntity;
      }
    } else {
      return _storageInteractionDataSource
          .getInteractions(filter: Filter.equals('id', id))
          .then((interactions) => interactions.isEmpty
              ? throw InteractionNotFoundException(
                  id: id, errorMessage: "Interaction not found")
              : _interactionMapper.mapFrom(interactions.first));
    }
  }

  @override
  Future<void> removeInteractions({
    required List<String> ids,
    String? genesisDid,
    String? encryptionKey,
  }) {
    if (genesisDid != null && encryptionKey != null) {
      return _secureStorageInteractionDataSource.removeInteractions(
        ids: ids,
        did: genesisDid,
        encryptionKey: encryptionKey,
      );
    } else {
      return _storageInteractionDataSource.removeInteractions(ids: ids);
    }
  }
}
