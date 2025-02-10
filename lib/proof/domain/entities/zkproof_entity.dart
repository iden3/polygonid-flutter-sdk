import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:polygonid_flutter_sdk/common/utils/base_64.dart';

/// Sample
/// ```
///       {
///         "pi_a": [
///             "10412436197494479587396667385707368282568055118269864457927476990636419702451",
///             "10781739095445201996467414817941805879982410676386176845296376344985187663334",
///             "1"
///         ],
///         "pi_b": [
///             [
///                 "18067868740006225615447194471370658980999926369695293115712951366707744064606",
///                 "21599241570547731234304039989166406415899717659171760043899509152011479663757"
///             ],
///             [
///                 "6699540705074924997967275186324755442260607671536434403065529164769702477398",
///                 "11257643293201627450293185164288482420559806649937371568160742601386671659800"
///             ],
///             [
///                 "1",
///                 "0"
///             ]
///         ],
///         "pi_c": [
///             "6216423503289496292944052032190353625422411483383378979029667243785319208095",
///             "14816218045158388758567608605576384994339714390370300963580658386534158603711",
///             "1"
///         ],
///         "protocol": "groth16"
///     }
/// ```
class ZKProofBaseEntity {
  final List<String> piA;
  final List<List<String>> piB;
  final List<String> piC;
  final String protocol;
  final String? curve;

  const ZKProofBaseEntity({
    required this.piA,
    required this.piB,
    required this.piC,
    required this.protocol,
    required this.curve,
  });

  factory ZKProofBaseEntity.fromJson(Map<String, dynamic> json) =>
      ZKProofBaseEntity(
        piA: (json['pi_a'] as List<dynamic>).map((e) => e as String).toList(),
        piB: (json['pi_b'] as List<dynamic>)
            .map((e) => (e as List<dynamic>).map((e) => e as String).toList())
            .toList(),
        piC: (json['pi_c'] as List<dynamic>).map((e) => e as String).toList(),
        protocol: json['protocol'] as String,
        curve: json['curve'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'pi_a': piA,
        'pi_b': piB,
        'pi_c': piC,
        'protocol': protocol,
        if (curve != null) 'curve': curve,
      };

  @override
  String toString() =>
      "[BaseProofEntity] {piA: $piA, piB: $piB, piC: $piC, protocol: $protocol, curve: $curve}";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZKProofBaseEntity &&
          runtimeType == other.runtimeType &&
          listEquals(piA, other.piA) &&
          listEquals(piB, other.piB) &&
          listEquals(piC, other.piC) &&
          protocol == other.protocol &&
          curve == other.curve;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Sample
/// ```
///   {
///     "proof": {
///         "pi_a": [
///             "10412436197494479587396667385707368282568055118269864457927476990636419702451",
///             "10781739095445201996467414817941805879982410676386176845296376344985187663334",
///             "1"
///         ],
///         "pi_b": [
///             [
///                 "18067868740006225615447194471370658980999926369695293115712951366707744064606",
///                 "21599241570547731234304039989166406415899717659171760043899509152011479663757"
///             ],
///             [
///                 "6699540705074924997967275186324755442260607671536434403065529164769702477398",
///                 "11257643293201627450293185164288482420559806649937371568160742601386671659800"
///             ],
///             [
///                 "1",
///                 "0"
///             ]
///         ],
///         "pi_c": [
///             "6216423503289496292944052032190353625422411483383378979029667243785319208095",
///             "14816218045158388758567608605576384994339714390370300963580658386534158603711",
///             "1"
///         ],
///         "protocol": "groth16"
///     },
///     "pub_signals": [
///         "4976943943966365062123221999838013171228156495366270377261380449787871898672",
///         "18656147546666944484453899241916469544090258810192803949522794490493271005313",
///         "379949150130214723420589610911161895495647789006649785264738141299135414272"
///     ]
///   }
/// ```

class ZKProofEntity {
  final ZKProofBaseEntity proof;
  final List<String> pubSignals;

  ZKProofEntity({
    required this.proof,
    required this.pubSignals,
  });

  factory ZKProofEntity.fromBase64(String data) =>
      ZKProofEntity.fromJson(jsonDecode(Base64Util.decode(data)));

  factory ZKProofEntity.fromJson(Map<String, dynamic> json) => ZKProofEntity(
        proof:
            ZKProofBaseEntity.fromJson(json['proof'] as Map<String, dynamic>),
        pubSignals: (json['pub_signals'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'proof': proof.toJson(),
        'pub_signals': pubSignals,
      };

  @override
  String toString() =>
      "[ZKProofEntity] {proof: $proof, pubSignals: $pubSignals}";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ZKProofEntity &&
          runtimeType == other.runtimeType &&
          proof == other.proof &&
          listEquals(pubSignals, other.pubSignals);

  @override
  int get hashCode => runtimeType.hashCode;

  //copyWith method
  ZKProofEntity copyWith({
    ZKProofBaseEntity? proof,
    List<String>? pubSignals,
  }) {
    return ZKProofEntity(
      proof: proof ?? this.proof,
      pubSignals: pubSignals ?? this.pubSignals,
    );
  }
}
