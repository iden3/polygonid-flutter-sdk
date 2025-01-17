import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../identity/domain/entities/hash_entity.dart';
import 'node_aux_entity.dart';

part 'mtproof_dto.g.dart';

/*
"proof": {
          "existence": false,
          "siblings": [],
          "node_aux": {
            "key":
                "24846663430375341177084327381366271031641225773947711007341346118923321345",
            "value":
                "6317996369756476782464660619835940615734517981889733696047139451453239145426"
          }
    }
*/

/// Represents a merkle tree proof DTO.
@JsonSerializable(explicitToJson: true)
class MTProofEntity extends Equatable {
  @JsonKey(name: 'existence')
  final bool existence;
  @JsonKey(name: 'siblings')
  final List<HashEntity> siblings;
  @JsonKey(name: 'node_aux', includeIfNull: false)
  final NodeAuxEntity? nodeAux;

  const MTProofEntity({
    required this.existence,
    required this.siblings,
    this.nodeAux,
  });

  factory MTProofEntity.fromJson(Map<String, dynamic> json) =>
      _$MTProofEntityFromJson(json);

  Map<String, dynamic> toJson() => _$MTProofEntityToJson(this);

  @override
  List<Object?> get props => [existence, siblings, nodeAux];
}
