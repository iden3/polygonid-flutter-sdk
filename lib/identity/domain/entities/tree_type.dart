import 'package:polygonid_flutter_sdk/constants.dart';

enum TreeType {
  claims(claimsTreeStoreName),
  revocation(revocationTreeStoreName),
  roots(rootsTreeStoreName);

  final String storeName;

  const TreeType(this.storeName);
}
