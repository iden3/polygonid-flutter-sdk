import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/env_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/repositories/config_repository.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/common/libs/polygonidcore/pidcore_base.dart';

class SetEnvUseCase extends FutureUseCase<EnvEntity, void> {
  final ConfigRepository _configRepository;

  SetEnvUseCase(this._configRepository);

  @override
  Future<void> execute({required EnvEntity param}) {
    PolygonIdCore.setEnvConfig(param.config);

    return _configRepository.setEnv(env: param).then((_) async {
      logger().i("[SetEnvUseCase] $param env has been set");

      if (param.chainConfigs.isNotEmpty) {
        await _configRepository.setSelectedChainId(
            chainId: param.chainConfigs.entries.first.key);
      }
    }).catchError((error) {
      logger().e("[SetEnvUseCase] Error: $error");
      throw error;
    });
  }
}
