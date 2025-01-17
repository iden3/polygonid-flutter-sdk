import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:polygonid_flutter_sdk/common/domain/domain_constants.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/env_config_entity.dart';
import 'package:polygonid_flutter_sdk/common/domain/error_exception.dart';
import 'package:polygonid_flutter_sdk/identity/data/data_sources/db_destination_path_data_source.dart';
import 'package:polygonid_flutter_sdk/identity/data/data_sources/encryption_db_data_source.dart';
import 'package:polygonid_flutter_sdk/identity/data/data_sources/lib_pidcore_identity_data_source.dart';
import 'package:polygonid_flutter_sdk/identity/data/data_sources/local_contract_files_data_source.dart';
import 'package:polygonid_flutter_sdk/identity/data/data_sources/remote_identity_data_source.dart';
import 'package:polygonid_flutter_sdk/identity/data/data_sources/rpc_data_source.dart';
import 'package:polygonid_flutter_sdk/identity/data/data_sources/secure_storage_profiles_data_source.dart';
import 'package:polygonid_flutter_sdk/identity/data/data_sources/storage_identity_data_source.dart';
import 'package:polygonid_flutter_sdk/identity/data/data_sources/wallet_data_source.dart';
import 'package:polygonid_flutter_sdk/identity/data/mappers/private_key/private_key_mapper.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/hash_entity.dart';
import 'package:polygonid_flutter_sdk/identity/data/dtos/id_description.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/node_entity.dart';
import 'package:polygonid_flutter_sdk/identity/data/mappers/state_identifier_mapper.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/identity_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/rhs_node_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/exceptions/identity_exceptions.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';
import 'package:poseidon/poseidon.dart';
import 'package:web3dart/crypto.dart';

class IdentityRepositoryImpl extends IdentityRepository {
  final WalletDataSource _walletDataSource;
  final RemoteIdentityDataSource _remoteIdentityDataSource;
  final StorageIdentityDataSource _storageIdentityDataSource;
  final RPCDataSource _rpcDataSource;
  final LocalContractFilesDataSource _localContractFilesDataSource;
  final LibPolygonIdCoreIdentityDataSource _libPolygonIdCoreIdentityDataSource;
  final EncryptionDbDataSource _encryptionDbDataSource;
  final DestinationPathDataSource _destinationPathDataSource;
  final PrivateKeyMapper _privateKeyMapper;
  final StateIdentifierMapper _stateIdentifierMapper;
  final SecureStorageProfilesDataSource _secureStorageProfilesDataSource;

  IdentityRepositoryImpl(
    this._walletDataSource,
    this._remoteIdentityDataSource,
    this._storageIdentityDataSource,
    this._rpcDataSource,
    this._localContractFilesDataSource,
    this._libPolygonIdCoreIdentityDataSource,
    this._encryptionDbDataSource,
    this._destinationPathDataSource,
    this._privateKeyMapper,
    this._stateIdentifierMapper,
    this._secureStorageProfilesDataSource,
  );

  @override
  Future<String> getPrivateKey({required String? secret}) {
    return _walletDataSource
        .createWallet(secret: _privateKeyMapper.mapFrom(secret))
        .then((wallet) => bytesToHex(wallet.privateKey));
  }

  @override
  Future<List<String>> getPublicKeys({required String bjjPrivateKey}) async {
    final wallet = await _walletDataSource.getWallet(
      privateKey: hexToBytes(bjjPrivateKey),
    );
    final pubKeys = wallet.publicKey;
    return pubKeys;
  }

