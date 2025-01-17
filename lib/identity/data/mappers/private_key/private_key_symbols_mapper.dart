import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:polygonid_flutter_sdk/identity/data/mappers/private_key/private_key_mapper.dart';
import 'package:polygonid_flutter_sdk/identity/domain/exceptions/identity_exceptions.dart';

@Injectable(as: PrivateKeyMapper)
@Deprecated(
    "It is wrong to use String.codeUnits to convert private key to bytes. ")
class PrivateKeySymbolsMapper extends PrivateKeyMapper {
  @override
  Uint8List? mapFrom(String? from) {
    Uint8List? key;

    if (from != null) {
      var private = from.codeUnits;

      if (private.length > 32) {
        throw TooLongPrivateKeyException(
          errorMessage:
              "Private key is too long, ${private.length} bytes instead of 32 bytes",
        );
      }

      key = Uint8List(32);
      key.setAll(0, Uint8List.fromList(private));
      key.fillRange(private.length, 32, 0);
    }

    return key;
  }
}
