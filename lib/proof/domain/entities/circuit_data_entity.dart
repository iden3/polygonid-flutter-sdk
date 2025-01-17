import 'dart:typed_data';

class CircuitDataEntity {
  final String circuitId;
  final Uint8List witnessCalculationData;
  final String zKeyPath;

  CircuitDataEntity(
    this.circuitId,
    this.witnessCalculationData,
    this.zKeyPath,
  );

  factory CircuitDataEntity.fromJson(Map<String, dynamic> json) {
    return CircuitDataEntity(
      json['circuitId'] as String,
      json['witnessCalculationData'] as Uint8List,
      json['zKeyPath'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'circuitId': circuitId,
      'witnessCalculationData': witnessCalculationData,
      'zKeyPath': zKeyPath,
    };
  }

  @override
  String toString() {
    return 'CircuitDataEntity{circuitId: $circuitId, witnessCalculationData: $witnessCalculationData, zKeyPath: $zKeyPath}';
  }
}
