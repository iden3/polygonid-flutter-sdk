import 'package:injectable/injectable.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/proof/response/iden3comm_proof_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';
import 'package:polygonid_flutter_sdk/proof/data/data_sources/crosschain_resolver_data_source.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/universal_resolver_entity.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/generate_inputs_response.dart';

typedef MessageWithSignature = ({BaseEIP712Message message, String signature});

@injectable
class CrosschainRepository {
  final ResolverDataSource _crosschainDataSource;
  final IdentityRepository _identityRepository;

  CrosschainRepository(
    this._crosschainDataSource,
    this._identityRepository,
  );

  Future<List<MessageWithSignature>> getCrosschainStatesWithSignatures({
    required String universalResolverUrl,
    required List<PublicStatesInfo> stateInfo,
  }) async {
    final requests = <Future<List<ResolverResponse>>>[];
    for (final publicStatesInfo in stateInfo) {
      requests.add(
        _getCrosschainStates(
          universalResolverUrl: universalResolverUrl,
          publicStatesInfo: publicStatesInfo,
        ),
      );
    }

    final responses = await Future.wait(requests);

    final statesWithSignatures = responses.fold(
      <ResolverResponse>[],
      (a, b) => [...a, ...b],
    ).map((m) {
      final proof = m.didResolutionMetadata.proof.first;
      return (
        message: proof.eip712.message,
        signature: proof.proofValue,
      );
    }).toList();

    return statesWithSignatures;
  }

  Future<List<ResolverResponse>> _getCrosschainStates({
    required String universalResolverUrl,
    required PublicStatesInfo publicStatesInfo,
  }) async {
    final responses = <ResolverResponse>[];

    for (final state in publicStatesInfo.states) {
      final didDescription = await _identityRepository.describeId(
        id: BigInt.parse(state.id),
      );

      await _crosschainDataSource.getDidResolution(
        universalResolverUrl: universalResolverUrl,
        did: didDescription.did,
        state: state.state,
      );
    }

    for (final gistState in publicStatesInfo.gists) {
      final didDescription = await _identityRepository.describeId(
        id: BigInt.parse(gistState.id),
      );

      await _crosschainDataSource.getDidResolution(
        universalResolverUrl: universalResolverUrl,
        did: didDescription.did,
        gist: gistState.root,
      );
    }

    return responses;
  }
}
