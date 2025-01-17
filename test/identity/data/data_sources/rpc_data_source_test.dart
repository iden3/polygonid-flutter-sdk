import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_cases/get_selected_chain_use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/identity/data/data_sources/rpc_data_source.dart';
import 'package:web3dart/web3dart.dart';

import '../../../common/fake_capturer.dart';
import 'rpc_data_source_test.mocks.dart';

// Data
const id = "4f4f4f";
const name = "theName";
final DeployedContract contract = DeployedContract(
    ContractAbi(name, [const ContractFunction('getState', [])], []),
    EthereumAddress(Uint8List.fromList([
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
    ])));
final DeployedContract wrongContract = DeployedContract(
    ContractAbi(name, [], []),
    EthereumAddress(Uint8List.fromList([
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
    ])));
const callResult = [];
const result = "";

// Dependencies
class FakeWeb3Client extends FakeCapturer implements Web3Client {
  @override
  Future<List<dynamic>> call({
    EthereumAddress? sender,
    DeployedContract? contract,
    ContractFunction? function,
    List<dynamic>? params,
    BlockNum? atBlock,
  }) {
    capture('call', value: [sender, contract, function, params, atBlock]);
    return Future.value(callResult);
  }
}

FakeWeb3Client client = FakeWeb3Client();
MockGetSelectedChainUseCase _getSelectedChainUseCase =
    MockGetSelectedChainUseCase();
MockStacktraceManager _stacktraceManager = MockStacktraceManager();

// Tested instance
RPCDataSource dataSource = RPCDataSource(
  _getSelectedChainUseCase,
  _stacktraceManager,
);

/// FIXME: UT not possible since [RPCDataSource.getState] is using directly [State]
/// TODO: [RPCDataSource.getGistProof]
@GenerateMocks([
  GetSelectedChainUseCase,
  StacktraceManager,
])
void main() {
  // setUp(() {
  //   client.resetCaptures();
  // });
  //
  // group("Get state", () {
  //   test(
  //       "Given an id and a contract, when I call getState, then I expect a state to be returned as a string",
  //       () async {
  //     // When
  //     expect(await dataSource.getState(id, contract), result);
  //
  //     // Then
  //     expect(client.callCount('call'), 1);
  //     expect(client.captures['call']?.first[1], contract);
  //     expect(client.captures['call']?.first[3], (capture) {
  //       return capture is List && capture.length == 1 && capture[0] is BigInt;
  //     });
  //   });
  //
  //   test(
  //       "Given an id and a contract, when I call getState and an error occurred, then I expect an exception to be thrown",
  //       () async {
  //     // When
  //     await dataSource
  //         .getState(id, wrongContract)
  //         .then((_) => expect(true, false))
  //         .catchError((error) {
  //       expect(true, true);
  //     });
  //
  //     // Then
  //     expect(client.callCount('call'), 0);
  //   });
  // });
}
