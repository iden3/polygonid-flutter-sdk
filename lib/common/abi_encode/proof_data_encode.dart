import 'package:polygonid_flutter_sdk/common/abi_encode/abi_encode.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/zkproof_entity.dart';
import 'package:web3dart/web3dart.dart';

class AbiEncodableZKProofEntity extends ZKProofEntity implements AbiEncodable {
  AbiEncodableZKProofEntity({
    required super.proof,
    required super.pubSignals,
  });

  factory AbiEncodableZKProofEntity.fromZKProofEntity(
      ZKProofEntity zkProofEntity) {
    return AbiEncodableZKProofEntity(
      proof: zkProofEntity.proof,
      pubSignals: zkProofEntity.pubSignals,
    );
  }

  @override
  AbiType get abiType {
    return const TupleType(
      [
        DynamicLengthArray(type: UintType()),
        FixedLengthArray(type: UintType(), length: 2),
        FixedLengthArray(
          type: FixedLengthArray(type: UintType(), length: 2),
          length: 2,
        ),
        FixedLengthArray(type: UintType(), length: 2),
      ],
    );
  }

  @override
  List toAbiEncodeArgs() {
    /// [uint256[] inputs, uint256[2], uint256[2][2], uint256[2]]
    /// We want to take only the first 2 elements of each array
    /// and swap the order of the elements in piB
    return [
      pubSignals.map((p) => BigInt.parse(p)).toList(),
      proof.piA.map((p) => BigInt.parse(p)).take(2).toList(),
      [
        [
          BigInt.parse(proof.piB[0][1]),
          BigInt.parse(proof.piB[0][0]),
        ],
        [
          BigInt.parse(proof.piB[1][1]),
          BigInt.parse(proof.piB[1][0]),
        ],
      ],
      proof.piC.map((p) => BigInt.parse(p)).take(2).toList(),
    ];
  }
}

extension AbiEncodableZKProofEntityExtension on ZKProofEntity {
  AbiEncodableZKProofEntity toAbiEncodable() {
    return AbiEncodableZKProofEntity.fromZKProofEntity(this);
  }
}
