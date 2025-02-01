import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart';

import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart';
import 'package:polygonid_flutter_sdk/common/domain/use_case.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/identity_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';

class GetIdentitiesUseCase extends FutureUseCase<void, List<IdentityEntity>> {
  final IdentityRepository _identityRepository;
  final StacktraceManager _stacktraceManager;

  GetIdentitiesUseCase(
    this._identityRepository,
    this._stacktraceManager,
  );

  @override
  Future<List<IdentityEntity>> execute({void param}) async {
    try {
      final identities = await _identityRepository.getIdentities();
      logger().i("[GetIdentitiesUseCase] identities: $identities");
      _stacktraceManager
          .addTrace("[GetIdentitiesUseCase] identities: $identities");

      return identities;
    } catch (error) {
      logger().e("[GetIdentitiesUseCase] Error: $error");
      _stacktraceManager.addTrace("[GetIdentitiesUseCase] Error: $error");
      _stacktraceManager.addError("[GetIdentitiesUseCase] Error: $error");

      rethrow;
    }
  }
}
