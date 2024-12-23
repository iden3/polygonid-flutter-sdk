import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:polygonid_flutter_sdk/common/domain/entities/media_type.dart';
import 'package:polygonid_flutter_sdk/credential/data/data_sources/local_claim_data_source.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/authorization/response/auth_body_response.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/authorization/response/auth_response.dart';
import 'package:polygonid_flutter_sdk/iden3comm/domain/entities/common/iden3_message_entity.dart';
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
import 'package:polygonid_flutter_sdk/identity/domain/entities/identity_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/node_entity.dart';
import 'package:polygonid_flutter_sdk/identity/data/mappers/state_identifier_mapper.dart';
import 'package:polygonid_flutter_sdk/identity/data/repositories/identity_repository_impl.dart';
import 'package:polygonid_flutter_sdk/identity/domain/entities/rhs_node_entity.dart';
import 'package:polygonid_flutter_sdk/identity/domain/exceptions/identity_exceptions.dart';
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart';
import 'package:polygonid_flutter_sdk/identity/libs/bjj/bjj_wallet.dart';
import 'package:web3dart/web3dart.dart';

import '../../../common/common_mocks.dart';
import '../../../common/iden3comm_mocks.dart';
import '../../../common/identity_mocks.dart';
import 'identity_repository_impl_test.mocks.dart';

// Data
class FakeWallet extends Fake implements BjjWallet {
  @override
  Uint8List get privateKey => CommonMocks.aBytes;

  @override
  List<String> get publicKey => CommonMocks.pubKeys;
}

final mockWallet = FakeWallet();
const otherIdentifier = "theOtherIdentifier";
final mockDTO = IdentityEntity(
  did: CommonMocks.identifier,
  publicKey: CommonMocks.pubKeys,
  profiles: CommonMocks.profiles,
);

final mockAuthResponse = AuthResponse(
  id: "id",
  thid: Iden3commMocks.authRequest.thid,
  to: Iden3commMocks.authRequest.from,
  from: CommonMocks.identifier,
  typ: MediaType.PlainMessage.name,
  type: Iden3MessageType.authResponse.name,
  body: AuthBodyResponse(
    message: Iden3commMocks.authRequest.body.message,
    proofs: [],
    did_doc: null,
  ),
);

final rhsNodeDTOs = [
  RhsNodeEntity(
      node: NodeEntity(
        children: const [],
        hash: HashEntity(data: Uint8List(32)),
        type: NodeType.middle,
      ),
      status: ''),
  RhsNodeEntity(
      node: NodeEntity(
        children: const [],
        hash: HashEntity(data: Uint8List(32)),
        type: NodeType.leaf,
      ),
      status: ''),
];
final rhsNodeEntities = [
  RhsNodeEntity(
      node: NodeEntity(
        children: const [],
        hash: HashEntity(data: Uint8List(32)),
        type: NodeType.middle,
      ),
      status: ''),
  RhsNodeEntity(
      node: NodeEntity(
        children: const [],
        hash: HashEntity(data: Uint8List(32)),
        type: NodeType.leaf,
      ),
      status: ''),
];

Response errorResponse = Response("body", 450);

const address = "address";
const abiName = "theABIName";
final DeployedContract contract = DeployedContract(
    ContractAbi(abiName, [const ContractFunction('getState', [])], []),
    EthereumAddress(Uint8List.fromList([
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
    ])));

var identities = [
  IdentityMocks.identityDTO,
  IdentityMocks.identityDTO,
  IdentityMocks.identityDTO,
];
var expectedIdentities = [
  IdentityMocks.identity,
  IdentityMocks.identity,
  IdentityMocks.identity,
];

// Dependencies
MockWalletDataSource walletDataSource = MockWalletDataSource();
MockRemoteIdentityDataSource remoteIdentityDataSource =
    MockRemoteIdentityDataSource();
MockStorageIdentityDataSource storageIdentityDataSource =
    MockStorageIdentityDataSource();
MockRPCDataSource rpcDataSource = MockRPCDataSource();
MockLocalContractFilesDataSource localContractFilesDataSource =
    MockLocalContractFilesDataSource();
MockLibPolygonIdCoreIdentityDataSource libPolygonIdCoreIdentityDataSource =
    MockLibPolygonIdCoreIdentityDataSource();
MockEncryptionDbDataSource encryptionDbDataSource =
    MockEncryptionDbDataSource();
MockDestinationPathDataSource destinationPathDataSource =
    MockDestinationPathDataSource();
