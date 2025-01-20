import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/chain_config_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/env_config_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/env_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/filter_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/generate_inputs_response.dart';

class CommonMocks {
  static String name = "theName";
  static String did = "did:polygonid:polygon:mumbai:$id";
  static String id = "theId";
  static String identifier = "theIdentifier";
  static String privateKey = "000000";
  static Map<BigInt, String> profiles = {
    BigInt.zero: "${did}0",
    BigInt.one: "${did}1"
  };
  static String walletPrivateKey = "theWalletPrivateKey";
  static String pubX = "thePubX";
  static String pubY = "thePubY";
  static List<String> pubKeys = [pubX, pubY];
  static String message = "theMessage";
  static String signature = "theSignature";
  static String challenge = "theChallenge";
  static String authClaim = "theAuthClaim";
  static String state = "theState";
  static String thid = "theThid";
  static String to = "theTo";
  static String from = "theFrom";
  static String typ = "theTyp";
  static String token = "theToken";
  static String url = "theUrl";
  static String circuitId = "credentialAtomicQuerySig";
  static String zkeyFilePath = "zkeyFilePath";
  static String field = "theField";
  static String issuer = "theIssuer";
  static String type = "KYCAgeCredential";
  static List<int> intValues = [0, 1, 2];
  static List<BigInt> bigIntValues = [BigInt.zero, BigInt.one, BigInt.two];
  static int operator = 4;
  static String config = "theConfig";
  static BigInt nonce = BigInt.one;
  static BigInt genesisNonce = BigInt.zero;
  static BigInt negativeNonce = BigInt.from(-1);
  static Map<String, dynamic> aMap = {
    'the': {'very': 'nice map'},
    'yep': 4
  };
  static Uint8List aBytes = Uint8List(32);
  static String inputs = "{}";
  static GenerateInputsResponse generateInputsResponse = GenerateInputsResponse(
    inputs: {},
  );
  static String hash = "theHash";
  static Exception exception = Exception(message);
  static String blockchain = "theBlockchain";
  static String network = "theNetwork";
  static String method = "theMethod";
  static EnvConfigEntity envConfig = EnvConfigEntity(ipfsNodeUrl: '');

  static FilterEntity filter = FilterEntity(name: name, value: aMap);

  static Key key = Key.fromBase16(CommonMocks.privateKey);

  static Map<String, dynamic> envJson = {
    'pushUrl': url,
    'ipfsUrl': url,
    'chainConfigs': {
      "137": {
        'blockchain': name,
        'network': network,
        'rpcUrl': url,
        'stateContractAddr': message,
      }
    },
    'didMethods': [],
  };

  static EnvEntity env = EnvEntity(
    pushUrl: url,
    ipfsUrl: url,
    chainConfigs: {
      "137": ChainConfigEntity(
        blockchain: name,
        network: network,
        rpcUrl: url,
        stateContractAddr: message,
      ),
    },
    didMethods: [],
  );

  static ChainConfigEntity chain = ChainConfigEntity(
    blockchain: name,
    network: network,
    rpcUrl: url,
    stateContractAddr: message,
  );

  static String expiration = "2050-01-01T00:00:00Z";

  static String credentialRawValue = "{\"the\": \"value\"}";
}
