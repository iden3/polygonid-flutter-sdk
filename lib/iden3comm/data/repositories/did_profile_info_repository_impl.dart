import 'package:polygonid_flutter_sdk/common/data/data_sources/mappers/filters_mapper.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/filter_entity.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/data_sources/secure_storage_did_profile_info_data_source.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/repositories/did_profile_info_repository.dart';

class DidProfileInfoRepositoryImpl implements DidProfileInfoRepository {
  final SecureStorageDidProfileInfoDataSource
      _secureStorageDidProfileInfoDataSource;
  final FiltersMapper _filtersMapper;

  DidProfileInfoRepositoryImpl(
    this._secureStorageDidProfileInfoDataSource,
    this._filtersMapper,
  );

  @override
  Future<void> addDidProfileInfo({
    required Map<String, dynamic> didProfileInfo,
    required String interactedDid,
    required String genesisDid,
    required String encryptionKey,
  }) {
    return _secureStorageDidProfileInfoDataSource.storeDidProfileInfo(
      didProfileInfo: didProfileInfo,
      interactedDid: interactedDid,
      did: genesisDid,
      encryptionKey: encryptionKey,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getDidProfileInfoList({
    List<FilterEntity>? filters,
    required String genesisDid,
    required String encryptionKey,
  }) {
    return _secureStorageDidProfileInfoDataSource.getDidProfileInfos(
        filter: filters == null ? null : _filtersMapper.mapTo(filters),
        did: genesisDid,
        encryptionKey: encryptionKey);
  }

  @override
  Future<void> removeDidProfileInfo({
    required String interactedDid,
    required String genesisDid,
    required String encryptionKey,
  }) {
    return _secureStorageDidProfileInfoDataSource.removeDidProfileInfo(
      interactedDid: interactedDid,
      did: genesisDid,
      encryptionKey: encryptionKey,
    );
  }

  @override
  Future<Map<String, dynamic>> getDidProfileInfoByInteractedWithDid({
    required String interactedWithDid,
    required String genesisDid,
    required String encryptionKey,
  }) {
    return _secureStorageDidProfileInfoDataSource
        .getDidProfileInfosByInteractedWithDid(
      did: genesisDid,
      encryptionKey: encryptionKey,
      interactedWithDid: interactedWithDid,
    );
  }
}
