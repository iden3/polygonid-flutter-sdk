import 'package:polygonid_flutter_sdk/common/kms/keys/types.dart';

/// builds key path
///
/// @param {KmsKeyType} keyType - key type
/// @param {string} keyID - key id
/// @returns string path
String keyPath(KeyType keyType, String keyID) {
  const basePath = '';
  return basePath + keyType.name + ':' + keyID;
}
