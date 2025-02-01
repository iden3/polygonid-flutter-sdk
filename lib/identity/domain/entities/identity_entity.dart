import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'identity_entity.g.dart';

/// Represents an identity DTO.
@JsonSerializable()
class IdentityEntity extends Equatable {
  final String did;
  final List<String> publicKey;
  final Map<BigInt, String> profiles;

  const IdentityEntity({
    required this.did,
    required this.publicKey,
    required this.profiles,
  });

  factory IdentityEntity.fromJson(Map<String, dynamic> json) =>
      _$IdentityEntityFromJson(json);

  Map<String, dynamic> toJson() => _$IdentityEntityToJson(this);

  @override
  List<Object?> get props => [did, publicKey, profiles];
}
