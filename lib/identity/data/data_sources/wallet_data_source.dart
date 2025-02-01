import 'dart:math';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/identity/libs/bjj/bjj_wallet.dart';
import 'package:polygonid_flutter_sdk/identity/libs/bjj/eddsa_babyjub.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart';

@injectable
class WalletLibWrapper {
  Future<BjjWallet> createWallet({Uint8List? secret}) {
    try {
      return BjjWallet.createBjjWallet(secret: secret);
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<BjjWallet> getWallet({required Uint8List privateKey}) {
    try {
      return Future.value(BjjWallet(privateKey));
    } catch (e) {
      return Future.error(e);
    }
  }

  /// Signs message with bjjKey derived from private key
  /// @param [String] privateKey - privateKey
  /// @param [String] message - message to sign
  /// @returns [String] - Babyjubjub signature packed and encoded as an hex string
  Future<String> signMessage({
    required Uint8List privateKey,
    required String message,
  }) async {
    Uint8List messHash;
    if (message.toLowerCase().startsWith("0x")) {
      message = strip0x(message);
      messHash = hexToBytes(message);
    } else {
      messHash = hexToBytes(BigInt.parse(message, radix: 10).toRadixString(16));
    }
    final bjjKey = BjjPrivateKey(privateKey);
    final signature = bjjKey.sign(messHash);
    return bytesToHex(signature);
  }
}

class WalletLibWrapperUpdated extends WalletLibWrapper {
  @override
  Future<BjjWallet> createWallet({Uint8List? secret}) async {
    if (secret == null) {
      final key = EthPrivateKey.createRandom(Random.secure());
      return BjjWallet(key.privateKey);
    } else {
      return BjjWallet(secret);
    }
  }
}

class WalletDataSource {
  final WalletLibWrapper _walletLibWrapper;

  WalletDataSource(this._walletLibWrapper);

  Future<BjjWallet> createWallet({Uint8List? secret}) {
    logger().i("CREATE_WALLLET_CALLED");
    return _walletLibWrapper.createWallet(secret: secret);
  }

  Future<BjjWallet> getWallet({required Uint8List privateKey}) {
    return _walletLibWrapper.getWallet(privateKey: privateKey);
  }

  Future<String> signMessage({
    required Uint8List privateKey,
    required String message,
  }) {
    return _walletLibWrapper.signMessage(
      privateKey: privateKey,
      message: message,
    );
  }
}
