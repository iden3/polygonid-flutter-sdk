import 'dart:typed_data';

import 'package:polygonid_flutter_sdk/common/abi_encode/abi_encode.dart';
import 'package:polygonid_flutter_sdk/common/utils/hex_utils.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/universal_resolver_entity.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

///
/// ZKPResponse
/// ----------------------------------------------------------------

/// struct ZKPResponse - tuple(uint64, bytes zkProof, bytes data)
class ZKPResponse implements AbiEncodable {
  final BigInt requestId;
  final Uint8List zkProof;
  final Uint8List data;

  ZKPResponse({
    required this.requestId,
    required this.zkProof,
    required this.data,
  });

  @override
  AbiType get abiType {
    return const TupleType([
      UintType(),
      DynamicBytes(),
      DynamicBytes(),
    ]);
  }

  @override
  List toAbiEncodeArgs() {
    return [
      requestId,
      zkProof,
      data,
    ];
  }
}

///
/// Metadata
/// ----------------------------------------------------------------

/// tuple(string key, bytes value)[]
class Metadata implements AbiEncodable {
  final String key;
  final Uint8List value;

  Metadata({
    required this.key,
    required this.value,
  });

  @override
  AbiType get abiType {
    return const TupleType(
      [
        StringType(),
        DynamicBytes(),
      ],
    );
  }

  @override
  List toAbiEncodeArgs() {
    return [
      key,
      value,
    ];
  }
}

///
/// Cross chain proof
/// ----------------------------------------------------------------

/// tuple(
///   string proofType,
///   bytes proof
/// )[]

class CrossChainProof implements AbiEncodable {
  final String proofType;
  final Uint8List proof;

  CrossChainProof({
    required this.proofType,
    required this.proof,
  });

  @override
  AbiType get abiType {
    return const TupleType([
      StringType(),
      DynamicBytes(),
    ]);
  }

  @override
  List toAbiEncodeArgs() {
    return [
      proofType,
      proof,
    ];
  }

  @override
  int get hashCode => proofType.hashCode ^ proof.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CrossChainProof &&
        other.proofType == proofType &&
        other.proof == proof;
  }
}

///
/// Signed state message
/// ----------------------------------------------------------------

abstract class SignedStateMessage implements AbiEncodable {
  final Uint8List signature;

  SignedStateMessage({
    required this.signature,
  });

  String get proofType;

  Map<String, dynamic> toJson() {
    return {
      'signature': bytesToHex(signature),
    };
  }
}

abstract class StateMessage implements AbiEncodable {
  Map<String, dynamic> toJson();
}

///
/// Global state message
/// ----------------------------------------------------------------

/// tuple(
///    tuple(
///      uint256 timestamp,
///      bytes2 idType,
///      uint256 root,
///      uint256 replacedAtTimestamp
///    ) globalStateMsg,
///    bytes signature,
/// ),

const _globalStateProofType = 'globalStateProof';

class SignedGlobalStateMessage extends SignedStateMessage {
  final GlobalStateMessage globalStateMsg;

  SignedGlobalStateMessage({
    required this.globalStateMsg,
    required super.signature,
  });

  @override
  String get proofType => _globalStateProofType;

  @override
  AbiType get abiType {
    return TupleType([
      TupleType([
        globalStateMsg.abiType,
        const DynamicBytes(),
      ]),
    ]);
  }

  @override
  List<dynamic> toAbiEncodeArgs() {
    return [
      [
        globalStateMsg.toAbiEncodeArgs(),
        signature,
      ],
    ];
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'globalStateMsg': globalStateMsg.toJson(),
    };
  }
}

class GlobalStateMessage extends StateMessage {
  final Uint8List idType;
  final BigInt replacedAtTimestamp;
  final BigInt root;
  final BigInt timestamp;

  GlobalStateMessage({
    required this.idType,
    required this.replacedAtTimestamp,
    required this.root,
    required this.timestamp,
  });

  factory GlobalStateMessage.fromEip712Message(
      GlobalStateEIP712Message message) {
    return GlobalStateMessage(
      idType: message.idType.strip0x().bytesFromHex(),
      replacedAtTimestamp: BigInt.parse(message.replacedAtTimestamp),
      root: BigInt.parse(message.root),
      timestamp: BigInt.parse(message.timestamp),
    );
  }

  @override
  AbiType get abiType {
    return const TupleType([
      UintType(),
      FixedBytes(2),
      UintType(),
      UintType(),
    ]);
  }

  @override
  List<dynamic> toAbiEncodeArgs() {
    return [
      timestamp,
      idType,
      root,
      replacedAtTimestamp,
    ];
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'idType': bytesToHex(idType),
      'replacedAtTimestamp': replacedAtTimestamp.toString(),
      'root': root.toString(),
      'timestamp': timestamp.toString(),
    };
  }
}

///
/// Identity state message
/// ----------------------------------------------------------------

/// tuple(
///   tuple(
///     uint256 timestamp
///     uint256 id
///     uint256 state
///     uint256 replacedAtTimestamp
///   ) idStateMsg,
///   bytes signature
/// )

const _identityStateProofType = 'stateProof';

class SignedIdentityStateMessage extends SignedStateMessage {
  final IdentityStateMessage idStateMsg;

  SignedIdentityStateMessage({
    required this.idStateMsg,
    required super.signature,
  });

  @override
  String get proofType => _identityStateProofType;

  @override
  AbiType get abiType {
    return TupleType([
      TupleType([
        idStateMsg.abiType,
        const DynamicBytes(),
      ]),
    ]);
  }

  @override
  List<dynamic> toAbiEncodeArgs() {
    return [
      [
        idStateMsg.toAbiEncodeArgs(),
        signature,
      ],
    ];
  }

  SignedIdentityStateMessage copyWithSignature(String signature) {
    return SignedIdentityStateMessage(
      idStateMsg: idStateMsg,
      signature: hexToBytes(signature),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'idStateMsg': idStateMsg.toJson(),
    };
  }
}

class IdentityStateMessage extends StateMessage {
  final BigInt timestamp;
  final BigInt id;
  final BigInt state;
  final BigInt replacedAtTimestamp;

  IdentityStateMessage({
    required this.timestamp,
    required this.id,
    required this.state,
    required this.replacedAtTimestamp,
  });

  factory IdentityStateMessage.fromEip712Message(
      IdentityStateEIP712Message message) {
    return IdentityStateMessage(
      timestamp: BigInt.parse(message.timestamp),
      id: BigInt.parse(message.id),
      state: BigInt.parse(message.state),
      replacedAtTimestamp: BigInt.parse(message.replacedAtTimestamp),
    );
  }

  @override
  AbiType get abiType {
    return const TupleType([
      UintType(),
      UintType(),
      UintType(),
      UintType(),
    ]);
  }

  @override
  List<dynamic> toAbiEncodeArgs() {
    return [
      timestamp,
      id,
      state,
      replacedAtTimestamp,
    ];
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toString(),
      'id': id.toString(),
      'state': state.toString(),
      'replacedAtTimestamp': replacedAtTimestamp.toString(),
    };
  }
}
