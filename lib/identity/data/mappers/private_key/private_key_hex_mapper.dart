import 'dart:typed_data';

import 'package:hex/hex.dart';
import 'package:polygonid_flutter_sdk/identity/data/mappers/private_key/private_key_mapper.dart';
import 'package:polygonid_flutter_sdk/identity/domain/exceptions/identity_exceptions.dart';

class PrivateKeyHexMapper extends PrivateKeyMapper {
  @override
  Uint8List? mapFrom(String? from) {
    if (from == null) {
      return null;
    }

    if (from.length != 64) {
      throw TooLongPrivateKeyException(
        errorMessage:
            "Private key is too long, ${from.length} symbols instead of 64 symbols",
      );
    }

    final private = HEX.decode(from);

    return Uint8List.fromList(private);
  }
}