MockPrivateKeyMapper privateKeyMapper = MockPrivateKeyMapper();
MockStateIdentifierMapper stateIdentifierMapper = MockStateIdentifierMapper();
MockSecureStorageProfilesDataSource secureStorageProfilesDataSource =
    MockSecureStorageProfilesDataSource();

// Tested instance
IdentityRepository repository = IdentityRepositoryImpl(
  walletDataSource,
  remoteIdentityDataSource,
  storageIdentityDataSource,
  rpcDataSource,
  localContractFilesDataSource,
  libPolygonIdCoreIdentityDataSource,
  encryptionDbDataSource,
  destinationPathDataSource,
  privateKeyMapper,
  stateIdentifierMapper,
  secureStorageProfilesDataSource,
);

@GenerateMocks([
  WalletDataSource,
  RemoteIdentityDataSource,
  StorageIdentityDataSource,
  RPCDataSource,
  LocalContractFilesDataSource,
  LocalClaimDataSource,
  LibPolygonIdCoreIdentityDataSource,
  EncryptionDbDataSource,
  DestinationPathDataSource,
  PrivateKeyMapper,
  StateIdentifierMapper,
  SecureStorageProfilesDataSource,
])
void main() {
  group("Sign message", () {
    setUp(() {
      reset(walletDataSource);
      reset(privateKeyMapper);

      // Given
      when(walletDataSource.signMessage(
              privateKey: anyNamed('privateKey'), message: anyNamed('message')))
          .thenAnswer((realInvocation) => Future.value(CommonMocks.signature));
    });

    test(
        "Given a privateKey and a message, when I call signMessage, then I expect a signature as a String to be returned",
        () async {
      // When
      expect(
          await repository.signMessage(
              privateKey: CommonMocks.privateKey, message: CommonMocks.message),
          CommonMocks.signature);

      // Then
      var signCaptured = verify(walletDataSource.signMessage(
              privateKey: captureAnyNamed('privateKey'),
              message: captureAnyNamed('message')))
          .captured;
      expect(signCaptured[0], [0, 0, 0]);
      expect(signCaptured[1], CommonMocks.message);
    });

    test(
        "Given a privateKey and a message, when I call signMessage and an error occurred, then I expect an IdentityException to be thrown",
        () async {
      // Given
      when(walletDataSource.signMessage(
              privateKey: anyNamed('privateKey'), message: anyNamed('message')))
          .thenAnswer((realInvocation) => Future.error(CommonMocks.exception));

      // When
      await repository
          .signMessage(
              privateKey: CommonMocks.privateKey, message: CommonMocks.message)
          .then((_) => null)
          .catchError((error) {
        expect(error, isA<IdentityException>());
        expect(error.error, CommonMocks.exception);
      });

      // Then
      var signCaptured = verify(walletDataSource.signMessage(
              privateKey: captureAnyNamed('privateKey'),
              message: captureAnyNamed('message')))
          .captured;
      expect(signCaptured[0], [0, 0, 0]);
      expect(signCaptured[1], CommonMocks.message);
    });
  });

  group("Remove identity", () {
    test(
        "Given an identifier, when I call removeIdentity, then I expect the process to complete",
        () async {
      // Given
      when(storageIdentityDataSource.removeIdentity(did: anyNamed('did')))
          .thenAnswer((realInvocation) => Future.value());

      // When
      await expectLater(
          repository.removeIdentity(genesisDid: CommonMocks.did), completes);

      // Then
      expect(
          verify(storageIdentityDataSource.removeIdentity(
                  did: captureAnyNamed('did')))
              .captured
              .first,
          CommonMocks.did);
    });

    test(
        "Given an identifier, when I call removeIdentity and an error occurred, then I expect an error to be thrown",
        () async {
      // Given
      when(storageIdentityDataSource.removeIdentity(did: anyNamed('did')))
          .thenAnswer((realInvocation) => Future.error(CommonMocks.exception));

      // When
      await expectLater(repository.removeIdentity(genesisDid: CommonMocks.did),
          throwsA(CommonMocks.exception));

      // Then
      expect(
          verify(storageIdentityDataSource.removeIdentity(
                  did: captureAnyNamed('did')))
              .captured
              .first,
          CommonMocks.did);
    });
  });

  group("Get Identity State", () {
    setUp(() {
      reset(rpcDataSource);

      // Given
      when(localContractFilesDataSource.loadStateContract(any))
          .thenAnswer((realInvocation) => Future.value(contract));
      when(stateIdentifierMapper.mapTo(any))
          .thenAnswer((realInvocation) => CommonMocks.id);
      when(rpcDataSource.getState(any, any))
          .thenAnswer((realInvocation) => Future.value(CommonMocks.state));
    });

    test(
        "Given parameters, when I call getState, then I expect a string to be returned",
        () async {
      // When
      expect(
          await repository.getState(
              identifier: CommonMocks.identifier, contractAddress: address),
          CommonMocks.state);

      // Then
      expect(
          verify(localContractFilesDataSource.loadStateContract(captureAny))
              .captured
              .first,
          address);
      expect(verify(stateIdentifierMapper.mapTo(captureAny)).captured.first,
          CommonMocks.identifier);
      var getStateCaptured =
          verify(rpcDataSource.getState(captureAny, captureAny)).captured;

      expect(getStateCaptured[0], CommonMocks.id);
      expect(getStateCaptured[1], contract);
    });

    test(
        "Given parameters, when I call getState and an error occured, then I expect an exception to be thrown",
        () async {
      // Given
      when(rpcDataSource.getState(any, any))
          .thenAnswer((realInvocation) => Future.error(CommonMocks.exception));

      // When
      await repository
          .getState(
              identifier: CommonMocks.identifier, contractAddress: address)
          .then((_) => expect(true, false))
          .catchError((error) {
        expect(error, isA<FetchIdentityStateException>());
        expect(error.error, CommonMocks.exception);
      });

      // Then
      expect(
          verify(localContractFilesDataSource.loadStateContract(captureAny))
              .captured
              .first,
          address);
      expect(verify(stateIdentifierMapper.mapTo(captureAny)).captured.first,
          CommonMocks.identifier);
      var getStateCaptured =
          verify(rpcDataSource.getState(captureAny, captureAny)).captured;

      expect(getStateCaptured[0], CommonMocks.id);
      expect(getStateCaptured[1], contract);
    });
  });

  group("Get State Roots", () {
    setUp(() {
      reset(remoteIdentityDataSource);

      // Given
      when(remoteIdentityDataSource.fetchStateRoots(url: anyNamed('url')))
          .thenAnswer((realInvocation) => Future.value(rhsNodeDTOs[0]));
    });
  });

  group("Get non revocation proof", () {
    test(
        "Given parameters, when I call getNonRevProof, then I expect a Map to be returned",
        () async {
      // Given
      when(remoteIdentityDataSource.getNonRevocationProof(any, any, any, any))
          .thenAnswer((realInvocation) => Future.value(CommonMocks.aMap));

      // When
      expect(
          await repository.getNonRevProof(
              identityState: CommonMocks.state,
              nonce: CommonMocks.nonce,
              baseUrl: CommonMocks.url),
          CommonMocks.aMap);

      // Then
      var fetchCaptured = verify(remoteIdentityDataSource.getNonRevocationProof(
              captureAny, captureAny, captureAny, captureAny))
          .captured;

      expect(fetchCaptured[0], CommonMocks.state);
      expect(fetchCaptured[1], CommonMocks.nonce);
      expect(fetchCaptured[2], CommonMocks.url);
    });

    test(
        "Given parameters, when I call getNonRevProof and an error occurred, then I expect a NonRevProofException to be thrown",
        () async {
      // Given
      when(remoteIdentityDataSource.getNonRevocationProof(any, any, any, any))
          .thenAnswer((realInvocation) => Future.error(CommonMocks.exception));

      // When
      await repository
          .getNonRevProof(
              identityState: CommonMocks.state,
              nonce: CommonMocks.nonce,
              baseUrl: CommonMocks.url)
          .then((_) => expect(true, false))
          .catchError((error) {
        expect(error, isA<NonRevProofException>());
        expect(error.error, CommonMocks.exception);
      });

      // Then
      var fetchCaptured = verify(remoteIdentityDataSource.getNonRevocationProof(
              captureAny, captureAny, captureAny, captureAny))
          .captured;

      expect(fetchCaptured[0], CommonMocks.state);
      expect(fetchCaptured[1], CommonMocks.nonce);
      expect(fetchCaptured[2], CommonMocks.url);
    });
  });

  group("Get did identifier", () {
    setUp(() {
      // Given
      when(
        libPolygonIdCoreIdentityDataSource.calculateGenesisId(
          claimsTreeRoot: anyNamed('claimsTreeRoot'),
          blockchain: anyNamed('blockchain'),
          network: anyNamed('network'),
          config: anyNamed('config'),
          method: anyNamed('method'),
        ),
      ).thenReturn(CommonMocks.did);
      when(libPolygonIdCoreIdentityDataSource.calculateProfileId(any, any))
          .thenReturn(CommonMocks.did);
    });

    test(
        "Given parameters without profileNonce, when I call getDidIdentifier, then I expect a String to be returned",
        () async {
      // When
      expect(
          await repository.getDidIdentifier(
            blockchain: CommonMocks.blockchain,
            network: CommonMocks.network,
            claimsRoot: CommonMocks.message,
            profileNonce: CommonMocks.genesisNonce,
            config: CommonMocks.envConfig,
            method: CommonMocks.method,
          ),
          CommonMocks.did);

      // Then
      var captureCalculate =
          verify(libPolygonIdCoreIdentityDataSource.calculateGenesisId(
        claimsTreeRoot: captureAnyNamed('claimsTreeRoot'),
        blockchain: captureAnyNamed('blockchain'),
        network: captureAnyNamed('network'),
        config: captureAnyNamed('config'),
        method: captureAnyNamed('method'),
      )).captured;

      expect(captureCalculate[0], CommonMocks.message);
      expect(captureCalculate[1], CommonMocks.blockchain);
      expect(captureCalculate[2], CommonMocks.network);

      verifyNever(libPolygonIdCoreIdentityDataSource.calculateProfileId(
          captureAny, captureAny));
    });

    test(
        "Given parameters with a profileNonce, when I call getDidIdentifier, then I expect a String to be returned",
        () async {
      // When
      expect(
          await repository.getDidIdentifier(
            blockchain: CommonMocks.blockchain,
            network: CommonMocks.network,
            claimsRoot: CommonMocks.message,
            profileNonce: CommonMocks.nonce,
            config: CommonMocks.envConfig,
            method: CommonMocks.method,
          ),
          CommonMocks.did);

      // Then
      var captureCalculate =
          verify(libPolygonIdCoreIdentityDataSource.calculateGenesisId(
        claimsTreeRoot: captureAnyNamed('claimsTreeRoot'),
        blockchain: captureAnyNamed('blockchain'),
        network: captureAnyNamed('network'),
        config: captureAnyNamed('config'),
        method: captureAnyNamed('method'),
      )).captured;
      expect(captureCalculate[0], CommonMocks.message);
      expect(captureCalculate[1], CommonMocks.blockchain);
      expect(captureCalculate[2], CommonMocks.network);

      var captureCalculateProfile = verify(libPolygonIdCoreIdentityDataSource
              .calculateProfileId(captureAny, captureAny))
          .captured;
      expect(captureCalculateProfile[0], CommonMocks.did);
      expect(captureCalculateProfile[1], CommonMocks.nonce);
    });

    test(
        "Given parameters with a profileNonce, when I call getDidIdentifier and an error occurred, then I expect an exception to be thrown",
        () async {
      // Given
      when(libPolygonIdCoreIdentityDataSource.calculateGenesisId(
        claimsTreeRoot: anyNamed('claimsTreeRoot'),
        blockchain: anyNamed('blockchain'),
        network: anyNamed('network'),
        config: anyNamed('config'),
        method: anyNamed('method'),
      )).thenThrow(CommonMocks.exception);

      // When
      await expectLater(
          repository.getDidIdentifier(
            blockchain: CommonMocks.blockchain,
            network: CommonMocks.network,
            claimsRoot: CommonMocks.message,
            profileNonce: CommonMocks.nonce,
            config: CommonMocks.envConfig,
            method: CommonMocks.method,
          ),
          throwsA(CommonMocks.exception));

      // Then
      var captureCalculate =
          verify(libPolygonIdCoreIdentityDataSource.calculateGenesisId(
        claimsTreeRoot: captureAnyNamed('claimsTreeRoot'),
        blockchain: captureAnyNamed('blockchain'),
        network: captureAnyNamed('network'),
        config: captureAnyNamed('config'),
        method: captureAnyNamed('method'),
      )).captured;
      expect(captureCalculate[0], CommonMocks.message);
      expect(captureCalculate[1], CommonMocks.blockchain);
      expect(captureCalculate[2], CommonMocks.network);

      verifyNever(libPolygonIdCoreIdentityDataSource.calculateProfileId(
          captureAny, captureAny));
    });
  });

  group("Export identity", () {
    setUp(() {
      // Given
      when(storageIdentityDataSource.getIdentityDb(
              did: anyNamed('did'), privateKey: anyNamed('privateKey')))
          .thenAnswer((realInvocation) => Future.value(CommonMocks.aMap));
      when(encryptionDbDataSource.encryptData(
              data: anyNamed('data'), key: anyNamed('key')))
          .thenReturn(CommonMocks.message);
    });

    test(
        "Given params, when I call exportIdentity, then I expect a String to be returned",
        () async {
      // When
      expect(
          await repository.exportIdentity(
              did: CommonMocks.did, privateKey: CommonMocks.privateKey),
          CommonMocks.message);

      // Then
      var captureIdentity = verify(storageIdentityDataSource.getIdentityDb(
              did: captureAnyNamed('did'),
              privateKey: captureAnyNamed('privateKey')))
          .captured;
      expect(captureIdentity[0], CommonMocks.did);
      expect(captureIdentity[1], CommonMocks.privateKey);

      var captureEncrypt = verify(encryptionDbDataSource.encryptData(
              data: captureAnyNamed('data'), key: captureAnyNamed('key')))
          .captured;
      expect(captureEncrypt[0], CommonMocks.aMap);
      expect(captureEncrypt[1], CommonMocks.key);
    });

    test(
        "Given params, when I call exportIdentity and a error occurred, then I expect an exception to be thrown",
        () async {
      // Given
      when(storageIdentityDataSource.getIdentityDb(
              did: anyNamed('did'), privateKey: anyNamed('privateKey')))
          .thenThrow(CommonMocks.exception);

      // When
      try {
        await repository.exportIdentity(
            did: CommonMocks.did, privateKey: CommonMocks.privateKey);
      } catch (error) {
        expect(error, CommonMocks.exception);
      }

      // Then
      var captureIdentity = verify(storageIdentityDataSource.getIdentityDb(
              did: captureAnyNamed('did'),
              privateKey: captureAnyNamed('privateKey')))
          .captured;
      expect(captureIdentity[0], CommonMocks.did);
      expect(captureIdentity[1], CommonMocks.privateKey);

      verifyNever(encryptionDbDataSource.encryptData(
          data: captureAnyNamed('data'), key: captureAnyNamed('key')));
    });
  });

  group("Import identity", () {
    setUp(() {
      // Given
      when(destinationPathDataSource.getDestinationPath(did: anyNamed('did')))
          .thenAnswer((realInvocation) => Future.value(CommonMocks.name));
      when(encryptionDbDataSource.decryptData(
              encryptedData: anyNamed('encryptedData'), key: anyNamed('key')))
          .thenReturn(CommonMocks.aMap);
      when(storageIdentityDataSource.saveIdentityDb(
              exportableDb: anyNamed('exportableDb'),
              destinationPath: anyNamed('destinationPath'),
              privateKey: anyNamed('privateKey')))
          .thenAnswer((realInvocation) => Future.value());
    });

    test(
        "Given params, when I call exportIdentity, then I expect a String to be returned",
        () async {
      // When
      await expectLater(
          repository.importIdentity(
              did: CommonMocks.did,
              privateKey: CommonMocks.privateKey,
              encryptedDb: CommonMocks.message),
          completes);

      // Then
      var captureDecrypt = verify(encryptionDbDataSource.decryptData(
              encryptedData: captureAnyNamed('encryptedData'),
              key: captureAnyNamed('key')))
          .captured;
      expect(captureDecrypt[0], CommonMocks.message);
      expect(captureDecrypt[1], CommonMocks.key);

      var captureSave = verify(storageIdentityDataSource.saveIdentityDb(
              exportableDb: captureAnyNamed('exportableDb'),
              destinationPath: captureAnyNamed('destinationPath'),
              privateKey: captureAnyNamed('privateKey')))
          .captured;
      expect(captureSave[0], CommonMocks.aMap);
      expect(captureSave[1], CommonMocks.name);
      expect(captureSave[2], CommonMocks.privateKey);
    });

    test(
        "Given params, when I call exportIdentity and an error occurred, then I expect an exception to be thrown",
        () async {
      // Given
      when(destinationPathDataSource.getDestinationPath(did: anyNamed('did')))
          .thenAnswer((realInvocation) => Future.error(CommonMocks.exception));

      // When
      try {
        await repository.importIdentity(
            did: CommonMocks.did,
            privateKey: CommonMocks.privateKey,
            encryptedDb: CommonMocks.message);
      } catch (error) {
        expect(error, CommonMocks.exception);
      }

      // Then
      var captureDecrypt = verify(encryptionDbDataSource.decryptData(
              encryptedData: captureAnyNamed('encryptedData'),
              key: captureAnyNamed('key')))
          .captured;
      expect(captureDecrypt[0], CommonMocks.message);
      expect(captureDecrypt[1], CommonMocks.key);

      verifyNever(storageIdentityDataSource.saveIdentityDb(
          exportableDb: captureAnyNamed('exportableDb'),
          destinationPath: captureAnyNamed('destinationPath'),
          privateKey: captureAnyNamed('privateKey')));
    });
  });
}
