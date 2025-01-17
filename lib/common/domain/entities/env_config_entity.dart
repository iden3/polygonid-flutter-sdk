import 'package:polygonid_flutter_sdk/common/domain/entities/chain_config_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/did_method_entity.dart';

/// https://github.com/0xPolygonID/c-polygonid?tab=readme-ov-file#configuration
class EnvConfigEntity {
  final String ipfsNodeUrl;
  final Map<String, ChainConfigEntity> chainConfigs;
  final List<DidMethodEntity> didMethods;
  final String? cacheDir;

  EnvConfigEntity({
    required this.ipfsNodeUrl,
    this.chainConfigs = const {},
    this.didMethods = const [],
    this.cacheDir,
  });

  factory EnvConfigEntity.fromJson(Map<String, dynamic> json) {
    return EnvConfigEntity(
      ipfsNodeUrl: json['ipfsNodeUrl'],
      chainConfigs: (json['chainConfigs'] as Map<dynamic, dynamic>).map(
          (key, value) => MapEntry(key, ChainConfigEntity.fromJson(value))),
      didMethods: (json['didMethods'] as List<dynamic>)
          .map((value) => DidMethodEntity.fromJson(value))
          .toList(),
      cacheDir: json['cacheDir'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ipfsNodeUrl': ipfsNodeUrl,
      'chainConfigs':
          chainConfigs.map((key, value) => MapEntry(key, value.toJson())),
      'didMethods': didMethods.map((e) => e.toJson()).toList(),
      'cacheDir': cacheDir,
    };
  }
}
