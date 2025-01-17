// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rhs_node_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RhsNodeEntity _$RhsNodeEntityFromJson(Map<String, dynamic> json) =>
    RhsNodeEntity(
      node: NodeEntity.fromJson(json['node'] as Map<String, dynamic>),
      status: json['status'] as String,
    );

Map<String, dynamic> _$RhsNodeEntityToJson(RhsNodeEntity instance) =>
    <String, dynamic>{
      'node': instance.node.toJson(),
      'status': instance.status,
    };
