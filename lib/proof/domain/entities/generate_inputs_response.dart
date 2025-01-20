class GenerateInputsResponse {
  final Map<String, dynamic> inputs;
  final Map<String, dynamic>? verifiablePresentation;
  final PublicStatesInfo? publicStatesInfo;

  GenerateInputsResponse({
    required this.inputs,
    this.verifiablePresentation,
    this.publicStatesInfo,
  });

  factory GenerateInputsResponse.fromJson(Map<String, dynamic> json) {
    return GenerateInputsResponse(
      inputs: json["inputs"],
      verifiablePresentation: json["verifiablePresentation"],
      publicStatesInfo: PublicStatesInfo.fromJson(json["publicStatesInfo"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "inputs": inputs,
        if (verifiablePresentation != null)
          "verifiablePresentation": verifiablePresentation,
        if (publicStatesInfo != null)
          "publicStatesInfo": publicStatesInfo?.toJson(),
      };
}

class PublicStatesInfo {
  final List<PublicUserStateInfo> states;
  final List<PublicGistStateInfo> gists;

  PublicStatesInfo({
    required this.states,
    required this.gists,
  });

  factory PublicStatesInfo.fromJson(Map<String, dynamic> json) {
    return PublicStatesInfo(
      states: List<PublicUserStateInfo>.from(
        json["states"].map((x) => PublicUserStateInfo.fromJson(x)),
      ),
      gists: List<PublicGistStateInfo>.from(
        json["gists"].map((x) => PublicGistStateInfo.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        "states": states.map((x) => x.toJson()).toList(),
        "gists": gists.map((x) => x.toJson()).toList(),
      };
}

class PublicUserStateInfo {
  final String id;
  final String state;

  PublicUserStateInfo({
    required this.id,
    required this.state,
  });

  factory PublicUserStateInfo.fromJson(Map<String, dynamic> json) {
    return PublicUserStateInfo(
      id: json["id"],
      state: json["state"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "state": state,
      };
}

class PublicGistStateInfo {
  final String id;
  final String root;

  PublicGistStateInfo({
    required this.id,
    required this.root,
  });

  factory PublicGistStateInfo.fromJson(Map<String, dynamic> json) {
    return PublicGistStateInfo(
      id: json["id"],
      root: json["root"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "root": root,
      };
}
