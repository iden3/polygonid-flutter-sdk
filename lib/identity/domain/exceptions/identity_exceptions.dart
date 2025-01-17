import 'package:polygonid_flutter_sdk/common/domain/error_exception.dart';

class IdentityException extends PolygonIdSDKException {
  IdentityException({required String errorMessage, dynamic error})
      : super(errorMessage: errorMessage, error: error);
}

class TooLongPrivateKeyException extends PolygonIdSDKException {
  TooLongPrivateKeyException({required String errorMessage, dynamic error})
      : super(errorMessage: errorMessage, error: error);
}

class IdentityAlreadyExistsException extends PolygonIdSDKException {
  final String did;

  IdentityAlreadyExistsException({
    required this.did,
    required String errorMessage,
    dynamic error,
  }) : super(errorMessage: errorMessage, error: error);
}

class ProfileAlreadyExistsException extends PolygonIdSDKException {
  final String genesisDid;
  final BigInt profileNonce;

  ProfileAlreadyExistsException({
    required this.genesisDid,
    required this.profileNonce,
    required String errorMessage,
    dynamic error,
  }) : super(errorMessage: errorMessage, error: error);
}

class UnknownProfileException extends PolygonIdSDKException {
  final BigInt profileNonce;

  UnknownProfileException({
    required this.profileNonce,
    required String errorMessage,
    dynamic error,
  }) : super(errorMessage: errorMessage, error: error);
}

class UnknownIdentityException extends PolygonIdSDKException {
  final String did;

  UnknownIdentityException({
    required this.did,
    required String errorMessage,
    dynamic error,
  }) : super(errorMessage: errorMessage, error: error);
}

class InvalidPrivateKeyException extends PolygonIdSDKException {
  final String privateKey;

  InvalidPrivateKeyException({
    required this.privateKey,
    required String errorMessage,
    dynamic error,
  }) : super(errorMessage: errorMessage, error: error);
}

class InvalidProfileException extends PolygonIdSDKException {
  final BigInt profileNonce;

  InvalidProfileException({
    required this.profileNonce,
    required String errorMessage,
    dynamic error,
  }) : super(errorMessage: errorMessage, error: error);

  dynamic get error {
    if (profileNonce == BigInt.zero) {
      return "Genesis profile can't be modified";
    } else if (profileNonce.isNegative) {
      return "Profile nonce can't be negative";
    }

    return "Invalid profile";
  }
}

class FetchIdentityStateException extends PolygonIdSDKException {
  FetchIdentityStateException({required String errorMessage, dynamic error})
      : super(errorMessage: errorMessage, error: error);
}

class FetchStateRootsException extends PolygonIdSDKException {
  FetchStateRootsException({required String errorMessage, dynamic error})
      : super(errorMessage: errorMessage, error: error);
}

class NonRevProofException extends PolygonIdSDKException {
  NonRevProofException({required String errorMessage, dynamic error})
      : super(errorMessage: errorMessage, error: error);
}

class DidNotMatchCurrentEnvException extends PolygonIdSDKException {
  final String did;
  final String rightDid;

  DidNotMatchCurrentEnvException({
    required this.did,
    required this.rightDid,
    required String errorMessage,
    dynamic error,
  }) : super(errorMessage: errorMessage, error: error);
}