  @override
  Future<NodeEntity> getAuthClaimNode({required List<String> children}) {
    BigInt hashIndex = poseidon4([
      BigInt.parse(children[0]),
      BigInt.parse(children[1]),
      BigInt.parse(children[2]),
      BigInt.parse(children[3]),
    ]);
    BigInt hashValue = poseidon4([
      BigInt.parse(children[4]),
      BigInt.parse(children[5]),
      BigInt.parse(children[6]),
      BigInt.parse(children[7]),
    ]);
    BigInt hashClaimNode = poseidon3([
      hashIndex,
      hashValue,
      BigInt.one,
    ]);
    NodeEntity authClaimNode = NodeEntity(
      children: [
        HashEntity.fromBigInt(hashIndex),
        HashEntity.fromBigInt(hashValue),
        HashEntity.fromBigInt(BigInt.one),
      ],
      hash: HashEntity.fromBigInt(hashClaimNode),
      type: NodeType.leaf,
    );
    return Future.value(authClaimNode);
  }

  @override
  Future<void> storeIdentity({required IdentityEntity identity}) {
    return _storageIdentityDataSource
        .storeIdentity(did: identity.did, identity: identity)
        .catchError(
          (error) => throw IdentityException(
            errorMessage: "Error storing identity with error: $error",
            error: error,
          ),
        );
  }

  /// Get an [IdentityEntity] from an identifier
  /// The [IdentityEntity] is the one previously stored and associated to the identifier
  /// Throws an [UnknownIdentityException] if not found.
  @override
  Future<IdentityEntity> getIdentity({required String genesisDid}) {
    return _storageIdentityDataSource.getIdentity(did: genesisDid).catchError(
          (error) => throw IdentityException(
            errorMessage: "Error getting identity with error: $error",
            error: error,
          ),
          test: (error) => error is! UnknownIdentityException,
        );
  }

  @override
  Future<List<IdentityEntity>> getIdentities() {
    return _storageIdentityDataSource.getIdentities().catchError(
          (error) => throw IdentityException(
            errorMessage: "Error getting identities with error: $error",
            error: error,
          ),
        );
  }

  @override
  Future<void> removeIdentity({required String genesisDid}) {
    return _storageIdentityDataSource.removeIdentity(did: genesisDid);
  }

  /// Sign a message through a privateKey
  ///
  /// Return a signature in hexadecimal format
  @override
  Future<String> signMessage({
    required String privateKey,
    required String message,
  }) async {
    try {
      final Uint8List hexPrivateKey = hexToBytes(privateKey);
      final String signedMessage = await _walletDataSource.signMessage(
        privateKey: hexPrivateKey,
        message: message,
      );
      return signedMessage;
    } on PolygonIdSDKException catch (_) {
      rethrow;
    } catch (error) {
      throw IdentityException(
        errorMessage: "Error signing message with error: $error",
        error: error,
      );
    }
  }

  @override
  Future<String> getState({
    required String identifier,
    required String contractAddress,
  }) {
    return _localContractFilesDataSource
        .loadStateContract(contractAddress)
        .then(
          (contract) => _rpcDataSource
              .getState(_stateIdentifierMapper.mapTo(identifier), contract)
              .catchError(
                (error) => throw FetchIdentityStateException(
                  errorMessage: "Error fetching state with error: $error",
                  error: error,
                ),
              ),
        );
  }

