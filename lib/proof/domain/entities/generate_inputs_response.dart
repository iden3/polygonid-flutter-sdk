class GenerateInputsResponse {
  final Map<String, dynamic> inputs;
  final dynamic verifiablePresentation;
  final Map<String, dynamic>? publicStatesInfo;

  GenerateInputsResponse({
    required this.inputs,
    this.verifiablePresentation,
    this.publicStatesInfo,
  });

  factory GenerateInputsResponse.fromJson(Map<String, dynamic> json) {
    return GenerateInputsResponse(
      inputs: json["inputs"],
      verifiablePresentation: json["verifiablePresentation"],
      publicStatesInfo: json["publicStatesInfo"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "inputs": inputs,
      if (verifiablePresentation != null)
        "verifiablePresentation": verifiablePresentation,
      if (publicStatesInfo != null) "publicStatesInfo": publicStatesInfo,
    };
  }
}
