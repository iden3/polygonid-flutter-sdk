import 'dart:convert';

import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/error_exception.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_cases/get_selected_chain_use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/common/utils/uint8_list_utils.dart';
import 'package:polygonid_flutter_sdk/assets/state.g.dart';
import 'package:polygonid_flutter_sdk/sdk/di/injector.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class RPCDataSource {
  /// FIXME: UC in a DS!
  final GetSelectedChainUseCase _getSelectedChainUseCase;
  final StacktraceManager _stacktraceManager;

  RPCDataSource(this._getSelectedChainUseCase, this._stacktraceManager);

  /// Retrieve last state for a given identity.
  ///
  /// @param [id] identity - The base58 identifier string
  /// @param [stateContract] the ABI contract
  ///
  /// @returns [String] last state committed
  Future<String> getState(String id, DeployedContract stateContract) async {
    final chain = await _getSelectedChainUseCase.execute();

    /// FIXME: inject web3Client through constructor
    Web3Client web3Client = getItSdk.get(param1: chain.rpcUrl);
    try {
      var state = State(address: stateContract.address, client: web3Client);
      BigInt idBigInt = Uint8ArrayUtils.leBuff2int(hexToBytes(id));
      logger().d(idBigInt);

      List<dynamic> result = await state.getStateInfoById(idBigInt);

      if (result.isNotEmpty && result.length == 7 && result[1] is BigInt) {
        if (result[1] != BigInt.zero) {
          // state
          String resultString =
              bytesToHex(Uint8ArrayUtils.bigIntToBytes(result[1]));
          logger().d(resultString);
          return resultString;
        }
      }
      return "";
    } on PolygonIdSDKException catch (_) {
      rethrow;
    } catch (e) {
      _stacktraceManager.addError("Error getting state from RPC with error $e");
      throw PolygonIdSDKException(
          errorMessage: "Error getting state from RPC with error $e");
    }
  }

  /// Retrieve gist proof.
  ///
  /// @param [id] identity - The id as bigint
  /// @param [gistContract] the ABI contract
  ///
  /// @returns [String] gist proof
  Future<String> getGistProof(String id, DeployedContract gistContract) async {
    final chain = await _getSelectedChainUseCase.execute();
    Web3Client web3Client = getItSdk.get(param1: chain.rpcUrl);
    try {
      /// TODO: replace to autegenerated code to interact with SC
      //var state = State(address: gistContract.address, client: web3Client);
      //dynamic res = await state.getGISTProof(BigInt.parse(id));
      final transactionParameters = [
        BigInt.parse(id),
      ];

      logger().d(transactionParameters);

      final List<dynamic> result = await web3Client.call(
        contract: gistContract,
        function: _getGistProof(gistContract),
        params: transactionParameters,
      );

      if (result.isNotEmpty && result[0] is List && result[0].length == 8) {
        final siblings =
            (result[0][2] as List).map((bigInt) => bigInt.toString()).toList();

        final String resultString = jsonEncode({
          "root": result[0][0].toString(),
          "existence": result[0][1].toString() == "true" ? true : false,
          "siblings": siblings,
          "index": result[0][3].toString(),
          "value": result[0][4].toString(),
          "auxExistence": result[0][5].toString() == "true" ? true : false,
          "auxIndex": result[0][6].toString(),
          "auxValue": result[0][7].toString(),
        });
        logger().d(resultString);
        return resultString;
      }
      return "";
    } on PolygonIdSDKException catch (_) {
      rethrow;
    } catch (e) {
      logger().e(e.toString());
      _stacktraceManager.addError("Error getting gist proof with error $e");
      throw PolygonIdSDKException(
          errorMessage: "Error getting gist proof with error $e");
    }
  }

  ContractFunction _getGistProof(DeployedContract contract) =>
      contract.function('getGISTProof');
}
