import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/did_entity.dart';

import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';

/// Get the DID entity from the string representation.
/// [param] - DID string representation.
/// Example: did:iden3:privado:main:2SZR7B32w1QSBNeX99h6hyVA8AFrpeX26r2f3S881j
class GetDidUseCase extends FutureUseCase<String, DidEntity> {
  GetDidUseCase();

  @override
  Future<DidEntity> execute({required String param}) {
    List<String> splits = param.split(":");

    if (splits.length == 5 && splits[0] == "did") {
      var did = DidEntity(
        did: param,
        method: splits[1],
        blockchain: splits[2],
        network: splits[3],
        identifier: splits[4],
      );
      logger().i("[GetDidUseCase] DID: $did");

      return Future.value(did);
    } else {
      logger().e("[GetDidUseCase] Error on did string representation");

      throw FormatException;
    }
  }
}
