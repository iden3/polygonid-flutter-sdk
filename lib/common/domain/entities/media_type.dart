enum MediaType {
  ZKPMessage('application/iden3-zkp-json'),
  PlainMessage('application/iden3comm-plain-json'),
  SignedMessage('application/iden3comm-signed-json'),
  EncryptedMessage('application/iden3comm-encrypted-json');

  final String name;

  const MediaType(this.name);

  static MediaType fromJson(String json) {
    return values.firstWhere(
      (e) => e.name == json,
      orElse: () => throw Exception('Invalid media type: $json'),
    );
  }

  String toJson() => name;
}
