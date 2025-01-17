import 'dart:convert';

import 'package:polygonid_flutter_sdk/common/domain/error_exception.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/exceptions/iden3comm_exceptions.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_auth_inputs_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_auth_challenge_use_case.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_jwz_use_case.dart';
import 'package:polygonid_flutter_sdk/proof/domain/use_cases/load_circuit_use_case.dart';
import 'package:polygonid_flutter_sdk/proof/domain/use_cases/prove_use_case.dart';

import '../../../common/domain/domain_logger.dart';
import '../../../common/domain/use_case.dart';

class GetAuthTokenParam {
  final String genesisDid;
  final BigInt profileNonce;
  final String privateKey;
  final String message;

  GetAuthTokenParam({
    required this.genesisDid,
    required this.profileNonce,
    required this.privateKey,
    required this.message,
  });
}

class GetAuthTokenUseCase extends FutureUseCase<GetAuthTokenParam, String> {
  final LoadCircuitUseCase _loadCircuitUseCase;
  final GetJWZUseCase _getJWZUseCase;
  final GetAuthChallengeUseCase _getAuthChallengeUseCase;
  final GetAuthInputsUseCase _getAuthInputsUseCase;
  final ProveUseCase _proveUseCase;
  final StacktraceManager _stacktraceManager;

  GetAuthTokenUseCase(
    this._loadCircuitUseCase,
    this._getJWZUseCase,
    this._getAuthChallengeUseCase,
    this._getAuthInputsUseCase,
    this._proveUseCase,
    this._stacktraceManager,
  );

  @override
  Future<String> execute({required GetAuthTokenParam param}) async {
    Stopwatch stopwatch = Stopwatch()..start();
    logger().i('GetAuthTokenUseCase: started');
    try {
      final jwz = await _getJWZUseCase.execute(
        param: GetJWZParam(message: param.message),
      );

      logger().i(
          'GetAuthTokenUseCase: getJWZUseCase at ${stopwatch.elapsedMilliseconds} ms');

      final authChallenge = await _getAuthChallengeUseCase.execute(param: jwz);

      logger().i(
          'GetAuthTokenUseCase: getAuthChallengeUseCase at ${stopwatch.elapsedMilliseconds} ms');

      final generateInputsResponse = await _getAuthInputsUseCase.execute(
        param: GetAuthInputsParam(
          authChallenge,
          param.genesisDid,
          param.profileNonce,
          param.privateKey,
        ),
      );
      final authInputs = jsonEncode(generateInputsResponse.inputs);

      logger().i(
          'GetAuthTokenUseCase: getAuthInputsUseCase at ${stopwatch.elapsedMilliseconds} ms');

      final circuit = await _loadCircuitUseCase.execute(param: "authV2");

      logger().i(
          'GetAuthTokenUseCase: loadCircuitUseCase at ${stopwatch.elapsedMilliseconds} ms');

      final zkProofEntity = await _proveUseCase.execute(
        param: ProveParam(authInputs, circuit),
      );

      logger().i(
          'GetAuthTokenUseCase: proveUseCase at ${stopwatch.elapsedMilliseconds} ms');

      String authToken = await _getJWZUseCase.execute(
        param: GetJWZParam(message: param.message, proof: zkProofEntity),
      );

      logger().i(
          'GetAuthTokenUseCase: getJWZUseCase at ${stopwatch.elapsedMilliseconds} ms');

      return authToken;
    } on PolygonIdSDKException catch (_) {
      rethrow;
    } catch (error) {
      logger().e("[GetAuthTokenUseCase] Error: $error");
      _stacktraceManager.addTrace("[GetAuthTokenUseCase] Error: $error");
      _stacktraceManager.addError("[GetAuthTokenUseCase] Error: $error");
      throw GetAuthTokenException(
        errorMessage: "Error while getting auth token",
        error: error,
      );
    }
  }
}
