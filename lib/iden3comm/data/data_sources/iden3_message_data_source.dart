import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:encrypt/encrypt.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/oaep.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/digests/sha512.dart';
import 'package:polygonid_flutter_sdk/common/data/exceptions/network_exceptions.dart';
import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/dtos/authorization/response/auth_body_did_doc_response_dto.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/dtos/authorization/response/auth_body_did_doc_service_metadata_devices_response_dto.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/dtos/authorization/response/auth_body_did_doc_service_metadata_response_dto.dart';
import 'package:polygonid_flutter_sdk/iden3comm/data/dtos/authorization/response/auth_body_did_doc_service_response_dto.dart';

class Iden3MessageDataSource {
  final StacktraceManager _stacktraceManager;

  Iden3MessageDataSource(this._stacktraceManager);

  Future<AuthBodyDidDocResponseDTO> getDidDocResponse(
    String pushUrl,
    String didIdentifier,
    String pushToken,
    String packageName,
  ) async {
    return AuthBodyDidDocResponseDTO(
      context: const ["https://www.w3.org/ns/did/v1"],
      id: didIdentifier,
      service: [
        AuthBodyDidDocServiceResponseDTO(
          id: '$didIdentifier#mobile',
          type: 'Iden3MobileServiceV1',
          serviceEndpoint: 'iden3comm:v0.1:callbackHandler',
        ),
        AuthBodyDidDocServiceResponseDTO(
          id: "$didIdentifier#push",
          type: "push-notification",
          serviceEndpoint: pushUrl,
          metadata: AuthBodyDidDocServiceMetadataResponseDTO(devices: [
            AuthBodyDidDocServiceMetadataDevicesResponseDTO(
              ciphertext:
                  await _getPushCipherText(pushToken, pushUrl, packageName),
              alg: "RSA-OAEP-512",
            )
          ]),
        )
      ],
    );
  }

  Future<String> _getPushCipherText(
    String pushToken,
    String serviceEndpoint,
    String packageName,
  ) async {
    var pushInfo = {
      "app_id": packageName,
      "pushkey": pushToken,
    };

    Dio dio = Dio();
    final dir = await getApplicationDocumentsDirectory();
    final path = dir.path;
    dio.interceptors.add(
      DioCacheInterceptor(
        options: CacheOptions(
          store: HiveCacheStore(path),
          policy: CachePolicy.request,
          hitCacheOnErrorExcept: [],
          maxStale: const Duration(days: 7),
          priority: CachePriority.high,
        ),
      ),
    );

    var publicKeyResponse =
        await dio.get(Uri.parse("$serviceEndpoint/public").toString());

    if (publicKeyResponse.statusCode == 200 ||
        publicKeyResponse.statusCode == 304) {
      String publicKeyPem = publicKeyResponse.data;
      var publicKey = RSAKeyParser().parse(publicKeyPem) as RSAPublicKey;
      final encrypter =
          OAEPEncoding.withCustomDigest(() => SHA512Digest(), RSAEngine());
      encrypter.init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
      Uint8List encrypted = encrypter
          .process(Uint8List.fromList(json.encode(pushInfo).codeUnits));
      return base64.encode(encrypted);
    } else {
      logger().d(
          'getPublicKey Error: code: ${publicKeyResponse.statusCode} msg: ${publicKeyResponse.data}');
      _stacktraceManager.addError(
          'getPublicKey Error: code: ${publicKeyResponse.statusCode} msg: ${publicKeyResponse.data}');
      throw NetworkException(
        errorMessage: publicKeyResponse.data.toString(),
        statusCode: publicKeyResponse.statusCode ?? 0,
      );
    }
  }
}
