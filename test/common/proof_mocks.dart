import 'dart:convert';
import 'dart:typed_data';
import 'package:polygonid_flutter_sdk/proof/domain/entities/circuit_data_entity.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/gist_mtproof_entity.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/mtproof_dto.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/generate_inputs_response.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/zkproof_entity.dart';

import 'common_mocks.dart';
import 'identity_mocks.dart';

class ProofMocks {
  /// [ZKProof]
  static String zkProofJson = '''
  {
    "proof": {
      "pi_a": [
        "12972257478055385287254365242929501313320558748939011660089608743099745111180",
        "21622795818283390802665504767647060461631890183525796753414450241606249570803",
        "1"
      ],
      "pi_b": [
        [
          "12847099681483620244891896889509565905200847639156662566646831644425587767605",
          "7726906658874355928566136582233753422308699830282128425801792100522740842714"
        ],
        [
          "6980467906257014147239154441798190038380315305036926368340008520828455606752",
          "2230249755933402645582750376178300456263004874069787222631240999642444874805"
        ],
        [
          "1",
          "0"
        ]
      ],
      "pi_c": [
        "16986087905048485488743861514238967021136225770235326941460938993915565121755",
        "6238325077558487082209623595523126622748360999246019878388111583106516338436",
        "1"
      ],
      "protocol": "groth16",
      "curve": "bn128"
    },
    "pub_signals": [
      "17316009529728255179407732231309441587133332082639649894788962814402285838612",
      "4219394255904646201524967826472004258359338691812127250829480128630763541992",
      "35420013747224963877199162246728707260324950256512116597756573594137329664"
    ]
  }
  ''';

  static ZKProofEntity zkProof =
      ZKProofEntity.fromJson(jsonDecode(zkProofJson));

  /// [CircuitDataEntity]
  static Uint8List datFile = Uint8List(32);
  static Uint8List zKeyFile = Uint8List(32);
  static CircuitDataEntity circuitData = CircuitDataEntity(
      CommonMocks.circuitId, datFile, CommonMocks.zkeyFilePath);

  static MTProofEntity mtProof = MTProofEntity(
      existence: true, siblings: [IdentityMocks.hash, IdentityMocks.hash]);

  static GistMTProofEntity gistMTProof =
      GistMTProofEntity(root: CommonMocks.message, proof: mtProof);

  static PublicStatesInfo publicStatesInfo =
      PublicStatesInfo(states: [], gists: []);
}
