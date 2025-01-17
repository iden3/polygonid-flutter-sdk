import 'package:polygonid_flutter_sdk/common/domain/use_cases/get_env_use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_genesis_state_use_case.dart';

import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';

class GetDidIdentifierParam {
  final String bjjPrivateKey;
  final List<String> bjjPublicKey;
  final String blockchain;
  final String network;
  final BigInt profileNonce;
  final String? method;

  GetDidIdentifierParam({
    required this.bjjPublicKey,
    required this.blockchain,
    required this.network,
    required this.profileNonce,
    this.method,
  }) : bjjPrivateKey = "";

  GetDidIdentifierParam.withPrivateKey({
    required this.bjjPrivateKey,
    required this.blockchain,
    required this.network,
    required this.profileNonce,
    this.method,
  }) : bjjPublicKey = const <String>[];
}

class GetDidIdentifierUseCase
    extends FutureUseCase<GetDidIdentifierParam, String> {
  final IdentityRepository _identityRepository;
  final GetEnvUseCase _getEnvUseCase;
  final GetGenesisStateUseCase _getGenesisStateUseCase;
  final StacktraceManager _stacktraceManager;

  GetDidIdentifierUseCase(
    this._identityRepository,
    this._getEnvUseCase,
    this._getGenesisStateUseCase,
    this._stacktraceManager,
  );

  @override
  Future<String> execute({required GetDidIdentifierParam param}) async {
    return Future(() async {
      final env = await _getEnvUseCase.execute();
      final List<String> publicKey;
      if (param.bjjPublicKey.isNotEmpty) {
        publicKey = param.bjjPublicKey;
      } else {
        publicKey = await _identityRepository.getPublicKeys(
          bjjPrivateKey: param.bjjPrivateKey,
        );
      }

      final genesisState = await _getGenesisStateUseCase.execute(
        param: publicKey,
      );
      final claimsRoot = genesisState.claimsTree.string();
      final did = await _identityRepository.getDidIdentifier(
        blockchain: param.blockchain,
        network: param.network,
        claimsRoot: claimsRoot,
        profileNonce: param.profileNonce,
        config: env.config,
        method: param.method,
      );
      logger().i("[GetDidIdentifierUseCase] did: $did");

      return did;
    }).catchError((error) {
      logger().e("[GetDidIdentifierUseCase] Error: $error");
      _stacktraceManager.addTrace("[GetDidIdentifierUseCase] Error: $error");
      throw error;
    });
  }
}
