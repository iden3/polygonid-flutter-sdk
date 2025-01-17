import 'package:injectable/injectable.dart';
import 'package:polygonid_flutter_sdk/common/data/data_sources/storage_key_value_data_source.dart';
import 'package:polygonid_flutter_sdk/common/data/exceptions/env_exceptions.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/env_entity.dart';

@singleton
class ConfigRepository {
  final StorageKeyValueDataSource _storageKeyValueDataSource;

  ConfigRepository(
    this._storageKeyValueDataSource,
  );

  EnvEntity? _envCache;

  @override
  Future<EnvEntity> getEnv() {
    if (_envCache != null) {
      return Future.value(_envCache!);
    }

    return _storageKeyValueDataSource.get(key: "env").then((value) {
      if (value == null) {
        return Future.error(EnvNotSetException());
      }

      return EnvEntity.fromJson(value);
    });
  }

  @override
  Future<void> setEnv({required EnvEntity env}) {
    _envCache = env;
    return _storageKeyValueDataSource.store(key: "env", value: env.toJson());
  }

  String? _selectedChainIdCache;

  @override
  Future<String?> getSelectedChainId() {
    if (_selectedChainIdCache != null) {
      return Future.value(_selectedChainIdCache);
    }

    return _storageKeyValueDataSource.get(key: "selected_chain").then((value) {
      return value;
    });
  }

  @override
  Future<void> setSelectedChainId({required String chainId}) {
    _selectedChainIdCache = chainId;
    return _storageKeyValueDataSource.store(
        key: "selected_chain", value: chainId);
  }
}