  @override
  Future<RhsNodeEntity> getStateRoots({required String url}) async {
    try {
      final node = await _remoteIdentityDataSource.fetchStateRoots(url: url);
      return node;
    } on PolygonIdSDKException catch (_) {
      rethrow;
    } catch (error) {
      throw FetchStateRootsException(
        errorMessage: "Error fetching state roots with error: $error",
        error: error,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getNonRevProof({
    required String identityState,
    required BigInt nonce,
    required String baseUrl,
    Map<String, dynamic>? cachedNonRevProof,
  }) {
    return _remoteIdentityDataSource
        .getNonRevocationProof(identityState, nonce, baseUrl, cachedNonRevProof)
        .catchError(
          (error) => throw NonRevProofException(
            errorMessage:
                "Error fetching non revocation proof with error: $error",
            error: error,
          ),
        );
  }

  @override
  Future<String> getDidIdentifier({
    required String blockchain,
    required String network,
    required String claimsRoot,
    required BigInt profileNonce,
    required EnvConfigEntity config,
    String? method,
  }) {
    try {
      // Get the genesis id
      final genesisDid = _libPolygonIdCoreIdentityDataSource.calculateGenesisId(
        claimsTreeRoot: claimsRoot,
        blockchain: blockchain,
        network: network,
        config: config.toJson(),
        method: method,
      );

      if (profileNonce == GENESIS_PROFILE_NONCE) {
        return Future.value(genesisDid);
      } else {
        String profileDid = _libPolygonIdCoreIdentityDataSource
            .calculateProfileId(genesisDid, profileNonce);

        return Future.value(profileDid);
      }
    } catch (error) {
      return Future.error(error);
    }
  }

  @override
  Future<String> getEthDidIdentifier({
    required String ethAddress,
    required String blockchain,
    required String network,
    required BigInt profileNonce,
    required EnvConfigEntity config,
    String? method,
  }) async {
    try {
      // Get the genesis id
      final genesisDid =
          _libPolygonIdCoreIdentityDataSource.calculateGenesisIdFromEth(
        ethAddress: ethAddress,
        blockchain: blockchain,
        network: network,
        config: config.toJson(),
        method: method,
      );

      if (profileNonce == GENESIS_PROFILE_NONCE) {
        return Future.value(genesisDid);
      } else {
        String profileDid = _libPolygonIdCoreIdentityDataSource
            .calculateProfileId(genesisDid, profileNonce);

        return Future.value(profileDid);
      }
    } catch (error) {
      return Future.error(error);
    }
  }

  @override
  String getPrivateProfileForGenesisDid({
    required String genesisDid,
    required BigInt profileNonce,
  }) {
    return _libPolygonIdCoreIdentityDataSource.calculateProfileId(
        genesisDid, profileNonce);
  }

  @override
  Future<String> convertIdToBigInt({required String id}) {
    String idBigInt = _libPolygonIdCoreIdentityDataSource.genesisIdToBigInt(id);
    return Future.value(idBigInt);
  }

  @override
  Future<IdDescription> describeId({
    required BigInt id,
    EnvConfigEntity? config,
  }) async {
    final idDescriptionJson = _libPolygonIdCoreIdentityDataSource.describeId(
      idAsInt: id.toString(),
      config: config == null ? null : jsonEncode(config.toJson()),
    );

    return IdDescription.fromJson(jsonDecode(idDescriptionJson));
  }

  @override
  Future<String> exportIdentity({
    required String did,
    required String encryptionKey,
  }) async {
    Map<String, Object?> exportableDb = await _storageIdentityDataSource
        .getIdentityDb(did: did, encryptionKey: encryptionKey);

    final key = Key.fromBase16(encryptionKey);

    return _encryptionDbDataSource.encryptData(
      data: exportableDb,
      key: key,
    );
  }

  @override
  Future<void> importIdentity({
    required String did,
    required String encryptedDb,
    required String encryptionKey,
  }) async {
    final key = Key.fromBase16(encryptionKey);

    Map<String, Object?> decryptedDb = _encryptionDbDataSource.decryptData(
      encryptedData: encryptedDb,
      key: key,
    );

    String destinationPath =
        await _destinationPathDataSource.getDestinationPath(did: did);

    return _storageIdentityDataSource.saveIdentityDb(
      exportableDb: decryptedDb,
      destinationPath: destinationPath,
      encryptionKey: encryptionKey,
    );
  }

  @override
  Future<Map<BigInt, String>> getProfiles({
    required String did,
    required String encryptionKey,
  }) {
    return _secureStorageProfilesDataSource.getProfiles(
      did: did,
      encryptionKey: encryptionKey,
    );
  }

  @override
  Future<void> putProfiles({
    required String did,
    required String encryptionKey,
    required Map<BigInt, String> profiles,
  }) {
    return _secureStorageProfilesDataSource.storeProfiles(
      did: did,
      profiles: profiles,
      encryptionKey: encryptionKey,
    );
  }
}
