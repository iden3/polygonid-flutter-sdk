import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:polygonid_flutter_sdk/common/utils/base_64.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/zkproof_entity.dart';

/// Sample
/// ```
/// {
///     "alg": "groth16",
///     "circuitId": "auth",
///     "crit": [
///         "circuitId"
///     ],
///     "typ": "application/iden3-zkp-json"
/// }
/// ```
///

/// Wrapper for [JWZEntity] header
class JWZHeader {
  final String alg;
  final String circuitId;
  final List<String> crit;
  final String typ;

  JWZHeader({
    required this.alg,
    required this.circuitId,
    required this.crit,
    required this.typ,
  });

  factory JWZHeader.fromBase64(String data) =>
      JWZHeader.fromJson(jsonDecode(Base64Util.decode(data)));

  factory JWZHeader.fromJson(Map<String, dynamic> json) => JWZHeader(
        alg: json['alg'] as String,
        circuitId: json['circuitId'] as String,
        crit: (json['crit'] as List<dynamic>).map((e) => e as String).toList(),
        typ: json['typ'] as String,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'alg': alg,
        'circuitId': circuitId,
        'crit': crit,
        'typ': typ,
      };

  @override
  String toString() =>
      "[JWZHeader] {alg: $alg, circuitId: $circuitId, crit: $crit, typ: $typ}";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JWZHeader &&
          runtimeType == other.runtimeType &&
          alg == other.alg &&
          circuitId == other.circuitId &&
          listEquals(crit, other.crit) &&
          typ == other.typ;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Wrapper for [JWZEntity] payload
class JWZPayload {
  final dynamic payload;

  JWZPayload({required this.payload});

  @override
  String toString() => "[JWZPayload] {payload: $payload}";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JWZPayload &&
          runtimeType == other.runtimeType &&
          payload == other.payload;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// JSON Web Zero-knowledge (JWZ) is an open standard
/// for representing messages proven by zero-knowledge technology.
class JWZEntity {
  final JWZHeader? header;
  final JWZPayload? payload;
  ZKProofEntity? proof;

  JWZEntity({this.header, required this.payload, this.proof});

  /// FIXME: should we move this to a mapper?
  factory JWZEntity.fromBase64(String data) {
    var split = data.split(".");

    return JWZEntity(
        header: JWZHeader.fromBase64(split[0]),
        payload: JWZPayload(payload: Base64Util.decode(split[1])),
        proof: split.length == 3 ? ZKProofEntity.fromBase64(split[2]) : null);
  }

  @override
  String toString() =>
      "[JWZEntity] {header: $header, payload: $payload, proof: $proof}";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JWZEntity &&
          runtimeType == other.runtimeType &&
          header == other.header &&
          payload == other.payload &&
          proof == other.proof;

  @override
  int get hashCode => runtimeType.hashCode;
}
