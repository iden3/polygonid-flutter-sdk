import 'package:polygonid_flutter_sdk/common/domain/domain_constants.dart';
import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/filter_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/error_exception.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';
import 'package:polygonid_flutter_sdk/common/utils/credential_sort_order.dart';
import 'package:polygonid_flutter_sdk/credential/domain/entities/claim_entity.dart';
import 'package:polygonid_flutter_sdk/credential/domain/exceptions/credential_exceptions.dart';
import 'package:polygonid_flutter_sdk/credential/domain/repositories/credential_repository.dart';
import 'package:polygonid_flutter_sdk/identity/domain/exceptions/identity_exceptions.dart';

class GetClaimsParam {
  final List<FilterEntity>? filters;
  final String genesisDid;
  final BigInt profileNonce;
  final String encryptionKey;

  List<CredentialSortOrder> credentialSortOrderList;

  GetClaimsParam({
    this.filters,
    required this.genesisDid,
    required this.profileNonce,
    required this.encryptionKey,
    this.credentialSortOrderList = const [],
  });
}

class GetClaimsUseCase
    extends FutureUseCase<GetClaimsParam, List<ClaimEntity>> {
  final CredentialRepository _credentialRepository;
  final StacktraceManager _stacktraceManager;

  GetClaimsUseCase(
    this._credentialRepository,
    this._stacktraceManager,
  );

  @override
  Future<List<ClaimEntity>> execute({required GetClaimsParam param}) async {
    // if profileNonce is less than GENESIS_PROFILE_NONCE is invalid
    // because the profileNonce should be greater than or equal to GENESIS_PROFILE_NONCE
    if (param.profileNonce < GENESIS_PROFILE_NONCE) {
      _stacktraceManager.addTrace("[GetClaimsUseCase] Invalid profile nonce");
      _stacktraceManager.addError(
          "[GetClaimsUseCase] Invalid profile nonce: ${param.profileNonce}");
      throw InvalidProfileException(
        profileNonce: param.profileNonce,
        errorMessage: "Invalid profile nonce when getting claims",
      );
    }

    try {
      List<ClaimEntity> claims = await _credentialRepository.getClaims(
        filters: param.filters,
        genesisDid: param.genesisDid,
        encryptionKey: param.encryptionKey,
        credentialSortOrderList: param.credentialSortOrderList,
      );
      return claims;
    } on PolygonIdSDKException catch (_) {
      rethrow;
    } catch (error) {
      _stacktraceManager.addTrace("[GetClaimsUseCase] Error: $error");
      _stacktraceManager.addError(
          "[GetClaimsUseCase] Error while getting claims from the DB\n${error.toString()}");
      logger().e("[GetClaimsUseCase] Error: $error");
      throw GetClaimsException(
        errorMessage:
            'Error while getting claims from the DB\n${error.toString()}',
        error: error,
      );
    }
  }
}
