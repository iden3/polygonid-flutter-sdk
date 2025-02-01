import 'package:polygonid_flutter_sdk/common/domain/entities/filter_entity.dart';

abstract class DidProfileInfoRepository {
  Future<void> addDidProfileInfo({
    required Map<String, dynamic> didProfileInfo,
    required String interactedDid,
    required String genesisDid,
    required String encryptionKey,
  });

  Future<List<Map<String, dynamic>>> getDidProfileInfoList({
    List<FilterEntity>? filters,
    required String genesisDid,
    required String encryptionKey,
  });

  Future<Map<String, dynamic>> getDidProfileInfoByInteractedWithDid({
    required String interactedWithDid,
    required String genesisDid,
    required String encryptionKey,
  });

  Future<void> removeDidProfileInfo({
    required String interactedDid,
    required String genesisDid,
    required String encryptionKey,
  });
}
