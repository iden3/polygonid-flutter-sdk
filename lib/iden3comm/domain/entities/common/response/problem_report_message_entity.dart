import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/iden3_message_entity.dart';

class ProblemReportMessageEntity extends Iden3MessageEntity<ProblemReportBody> {
  // Parent thread
  final String pthid;

  // List of IDs of previous messages that triggered this one
  final List<String>? ack;

  ProblemReportMessageEntity({
    required super.id,
    required super.typ,
    required super.type,
    required super.thid,
    required this.pthid,
    required this.ack,
    required super.from,
    required super.body,
  }) : super(messageType: Iden3MessageType.problemReport);

  factory ProblemReportMessageEntity.fromJson(Map<String, dynamic> json) {
    ProblemReportBody body = ProblemReportBody.fromJson(json['body']);

    return ProblemReportMessageEntity(
      id: json['id'],
      typ: json['typ'],
      type: json['type'],
      thid: json['thid'],
      pthid: json['pthid'],
      ack: json['ack'].map<String>((e) => e.toString()).toList(),
      from: "",
      body: body,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['body'] = body.toJson();
    data['pthid'] = pthid;
    data['ack'] = ack;
    return data;
  }

  @override
  String toString() => "[ProblemReportMessageEntity] {${super.toString()}}";

  @override
  bool operator ==(Object other) =>
      super == other && other is ProblemReportMessageEntity;

  @override
  int get hashCode => runtimeType.hashCode;
}

class ProblemReportBody {
  // (optional) List of arguments matching the placeholders in comment field
  final List<String>? args;

  // (required) Problem code (See Problem Codes section)
  final String code;

  // (optional) Human-friendly text describing the problem. Can include {1} placeholders {2}
  final String? comment;

  // (optional) URI where more help about the problem could be received
  final String? escalateTo;

  ProblemReportBody({
    this.args,
    required this.code,
    this.comment,
    this.escalateTo,
  });

  factory ProblemReportBody.fromJson(Map<String, dynamic> json) {
    return ProblemReportBody(
      args: json['args'].map<String>((e) => e.toString()).toList(),
      code: json['code'],
      comment: json['comment'],
      escalateTo: json['escalate_to'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      if (args != null) 'args': args,
      if (escalateTo != null) 'escalate_to': escalateTo,
      if (comment != null) 'comment': comment,
    };
  }

  @override
  String toString() =>
      "[ProblemReportBody] {code: $code, comment: $comment, args: $args, escalateTo: $escalateTo}";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProblemReportBody &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          escalateTo == other.escalateTo &&
          args == other.args &&
          comment == other.comment;

  @override
  int get hashCode => runtimeType.hashCode;
}
