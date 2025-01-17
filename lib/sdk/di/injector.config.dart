// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i497;

import 'package:archive/archive.dart' as _i71;
import 'package:dio/dio.dart' as _i361;
import 'package:encrypt/encrypt.dart' as _i890;
import 'package:flutter/services.dart' as _i281;
import 'package:get_it/get_it.dart' as _i174;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;
import 'package:logger/logger.dart' as _i974;
import 'package:package_info_plus/package_info_plus.dart' as _i655;
import 'package:polygonid_flutter_sdk/common/data/data_sources/mappers/filter_mapper.dart'
    as _i325;
import 'package:polygonid_flutter_sdk/common/data/data_sources/mappers/filters_mapper.dart'
    as _i461;
import 'package:polygonid_flutter_sdk/common/data/data_sources/storage_key_value_data_source.dart'
    as _i525;
import 'package:polygonid_flutter_sdk/common/domain/domain_logger.dart'
    as _i1041;
import 'package:polygonid_flutter_sdk/common/domain/repositories/config_repository.dart'
    as _i415;
import 'package:polygonid_flutter_sdk/common/domain/use_cases/get_env_use_case.dart'
    as _i626;
import 'package:polygonid_flutter_sdk/common/domain/use_cases/get_package_name_use_case.dart'
    as _i295;
import 'package:polygonid_flutter_sdk/common/domain/use_cases/get_selected_chain_use_case.dart'
    as _i737;
import 'package:polygonid_flutter_sdk/common/domain/use_cases/set_env_use_case.dart'
    as _i924;
import 'package:polygonid_flutter_sdk/common/domain/use_cases/set_selected_chain_use_case.dart'
    as _i438;
import 'package:polygonid_flutter_sdk/common/infrastructure/stacktrace_stream_manager.dart'
    as _i267;
import 'package:polygonid_flutter_sdk/common/libs/polygonidcore/pidcore_base.dart'
    as _i393;
import 'package:polygonid_flutter_sdk/credential/data/credential_repository_impl.dart'
    as _i550;
import 'package:polygonid_flutter_sdk/credential/data/data_sources/cache_claim_data_source.dart'
    as _i272;
import 'package:polygonid_flutter_sdk/credential/data/data_sources/lib_pidcore_credential_data_source.dart'
    as _i758;
import 'package:polygonid_flutter_sdk/credential/data/data_sources/local_claim_data_source.dart'
    as _i969;
import 'package:polygonid_flutter_sdk/credential/data/data_sources/remote_claim_data_source.dart'
    as _i62;
import 'package:polygonid_flutter_sdk/credential/data/data_sources/storage_claim_data_source.dart'
    as _i738;
import 'package:polygonid_flutter_sdk/credential/data/mappers/claim_info_mapper.dart'
    as _i894;
import 'package:polygonid_flutter_sdk/credential/data/mappers/claim_mapper.dart'
    as _i294;
import 'package:polygonid_flutter_sdk/credential/data/mappers/claim_state_mapper.dart'
    as _i497;
import 'package:polygonid_flutter_sdk/credential/data/mappers/display_type_mapper.dart'
    as _i590;
import 'package:polygonid_flutter_sdk/credential/domain/repositories/credential_repository.dart'
    as _i309;
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/add_did_profile_info_use_case.dart'
    as _i893;
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/cache_credential_use_case.dart'
    as _i348;
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/cache_credentials_use_case.dart'
    as _i500;
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/generate_non_rev_proof_use_case.dart'
    as _i40;
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/get_claim_revocation_nonce_use_case.dart'
    as _i53;
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/get_claim_revocation_status_use_case.dart'
    as _i610;
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/get_claims_use_case.dart'
    as _i657;
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/get_credential_by_id_use_case.dart'
    as _i227;
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/get_credential_by_partial_id_use_case.dart'
    as _i158;
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/get_did_profile_info_list_use_case.dart'
    as _i108;
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/get_did_profile_info_use_case.dart'
    as _i616;
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/get_non_rev_proof_use_case.dart'
    as _i660;
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/refresh_credential_use_case.dart'
    as _i143;
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/remove_all_claims_use_case.dart'
    as _i503;
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/remove_claims_use_case.dart'
    as _i958;
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/remove_did_profile_info_use_case.dart'
    as _i646;
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/save_claims_use_case.dart'
    as _i635;
import 'package:polygonid_flutter_sdk/credential/domain/use_cases/update_claim_use_case.dart'
    as _i168;
import 'package:polygonid_flutter_sdk/credential/libs/polygonidcore/pidcore_credential.dart'
    as _i328;
import 'package:polygonid_flutter_sdk/iden3comm/data/data_sources/iden3_message_data_source.dart'
    as _i296;
import 'package:polygonid_flutter_sdk/iden3comm/data/data_sources/remote_iden3comm_data_source.dart'
    as _i409;
import 'package:polygonid_flutter_sdk/iden3comm/data/data_sources/secure_storage_did_profile_info_data_source.dart'
    as _i361;
import 'package:polygonid_flutter_sdk/iden3comm/data/data_sources/secure_storage_interaction_data_source.dart'
    as _i425;
import 'package:polygonid_flutter_sdk/iden3comm/data/data_sources/storage_interaction_data_source.dart'
    as _i57;
import 'package:polygonid_flutter_sdk/iden3comm/data/mappers/interaction_mapper.dart'
    as _i1026;
import 'package:polygonid_flutter_sdk/iden3comm/data/mappers/jwz_mapper.dart'
    as _i98;
import 'package:polygonid_flutter_sdk/iden3comm/data/mappers/proof_request_filters_mapper.dart'
    as _i96;
import 'package:polygonid_flutter_sdk/iden3comm/data/repositories/did_profile_info_repository_impl.dart'
    as _i66;
import 'package:polygonid_flutter_sdk/iden3comm/data/repositories/iden3comm_credential_repository_impl.dart'
    as _i910;
import 'package:polygonid_flutter_sdk/iden3comm/data/repositories/iden3comm_repository_impl.dart'
    as _i588;
import 'package:polygonid_flutter_sdk/iden3comm/data/repositories/interaction_repository_impl.dart'
    as _i548;
import 'package:polygonid_flutter_sdk/iden3comm/domain/repositories/did_profile_info_repository.dart'
    as _i258;
import 'package:polygonid_flutter_sdk/iden3comm/domain/repositories/iden3comm_credential_repository.dart'
    as _i698;
import 'package:polygonid_flutter_sdk/iden3comm/domain/repositories/iden3comm_repository.dart'
    as _i88;
import 'package:polygonid_flutter_sdk/iden3comm/domain/repositories/interaction_repository.dart'
    as _i1012;
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/authenticate_use_case.dart'
    as _i411;
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/check_profile_and_did_current_env.dart'
    as _i505;
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/clean_schema_cache_use_case.dart'
    as _i359;
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/fetch_and_save_claims_use_case.dart'
    as _i102;
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/fetch_credentials_use_case.dart'
    as _i709;
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/fetch_onchain_claim_use_case.dart'
    as _i1054;
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/fetch_onchain_claims_use_case.dart'
    as _i146;
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/fetch_schema_use_case.dart'
    as _i238;
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/generate_iden3comm_proof_use_case.dart'
    as _i340;
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_auth_challenge_use_case.dart'
    as _i734;
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_auth_inputs_use_case.dart'
    as _i114;
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_auth_token_use_case.dart'
    as _i871;
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_fetch_requests_use_case.dart'
    as _i968;
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_filters_use_case.dart'
    as _i539;
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_iden3comm_claims_rev_nonce_use_case.dart'
    as _i369;
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_iden3comm_claims_use_case.dart'
    as _i347;
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_iden3comm_proofs_use_case.dart'
    as _i412;
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_iden3message_use_case.dart'
    as _i897;
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_jwz_use_case.dart'
    as _i249;
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_proof_query_context_use_case.dart'
    as _i631;
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_proof_requests_use_case.dart'
    as _i627;
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/get_schemas_use_case.dart'
    as _i233;
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/interaction/add_interaction_use_case.dart'
    as _i1031;
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/interaction/get_interactions_use_case.dart'
    as _i484;
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/interaction/remove_interactions_use_case.dart'
    as _i975;
import 'package:polygonid_flutter_sdk/iden3comm/domain/use_cases/interaction/update_interaction_use_case.dart'
    as _i989;
import 'package:polygonid_flutter_sdk/identity/data/data_sources/db_destination_path_data_source.dart'
    as _i938;
import 'package:polygonid_flutter_sdk/identity/data/data_sources/encryption_db_data_source.dart'
    as _i200;
import 'package:polygonid_flutter_sdk/identity/data/data_sources/lib_pidcore_identity_data_source.dart'
    as _i136;
import 'package:polygonid_flutter_sdk/identity/data/data_sources/local_contract_files_data_source.dart'
    as _i22;
import 'package:polygonid_flutter_sdk/identity/data/data_sources/remote_identity_data_source.dart'
    as _i839;
import 'package:polygonid_flutter_sdk/identity/data/data_sources/rpc_data_source.dart'
    as _i873;
import 'package:polygonid_flutter_sdk/identity/data/data_sources/secure_storage_profiles_data_source.dart'
    as _i232;
import 'package:polygonid_flutter_sdk/identity/data/data_sources/smt_data_source.dart'
    as _i575;
import 'package:polygonid_flutter_sdk/identity/data/data_sources/storage_identity_data_source.dart'
    as _i995;
import 'package:polygonid_flutter_sdk/identity/data/data_sources/storage_smt_data_source.dart'
    as _i42;
import 'package:polygonid_flutter_sdk/identity/data/data_sources/wallet_data_source.dart'
    as _i383;
import 'package:polygonid_flutter_sdk/identity/data/mappers/node_type_entity_mapper.dart'
    as _i307;
import 'package:polygonid_flutter_sdk/identity/data/mappers/private_key/private_key_hex_mapper.dart'
    as _i180;
import 'package:polygonid_flutter_sdk/identity/data/mappers/private_key/private_key_mapper.dart'
    as _i526;
import 'package:polygonid_flutter_sdk/identity/data/mappers/private_key/private_key_symbols_mapper.dart'
    as _i168;
import 'package:polygonid_flutter_sdk/identity/data/mappers/q_mapper.dart'
    as _i599;
import 'package:polygonid_flutter_sdk/identity/data/mappers/state_identifier_mapper.dart'
    as _i720;
import 'package:polygonid_flutter_sdk/identity/data/repositories/identity_repository_impl.dart'
    as _i393;
import 'package:polygonid_flutter_sdk/identity/data/repositories/smt_repository_impl.dart'
    as _i328;
import 'package:polygonid_flutter_sdk/identity/domain/repositories/identity_repository.dart'
    as _i26;
import 'package:polygonid_flutter_sdk/identity/domain/repositories/smt_repository.dart'
    as _i946;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/fetch_identity_state_use_case.dart'
    as _i484;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/fetch_state_roots_use_case.dart'
    as _i172;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_current_env_did_identifier_use_case.dart'
    as _i675;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_did_identifier_use_case.dart'
    as _i732;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_did_use_case.dart'
    as _i78;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_genesis_state_use_case.dart'
    as _i1042;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_identity_auth_claim_use_case.dart'
    as _i392;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_latest_state_use_case.dart'
    as _i754;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/get_public_keys_use_case.dart'
    as _i166;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/add_identity_use_case.dart'
    as _i561;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/add_new_identity_use_case.dart'
    as _i279;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/backup_identity_use_case.dart'
    as _i133;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/check_identity_validity_use_case.dart'
    as _i548;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/create_identity_use_case.dart'
    as _i845;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/get_identities_use_case.dart'
    as _i348;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/get_identity_use_case.dart'
    as _i743;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/get_private_key_use_case.dart'
    as _i665;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/remove_identity_use_case.dart'
    as _i668;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/restore_identity_use_case.dart'
    as _i11;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/sign_message_use_case.dart'
    as _i449;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/identity/update_identity_use_case.dart'
    as _i816;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/profile/add_profile_use_case.dart'
    as _i1050;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/profile/check_profile_validity_use_case.dart'
    as _i192;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/profile/create_profiles_use_case.dart'
    as _i266;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/profile/get_profiles_use_case.dart'
    as _i561;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/profile/remove_profile_use_case.dart'
    as _i829;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/profile/restore_profiles_use_case.dart'
    as _i657;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/smt/create_identity_state_use_case.dart'
    as _i798;
import 'package:polygonid_flutter_sdk/identity/domain/use_cases/smt/remove_identity_state_use_case.dart'
    as _i1009;
import 'package:polygonid_flutter_sdk/identity/libs/bjj/bjj.dart' as _i80;
import 'package:polygonid_flutter_sdk/identity/libs/polygonidcore/pidcore_identity.dart'
    as _i852;
import 'package:polygonid_flutter_sdk/proof/data/data_sources/circuits_download_data_source.dart'
    as _i352;
import 'package:polygonid_flutter_sdk/proof/data/data_sources/circuits_files_data_source.dart'
    as _i540;
import 'package:polygonid_flutter_sdk/proof/data/data_sources/gist_mtproof_data_source.dart'
    as _i694;
import 'package:polygonid_flutter_sdk/proof/data/data_sources/lib_pidcore_proof_data_source.dart'
    as _i41;
import 'package:polygonid_flutter_sdk/proof/data/data_sources/proof_circuit_data_source.dart'
    as _i1021;
import 'package:polygonid_flutter_sdk/proof/data/data_sources/prover_lib_data_source.dart'
    as _i502;
import 'package:polygonid_flutter_sdk/proof/data/data_sources/witness_data_source.dart'
    as _i1039;
import 'package:polygonid_flutter_sdk/proof/data/repositories/proof_repository_impl.dart'
    as _i581;
import 'package:polygonid_flutter_sdk/proof/domain/repositories/proof_repository.dart'
    as _i341;
import 'package:polygonid_flutter_sdk/proof/domain/use_cases/cancel_download_circuits_use_case.dart'
    as _i394;
import 'package:polygonid_flutter_sdk/proof/domain/use_cases/circuits_files_exist_use_case.dart'
    as _i991;
import 'package:polygonid_flutter_sdk/proof/domain/use_cases/download_circuits_use_case.dart'
    as _i570;
import 'package:polygonid_flutter_sdk/proof/domain/use_cases/generate_zkproof_use_case.dart'
    as _i746;
import 'package:polygonid_flutter_sdk/proof/domain/use_cases/get_gist_mtproof_use_case.dart'
    as _i344;
import 'package:polygonid_flutter_sdk/proof/domain/use_cases/is_proof_circuit_supported_use_case.dart'
    as _i735;
import 'package:polygonid_flutter_sdk/proof/domain/use_cases/load_circuit_use_case.dart'
    as _i660;
import 'package:polygonid_flutter_sdk/proof/domain/use_cases/prove_use_case.dart'
    as _i310;
import 'package:polygonid_flutter_sdk/proof/infrastructure/proof_generation_stream_manager.dart'
    as _i920;
import 'package:polygonid_flutter_sdk/proof/libs/polygonidcore/pidcore_proof.dart'
    as _i961;
import 'package:polygonid_flutter_sdk/sdk/credential.dart' as _i501;
import 'package:polygonid_flutter_sdk/sdk/di/injector.dart' as _i335;
import 'package:polygonid_flutter_sdk/sdk/error_handling.dart' as _i795;
import 'package:polygonid_flutter_sdk/sdk/iden3comm.dart' as _i500;
import 'package:polygonid_flutter_sdk/sdk/identity.dart' as _i17;
import 'package:polygonid_flutter_sdk/sdk/polygon_id_sdk.dart' as _i189;
import 'package:polygonid_flutter_sdk/sdk/polygonid_flutter_channel.dart'
    as _i608;
import 'package:polygonid_flutter_sdk/sdk/proof.dart' as _i445;
import 'package:sembast/sembast.dart' as _i310;
import 'package:web3dart/web3dart.dart' as _i641;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt $initSDKGetIt({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final loggerModule = _$LoggerModule();
    final channelModule = _$ChannelModule();
    final networkModule = _$NetworkModule();
    final filesManagerModule = _$FilesManagerModule();
    final platformModule = _$PlatformModule();
    final databaseModule = _$DatabaseModule();
    final encryptionModule = _$EncryptionModule();
    final repositoriesModule = _$RepositoriesModule();
    gh.factory<_i502.ProverLibDataSource>(() => _i502.ProverLibDataSource());
    gh.factory<_i1039.WitnessDataSource>(() => _i1039.WitnessDataSource());
    gh.factory<_i694.GistMTProofDataSource>(
        () => _i694.GistMTProofDataSource());
    gh.factory<_i1021.ProofCircuitDataSource>(
        () => _i1021.ProofCircuitDataSource());
    gh.factory<_i894.ClaimInfoMapper>(() => _i894.ClaimInfoMapper());
    gh.factory<_i497.ClaimStateMapper>(() => _i497.ClaimStateMapper());
    gh.factory<_i590.DisplayTypeMapper>(() => _i590.DisplayTypeMapper());
    gh.factory<_i80.BabyjubjubLib>(() => _i80.BabyjubjubLib());
    gh.factory<_i383.WalletLibWrapper>(() => _i383.WalletLibWrapper());
    gh.factory<_i200.EncryptionDbDataSource>(
        () => _i200.EncryptionDbDataSource());
    gh.factory<_i938.CreatePathWrapper>(() => _i938.CreatePathWrapper());
    gh.factory<_i22.LocalContractFilesDataSource>(
        () => _i22.LocalContractFilesDataSource());
    gh.factory<_i599.QMapper>(() => _i599.QMapper());
    gh.factory<_i720.StateIdentifierMapper>(
        () => _i720.StateIdentifierMapper());
    gh.factory<_i180.PrivateKeyHexMapper>(() => _i180.PrivateKeyHexMapper());
    gh.factory<_i307.NodeTypeEntityMapper>(() => _i307.NodeTypeEntityMapper());
    gh.factory<_i192.CheckProfileValidityUseCase>(
        () => _i192.CheckProfileValidityUseCase());
    gh.factory<_i78.GetDidUseCase>(() => _i78.GetDidUseCase());
    gh.factory<_i393.PolygonIdCore>(() => _i393.PolygonIdCore());
    gh.factory<_i325.FilterMapper>(() => _i325.FilterMapper());
    gh.factory<_i974.Logger>(() => loggerModule.logger);
    gh.factory<_i1041.PolygonIdSdkLogger>(() => loggerModule.sdkLogger);
    gh.factory<_i189.PolygonIdSdk>(() => channelModule.polygonIdSdk);
    gh.factory<_i519.Client>(() => networkModule.client);
    gh.factory<_i361.Dio>(() => networkModule.dio);
    gh.factoryAsync<_i497.Directory>(
        () => filesManagerModule.applicationDocumentsDirectory);
    gh.factory<_i71.ZipDecoder>(() => filesManagerModule.zipDecoder());
    gh.factory<_i1026.InteractionMapper>(() => _i1026.InteractionMapper());
    gh.factory<_i968.GetFetchRequestsUseCase>(
        () => _i968.GetFetchRequestsUseCase());
    gh.lazySingleton<_i920.ProofGenerationStepsStreamManager>(
        () => _i920.ProofGenerationStepsStreamManager());
    gh.lazySingleton<_i267.StacktraceManager>(() => _i267.StacktraceManager());
    gh.lazySingleton<_i281.MethodChannel>(() => channelModule.methodChannel);
    gh.lazySingletonAsync<_i655.PackageInfo>(() => platformModule.packageInfo);
    gh.lazySingleton<_i281.AssetBundle>(() => platformModule.assetBundle);
    gh.lazySingletonAsync<_i310.Database>(() => databaseModule.database());
    gh.factoryParam<_i310.SembastCodec, String, dynamic>((
      privateKey,
      _,
    ) =>
        databaseModule.getCodec(privateKey));
    gh.factory<_i310.StoreRef<String, Map<String, Object?>>>(
      () => databaseModule.claimStore,
      instanceName: 'claimStore',
    );
    gh.factoryParam<_i890.Encrypter, _i890.Key, dynamic>(
      (
        key,
        _,
      ) =>
          encryptionModule.encryptAES(key),
      instanceName: 'encryptAES',
    );
    gh.factory<Map<String, _i310.StoreRef<String, Map<String, Object?>>>>(
      () => databaseModule.identityStateStore,
      instanceName: 'identityStateStore',
    );
    gh.factoryParamAsync<_i310.Database, String?, String?>(
      (
        identifier,
        privateKey,
      ) =>
          databaseModule.identityDatabase(
        identifier,
        privateKey,
      ),
      instanceName: 'polygonIdSdkIdentity',
    );
    gh.factory<_i310.StoreRef<String, Map<String, Object?>>>(
      () => databaseModule.didProfileInfoStore,
      instanceName: 'didProfileInfoStore',
    );
    gh.factory<_i310.StoreRef<String, Map<String, Object?>>>(
      () => databaseModule.identityStore,
      instanceName: 'identityStore',
    );
    gh.factory<_i995.IdentityStoreRefWrapper>(() =>
        _i995.IdentityStoreRefWrapper(
            gh<_i310.StoreRef<String, Map<String, Object?>>>(
                instanceName: 'identityStore')));
    gh.factory<_i62.RemoteClaimDataSource>(() => _i62.RemoteClaimDataSource(
          gh<_i519.Client>(),
          gh<_i267.StacktraceManager>(),
        ));
    gh.factory<_i461.FiltersMapper>(
        () => _i461.FiltersMapper(gh<_i325.FilterMapper>()));
    gh.factory<_i526.PrivateKeyMapper>(() => _i168.PrivateKeySymbolsMapper());
    gh.factory<_i310.StoreRef<String, dynamic>>(
      () => databaseModule.keyValueStore,
      instanceName: 'keyValueStore',
    );
    gh.factory<_i961.PolygonIdCoreProof>(
        () => _i961.PolygonIdCoreProof(gh<_i267.StacktraceManager>()));
    gh.factory<_i328.PolygonIdCoreCredential>(
        () => _i328.PolygonIdCoreCredential(gh<_i267.StacktraceManager>()));
    gh.factory<_i852.PolygonIdCoreIdentity>(
        () => _i852.PolygonIdCoreIdentity(gh<_i267.StacktraceManager>()));
    gh.factory<_i839.RemoteIdentityDataSource>(
        () => _i839.RemoteIdentityDataSource(gh<_i267.StacktraceManager>()));
    gh.factory<_i795.ErrorHandling>(
        () => _i795.ErrorHandling(gh<_i267.StacktraceManager>()));
    gh.factory<_i296.Iden3MessageDataSource>(
        () => _i296.Iden3MessageDataSource(gh<_i267.StacktraceManager>()));
    gh.factory<_i96.ProofRequestFiltersMapper>(
        () => _i96.ProofRequestFiltersMapper(gh<_i267.StacktraceManager>()));
    gh.factory<_i98.JWZMapper>(
        () => _i98.JWZMapper(gh<_i267.StacktraceManager>()));
    gh.factory<_i897.GetIden3MessageUseCase>(
        () => _i897.GetIden3MessageUseCase(gh<_i267.StacktraceManager>()));
    gh.factory<_i310.StoreRef<String, Map<String, Object?>>>(
      () => databaseModule.interactionStore,
      instanceName: 'interactionStore',
    );
    gh.factory<_i409.RemoteIden3commDataSource>(
        () => _i409.RemoteIden3commDataSource(
              gh<_i361.Dio>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factory<_i425.SecureInteractionStoreRefWrapper>(() =>
        _i425.SecureInteractionStoreRefWrapper(
            gh<_i310.StoreRef<String, Map<String, Object?>>>(
                instanceName: 'interactionStore')));
    gh.factory<_i57.InteractionStoreRefWrapper>(() =>
        _i57.InteractionStoreRefWrapper(
            gh<_i310.StoreRef<String, Map<String, Object?>>>(
                instanceName: 'interactionStore')));
    gh.factory<_i738.ClaimStoreRefWrapper>(() => _i738.ClaimStoreRefWrapper(
        gh<_i310.StoreRef<String, Map<String, Object?>>>(
            instanceName: 'claimStore')));
    gh.factory<_i738.StorageClaimDataSource>(
        () => _i738.StorageClaimDataSource(gh<_i738.ClaimStoreRefWrapper>()));
    gh.factory<_i310.StoreRef<String, Map<String, Object?>>>(
      () => databaseModule.profileStore,
      instanceName: 'profilesStore',
    );
    gh.factoryParam<_i641.Web3Client, String, dynamic>((
      rpcUrl,
      _,
    ) =>
        networkModule.web3client(rpcUrl));
    gh.factory<_i294.ClaimMapper>(() => _i294.ClaimMapper(
          gh<_i497.ClaimStateMapper>(),
          gh<_i894.ClaimInfoMapper>(),
          gh<_i590.DisplayTypeMapper>(),
        ));
    gh.factory<_i758.LibPolygonIdCoreCredentialDataSource>(() =>
        _i758.LibPolygonIdCoreCredentialDataSource(
            gh<_i328.PolygonIdCoreCredential>()));
    gh.factory<_i361.SecureDidProfileInfoStoreRefWrapper>(() =>
        _i361.SecureDidProfileInfoStoreRefWrapper(
            gh<_i310.StoreRef<String, Map<String, Object?>>>(
                instanceName: 'didProfileInfoStore')));
    gh.factoryAsync<_i995.StorageIdentityDataSource>(
        () async => _i995.StorageIdentityDataSource(
              await getAsync<_i310.Database>(),
              gh<_i995.IdentityStoreRefWrapper>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factory<_i136.LibPolygonIdCoreIdentityDataSource>(() =>
        _i136.LibPolygonIdCoreIdentityDataSource(
            gh<_i852.PolygonIdCoreIdentity>()));
    gh.factory<_i425.SecureStorageInteractionDataSource>(() =>
        _i425.SecureStorageInteractionDataSource(
            gh<_i425.SecureInteractionStoreRefWrapper>()));
    gh.factory<_i383.WalletDataSource>(
        () => _i383.WalletDataSource(gh<_i383.WalletLibWrapper>()));
    gh.factory<_i910.Iden3commCredentialRepositoryImpl>(
        () => _i910.Iden3commCredentialRepositoryImpl(
              gh<_i409.RemoteIden3commDataSource>(),
              gh<_i96.ProofRequestFiltersMapper>(),
              gh<_i294.ClaimMapper>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factory<_i42.IdentitySMTStoreRefWrapper>(() =>
        _i42.IdentitySMTStoreRefWrapper(
            gh<Map<String, _i310.StoreRef<String, Map<String, Object?>>>>(
                instanceName: 'identityStateStore')));
    gh.factory<_i608.PolygonIdFlutterChannel>(
        () => _i608.PolygonIdFlutterChannel(
              gh<_i189.PolygonIdSdk>(),
              gh<_i281.MethodChannel>(),
            ));
    gh.factory<_i361.SecureStorageDidProfileInfoDataSource>(() =>
        _i361.SecureStorageDidProfileInfoDataSource(
            gh<_i361.SecureDidProfileInfoStoreRefWrapper>()));
    gh.factoryAsync<_i540.CircuitsFilesDataSource>(() async =>
        _i540.CircuitsFilesDataSource(await getAsync<_i497.Directory>()));
    gh.factory<_i66.DidProfileInfoRepositoryImpl>(
        () => _i66.DidProfileInfoRepositoryImpl(
              gh<_i361.SecureStorageDidProfileInfoDataSource>(),
              gh<_i461.FiltersMapper>(),
            ));
    gh.factory<_i352.CircuitsDownloadDataSource>(
        () => _i352.CircuitsDownloadDataSource(gh<_i361.Dio>()));
    gh.factory<_i232.SecureStorageProfilesStoreRefWrapper>(() =>
        _i232.SecureStorageProfilesStoreRefWrapper(
            gh<_i310.StoreRef<String, Map<String, Object?>>>(
                instanceName: 'profilesStore')));
    gh.singletonAsync<_i295.GetPackageNameUseCase>(() async =>
        _i295.GetPackageNameUseCase(await getAsync<_i655.PackageInfo>()));
    gh.factory<_i698.Iden3commCredentialRepository>(() =>
        repositoriesModule.iden3commCredentialRepository(
            gh<_i910.Iden3commCredentialRepositoryImpl>()));
    gh.factory<_i938.DestinationPathDataSource>(
        () => _i938.DestinationPathDataSource(gh<_i938.CreatePathWrapper>()));
    gh.factory<_i41.LibPolygonIdCoreWrapper>(
        () => _i41.LibPolygonIdCoreWrapper(gh<_i961.PolygonIdCoreProof>()));
    gh.factory<_i42.StorageSMTDataSource>(
        () => _i42.StorageSMTDataSource(gh<_i42.IdentitySMTStoreRefWrapper>()));
    gh.factory<_i232.SecureStorageProfilesDataSource>(() =>
        _i232.SecureStorageProfilesDataSource(
            gh<_i232.SecureStorageProfilesStoreRefWrapper>()));
    gh.factory<_i575.SMTDataSource>(
        () => _i575.SMTDataSource(gh<_i42.StorageSMTDataSource>()));
    gh.singleton<_i969.LocalClaimDataSource>(() => _i969.LocalClaimDataSource(
        gh<_i758.LibPolygonIdCoreCredentialDataSource>()));
    gh.factory<_i272.CacheCredentialDataSource>(() =>
        _i272.CacheCredentialDataSource(
            gh<_i758.LibPolygonIdCoreCredentialDataSource>()));
    gh.factoryAsync<_i57.StorageInteractionDataSource>(
        () async => _i57.StorageInteractionDataSource(
              await getAsync<_i310.Database>(),
              gh<_i57.InteractionStoreRefWrapper>(),
            ));
    gh.factory<_i525.KeyValueStoreRefWrapper>(() =>
        _i525.KeyValueStoreRefWrapper(gh<_i310.StoreRef<String, dynamic>>(
            instanceName: 'keyValueStore')));
    gh.factoryAsync<_i548.InteractionRepositoryImpl>(
        () async => _i548.InteractionRepositoryImpl(
              gh<_i425.SecureStorageInteractionDataSource>(),
              await getAsync<_i57.StorageInteractionDataSource>(),
              gh<_i1026.InteractionMapper>(),
              gh<_i461.FiltersMapper>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factory<_i631.GetProofQueryContextUseCase>(
        () => _i631.GetProofQueryContextUseCase(
              gh<_i698.Iden3commCredentialRepository>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factory<_i41.LibPolygonIdCoreProofDataSource>(
        () => _i41.LibPolygonIdCoreProofDataSource(
              gh<_i41.LibPolygonIdCoreWrapper>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factory<_i258.DidProfileInfoRepository>(() => repositoriesModule
        .didProfileInfoRepository(gh<_i66.DidProfileInfoRepositoryImpl>()));
    gh.factory<_i893.AddDidProfileInfoUseCase>(() =>
        _i893.AddDidProfileInfoUseCase(gh<_i258.DidProfileInfoRepository>()));
    gh.factory<_i616.GetDidProfileInfoUseCase>(() =>
        _i616.GetDidProfileInfoUseCase(gh<_i258.DidProfileInfoRepository>()));
    gh.factory<_i108.GetDidProfileInfoListUseCase>(() =>
        _i108.GetDidProfileInfoListUseCase(
            gh<_i258.DidProfileInfoRepository>()));
    gh.factory<_i646.RemoveDidProfileInfoUseCase>(() =>
        _i646.RemoveDidProfileInfoUseCase(
            gh<_i258.DidProfileInfoRepository>()));
    gh.factoryAsync<_i525.StorageKeyValueDataSource>(
        () async => _i525.StorageKeyValueDataSource(
              await getAsync<_i310.Database>(),
              gh<_i525.KeyValueStoreRefWrapper>(),
            ));
    gh.factory<_i238.FetchSchemaUseCase>(() =>
        _i238.FetchSchemaUseCase(gh<_i698.Iden3commCredentialRepository>()));
    gh.factory<_i233.GetSchemasUseCase>(() =>
        _i233.GetSchemasUseCase(gh<_i698.Iden3commCredentialRepository>()));
    gh.factory<_i328.SMTRepositoryImpl>(() => _i328.SMTRepositoryImpl(
          gh<_i575.SMTDataSource>(),
          gh<_i42.StorageSMTDataSource>(),
        ));
    gh.factory<_i627.GetProofRequestsUseCase>(
        () => _i627.GetProofRequestsUseCase(
              gh<_i631.GetProofQueryContextUseCase>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i1012.InteractionRepository>(() async =>
        repositoriesModule.interactionRepository(
            await getAsync<_i548.InteractionRepositoryImpl>()));
    gh.factory<_i550.CredentialRepositoryImpl>(
        () => _i550.CredentialRepositoryImpl(
              gh<_i62.RemoteClaimDataSource>(),
              gh<_i738.StorageClaimDataSource>(),
              gh<_i969.LocalClaimDataSource>(),
              gh<_i272.CacheCredentialDataSource>(),
              gh<_i294.ClaimMapper>(),
              gh<_i461.FiltersMapper>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factory<_i588.Iden3commRepositoryImpl>(
        () => _i588.Iden3commRepositoryImpl(
              gh<_i296.Iden3MessageDataSource>(),
              gh<_i409.RemoteIden3commDataSource>(),
              gh<_i41.LibPolygonIdCoreProofDataSource>(),
              gh<_i599.QMapper>(),
              gh<_i98.JWZMapper>(),
              gh<_i897.GetIden3MessageUseCase>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.singletonAsync<_i415.ConfigRepository>(() async =>
        _i415.ConfigRepository(
            await getAsync<_i525.StorageKeyValueDataSource>()));
    gh.factory<_i946.SMTRepository>(
        () => repositoriesModule.smtRepository(gh<_i328.SMTRepositoryImpl>()));
    gh.factory<_i88.Iden3commRepository>(() => repositoriesModule
        .iden3commRepository(gh<_i588.Iden3commRepositoryImpl>()));
    gh.factory<_i359.CleanSchemaCacheUseCase>(
        () => _i359.CleanSchemaCacheUseCase(gh<_i88.Iden3commRepository>()));
    gh.factory<_i309.CredentialRepository>(() => repositoriesModule
        .credentialRepository(gh<_i550.CredentialRepositoryImpl>()));
    gh.factory<_i53.GetClaimRevocationNonceUseCase>(() =>
        _i53.GetClaimRevocationNonceUseCase(gh<_i309.CredentialRepository>()));
    gh.factory<_i227.GetCredentialByIdUseCase>(
        () => _i227.GetCredentialByIdUseCase(gh<_i309.CredentialRepository>()));
    gh.factory<_i158.GetCredentialByPartialIdUseCase>(() =>
        _i158.GetCredentialByPartialIdUseCase(
            gh<_i309.CredentialRepository>()));
    gh.factory<_i348.CacheCredentialUseCase>(
        () => _i348.CacheCredentialUseCase(gh<_i309.CredentialRepository>()));
    gh.factoryAsync<_i438.SetSelectedChainUseCase>(() async =>
        _i438.SetSelectedChainUseCase(
            await getAsync<_i415.ConfigRepository>()));
    gh.factoryAsync<_i924.SetEnvUseCase>(() async =>
        _i924.SetEnvUseCase(await getAsync<_i415.ConfigRepository>()));
    gh.factoryAsync<_i626.GetEnvUseCase>(() async => _i626.GetEnvUseCase(
          await getAsync<_i415.ConfigRepository>(),
          gh<_i267.StacktraceManager>(),
        ));
    gh.factoryAsync<_i500.CacheCredentialsUseCase>(
        () async => _i500.CacheCredentialsUseCase(
              gh<_i348.CacheCredentialUseCase>(),
              gh<_i267.StacktraceManager>(),
              await getAsync<_i626.GetEnvUseCase>(),
            ));
    gh.factoryAsync<_i581.ProofRepositoryImpl>(
        () async => _i581.ProofRepositoryImpl(
              gh<_i1039.WitnessDataSource>(),
              gh<_i502.ProverLibDataSource>(),
              gh<_i41.LibPolygonIdCoreProofDataSource>(),
              gh<_i694.GistMTProofDataSource>(),
              gh<_i1021.ProofCircuitDataSource>(),
              gh<_i22.LocalContractFilesDataSource>(),
              gh<_i352.CircuitsDownloadDataSource>(),
              gh<_i294.ClaimMapper>(),
              await getAsync<_i540.CircuitsFilesDataSource>(),
              await getAsync<_i626.GetEnvUseCase>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factory<_i734.GetAuthChallengeUseCase>(
        () => _i734.GetAuthChallengeUseCase(
              gh<_i88.Iden3commRepository>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factory<_i249.GetJWZUseCase>(() => _i249.GetJWZUseCase(
          gh<_i88.Iden3commRepository>(),
          gh<_i267.StacktraceManager>(),
        ));
    gh.factoryAsync<_i1031.AddInteractionUseCase>(
        () async => _i1031.AddInteractionUseCase(
              await getAsync<_i1012.InteractionRepository>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i484.GetInteractionsUseCase>(
        () async => _i484.GetInteractionsUseCase(
              await getAsync<_i1012.InteractionRepository>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i737.GetSelectedChainUseCase>(
        () async => _i737.GetSelectedChainUseCase(
              await getAsync<_i415.ConfigRepository>(),
              await getAsync<_i626.GetEnvUseCase>(),
            ));
    gh.factory<_i1009.RemoveIdentityStateUseCase>(
        () => _i1009.RemoveIdentityStateUseCase(
              gh<_i946.SMTRepository>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factory<_i754.GetLatestStateUseCase>(() => _i754.GetLatestStateUseCase(
          gh<_i946.SMTRepository>(),
          gh<_i267.StacktraceManager>(),
        ));
    gh.factoryAsync<_i873.RPCDataSource>(() async => _i873.RPCDataSource(
          await getAsync<_i737.GetSelectedChainUseCase>(),
          gh<_i267.StacktraceManager>(),
        ));
    gh.factory<_i958.RemoveClaimsUseCase>(() => _i958.RemoveClaimsUseCase(
          gh<_i309.CredentialRepository>(),
          gh<_i267.StacktraceManager>(),
        ));
    gh.factory<_i660.GetNonRevProofUseCase>(() => _i660.GetNonRevProofUseCase(
          gh<_i309.CredentialRepository>(),
          gh<_i267.StacktraceManager>(),
        ));
    gh.factory<_i657.GetClaimsUseCase>(() => _i657.GetClaimsUseCase(
          gh<_i309.CredentialRepository>(),
          gh<_i267.StacktraceManager>(),
        ));
    gh.factory<_i168.UpdateClaimUseCase>(() => _i168.UpdateClaimUseCase(
          gh<_i309.CredentialRepository>(),
          gh<_i267.StacktraceManager>(),
        ));
    gh.factory<_i635.SaveClaimsUseCase>(() => _i635.SaveClaimsUseCase(
          gh<_i309.CredentialRepository>(),
          gh<_i267.StacktraceManager>(),
        ));
    gh.factory<_i503.RemoveAllClaimsUseCase>(() => _i503.RemoveAllClaimsUseCase(
          gh<_i309.CredentialRepository>(),
          gh<_i267.StacktraceManager>(),
        ));
    gh.factoryAsync<_i1054.FetchOnchainClaimUseCase>(
        () async => _i1054.FetchOnchainClaimUseCase(
              await getAsync<_i737.GetSelectedChainUseCase>(),
              await getAsync<_i626.GetEnvUseCase>(),
              gh<_i758.LibPolygonIdCoreCredentialDataSource>(),
              gh<_i22.LocalContractFilesDataSource>(),
              gh<_i409.RemoteIden3commDataSource>(),
              gh<_i294.ClaimMapper>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factory<_i392.GetAuthClaimUseCase>(() => _i392.GetAuthClaimUseCase(
          gh<_i309.CredentialRepository>(),
          gh<_i267.StacktraceManager>(),
        ));
    gh.factoryAsync<_i341.ProofRepository>(() async => repositoriesModule
        .proofRepository(await getAsync<_i581.ProofRepositoryImpl>()));
    gh.factoryAsync<_i660.LoadCircuitUseCase>(
        () async => _i660.LoadCircuitUseCase(
              await getAsync<_i341.ProofRepository>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i310.ProveUseCase>(() async => _i310.ProveUseCase(
          await getAsync<_i341.ProofRepository>(),
          gh<_i267.StacktraceManager>(),
        ));
    gh.factoryAsync<_i746.GenerateZKProofUseCase>(
        () async => _i746.GenerateZKProofUseCase(
              await getAsync<_i341.ProofRepository>(),
              await getAsync<_i310.ProveUseCase>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i393.IdentityRepositoryImpl>(
        () async => _i393.IdentityRepositoryImpl(
              gh<_i383.WalletDataSource>(),
              gh<_i839.RemoteIdentityDataSource>(),
              await getAsync<_i995.StorageIdentityDataSource>(),
              await getAsync<_i873.RPCDataSource>(),
              gh<_i22.LocalContractFilesDataSource>(),
              gh<_i136.LibPolygonIdCoreIdentityDataSource>(),
              gh<_i200.EncryptionDbDataSource>(),
              gh<_i938.DestinationPathDataSource>(),
              gh<_i526.PrivateKeyMapper>(),
              gh<_i720.StateIdentifierMapper>(),
              gh<_i232.SecureStorageProfilesDataSource>(),
            ));
    gh.factoryAsync<_i735.IsProofCircuitSupportedUseCase>(() async =>
        _i735.IsProofCircuitSupportedUseCase(
            await getAsync<_i341.ProofRepository>()));
    gh.factoryAsync<_i991.CircuitsFilesExistUseCase>(() async =>
        _i991.CircuitsFilesExistUseCase(
            await getAsync<_i341.ProofRepository>()));
    gh.factoryAsync<_i570.DownloadCircuitsUseCase>(() async =>
        _i570.DownloadCircuitsUseCase(await getAsync<_i341.ProofRepository>()));
    gh.factoryAsync<_i394.CancelDownloadCircuitsUseCase>(() async =>
        _i394.CancelDownloadCircuitsUseCase(
            await getAsync<_i341.ProofRepository>()));
    gh.factoryAsync<_i347.GetIden3commClaimsUseCase>(
        () async => _i347.GetIden3commClaimsUseCase(
              gh<_i698.Iden3commCredentialRepository>(),
              gh<_i657.GetClaimsUseCase>(),
              await getAsync<_i735.IsProofCircuitSupportedUseCase>(),
              gh<_i627.GetProofRequestsUseCase>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i445.Proof>(() async => _i445.Proof(
          await getAsync<_i746.GenerateZKProofUseCase>(),
          await getAsync<_i570.DownloadCircuitsUseCase>(),
          await getAsync<_i991.CircuitsFilesExistUseCase>(),
          gh<_i920.ProofGenerationStepsStreamManager>(),
          await getAsync<_i394.CancelDownloadCircuitsUseCase>(),
          gh<_i267.StacktraceManager>(),
        ));
    gh.factoryAsync<_i539.GetFiltersUseCase>(
        () async => _i539.GetFiltersUseCase(
              gh<_i698.Iden3commCredentialRepository>(),
              await getAsync<_i735.IsProofCircuitSupportedUseCase>(),
              gh<_i627.GetProofRequestsUseCase>(),
            ));
    gh.factoryAsync<_i369.GetIden3commClaimsRevNonceUseCase>(
        () async => _i369.GetIden3commClaimsRevNonceUseCase(
              gh<_i698.Iden3commCredentialRepository>(),
              gh<_i657.GetClaimsUseCase>(),
              gh<_i53.GetClaimRevocationNonceUseCase>(),
              await getAsync<_i735.IsProofCircuitSupportedUseCase>(),
              gh<_i627.GetProofRequestsUseCase>(),
            ));
    gh.factoryAsync<_i26.IdentityRepository>(() async => repositoriesModule
        .identityRepository(await getAsync<_i393.IdentityRepositoryImpl>()));
    gh.factoryAsync<_i449.SignMessageUseCase>(() async =>
        _i449.SignMessageUseCase(await getAsync<_i26.IdentityRepository>()));
    gh.factoryAsync<_i172.FetchStateRootsUseCase>(() async =>
        _i172.FetchStateRootsUseCase(
            await getAsync<_i26.IdentityRepository>()));
    gh.factoryAsync<_i665.GetPrivateKeyUseCase>(
        () async => _i665.GetPrivateKeyUseCase(
              await getAsync<_i26.IdentityRepository>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i348.GetIdentitiesUseCase>(
        () async => _i348.GetIdentitiesUseCase(
              await getAsync<_i26.IdentityRepository>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i166.GetPublicKeysUseCase>(
        () async => _i166.GetPublicKeysUseCase(
              await getAsync<_i26.IdentityRepository>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i1042.GetGenesisStateUseCase>(
        () async => _i1042.GetGenesisStateUseCase(
              await getAsync<_i26.IdentityRepository>(),
              gh<_i946.SMTRepository>(),
              gh<_i392.GetAuthClaimUseCase>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i344.GetGistMTProofUseCase>(
        () async => _i344.GetGistMTProofUseCase(
              await getAsync<_i341.ProofRepository>(),
              await getAsync<_i26.IdentityRepository>(),
              await getAsync<_i737.GetSelectedChainUseCase>(),
              gh<_i78.GetDidUseCase>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i484.FetchIdentityStateUseCase>(
        () async => _i484.FetchIdentityStateUseCase(
              await getAsync<_i26.IdentityRepository>(),
              await getAsync<_i737.GetSelectedChainUseCase>(),
              gh<_i78.GetDidUseCase>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i732.GetDidIdentifierUseCase>(
        () async => _i732.GetDidIdentifierUseCase(
              await getAsync<_i26.IdentityRepository>(),
              await getAsync<_i626.GetEnvUseCase>(),
              await getAsync<_i1042.GetGenesisStateUseCase>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i798.CreateIdentityStateUseCase>(
        () async => _i798.CreateIdentityStateUseCase(
              await getAsync<_i26.IdentityRepository>(),
              gh<_i946.SMTRepository>(),
              gh<_i392.GetAuthClaimUseCase>(),
              await getAsync<_i166.GetPublicKeysUseCase>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i505.CheckProfileAndDidCurrentEnvUseCase>(
        () async => _i505.CheckProfileAndDidCurrentEnvUseCase(
              gh<_i192.CheckProfileValidityUseCase>(),
              await getAsync<_i737.GetSelectedChainUseCase>(),
              await getAsync<_i732.GetDidIdentifierUseCase>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i146.FetchOnchainClaimsUseCase>(
        () async => _i146.FetchOnchainClaimsUseCase(
              await getAsync<_i1054.FetchOnchainClaimUseCase>(),
              await getAsync<_i505.CheckProfileAndDidCurrentEnvUseCase>(),
              await getAsync<_i626.GetEnvUseCase>(),
              await getAsync<_i737.GetSelectedChainUseCase>(),
              gh<_i78.GetDidUseCase>(),
              gh<_i22.LocalContractFilesDataSource>(),
              await getAsync<_i26.IdentityRepository>(),
              gh<_i258.DidProfileInfoRepository>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i675.GetCurrentEnvDidIdentifierUseCase>(
        () async => _i675.GetCurrentEnvDidIdentifierUseCase(
              await getAsync<_i737.GetSelectedChainUseCase>(),
              await getAsync<_i732.GetDidIdentifierUseCase>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i40.GenerateNonRevProofUseCase>(
        () async => _i40.GenerateNonRevProofUseCase(
              await getAsync<_i26.IdentityRepository>(),
              gh<_i309.CredentialRepository>(),
              await getAsync<_i484.FetchIdentityStateUseCase>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i266.CreateProfilesUseCase>(
        () async => _i266.CreateProfilesUseCase(
              await getAsync<_i166.GetPublicKeysUseCase>(),
              await getAsync<_i675.GetCurrentEnvDidIdentifierUseCase>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i743.GetIdentityUseCase>(
        () async => _i743.GetIdentityUseCase(
              await getAsync<_i26.IdentityRepository>(),
              gh<_i78.GetDidUseCase>(),
              await getAsync<_i732.GetDidIdentifierUseCase>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i114.GetAuthInputsUseCase>(
        () async => _i114.GetAuthInputsUseCase(
              await getAsync<_i743.GetIdentityUseCase>(),
              gh<_i309.CredentialRepository>(),
              await getAsync<_i449.SignMessageUseCase>(),
              await getAsync<_i344.GetGistMTProofUseCase>(),
              gh<_i754.GetLatestStateUseCase>(),
              gh<_i88.Iden3commRepository>(),
              await getAsync<_i26.IdentityRepository>(),
              gh<_i946.SMTRepository>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i845.CreateIdentityUseCase>(
        () async => _i845.CreateIdentityUseCase(
              await getAsync<_i166.GetPublicKeysUseCase>(),
              await getAsync<_i675.GetCurrentEnvDidIdentifierUseCase>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i871.GetAuthTokenUseCase>(
        () async => _i871.GetAuthTokenUseCase(
              await getAsync<_i660.LoadCircuitUseCase>(),
              gh<_i249.GetJWZUseCase>(),
              gh<_i734.GetAuthChallengeUseCase>(),
              await getAsync<_i114.GetAuthInputsUseCase>(),
              await getAsync<_i310.ProveUseCase>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i816.UpdateIdentityUseCase>(
        () async => _i816.UpdateIdentityUseCase(
              await getAsync<_i26.IdentityRepository>(),
              await getAsync<_i743.GetIdentityUseCase>(),
            ));
    gh.factoryAsync<_i133.BackupIdentityUseCase>(
        () async => _i133.BackupIdentityUseCase(
              await getAsync<_i743.GetIdentityUseCase>(),
              await getAsync<_i26.IdentityRepository>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i610.GetClaimRevocationStatusUseCase>(
        () async => _i610.GetClaimRevocationStatusUseCase(
              gh<_i309.CredentialRepository>(),
              await getAsync<_i40.GenerateNonRevProofUseCase>(),
              gh<_i660.GetNonRevProofUseCase>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i561.GetProfilesUseCase>(
        () async => _i561.GetProfilesUseCase(
              await getAsync<_i743.GetIdentityUseCase>(),
              await getAsync<_i505.CheckProfileAndDidCurrentEnvUseCase>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i975.RemoveInteractionsUseCase>(
        () async => _i975.RemoveInteractionsUseCase(
              await getAsync<_i1012.InteractionRepository>(),
              await getAsync<_i743.GetIdentityUseCase>(),
            ));
    gh.factoryAsync<_i548.CheckIdentityValidityUseCase>(
        () async => _i548.CheckIdentityValidityUseCase(
              await getAsync<_i665.GetPrivateKeyUseCase>(),
              await getAsync<_i166.GetPublicKeysUseCase>(),
              await getAsync<_i675.GetCurrentEnvDidIdentifierUseCase>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i102.FetchAndSaveClaimsUseCase>(
        () async => _i102.FetchAndSaveClaimsUseCase(
              gh<_i698.Iden3commCredentialRepository>(),
              await getAsync<_i1054.FetchOnchainClaimUseCase>(),
              await getAsync<_i505.CheckProfileAndDidCurrentEnvUseCase>(),
              await getAsync<_i626.GetEnvUseCase>(),
              await getAsync<_i737.GetSelectedChainUseCase>(),
              await getAsync<_i732.GetDidIdentifierUseCase>(),
              gh<_i78.GetDidUseCase>(),
              gh<_i968.GetFetchRequestsUseCase>(),
              await getAsync<_i871.GetAuthTokenUseCase>(),
              gh<_i635.SaveClaimsUseCase>(),
              gh<_i348.CacheCredentialUseCase>(),
              gh<_i22.LocalContractFilesDataSource>(),
              await getAsync<_i26.IdentityRepository>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i829.RemoveProfileUseCase>(
        () async => _i829.RemoveProfileUseCase(
              await getAsync<_i743.GetIdentityUseCase>(),
              await getAsync<_i816.UpdateIdentityUseCase>(),
              await getAsync<_i505.CheckProfileAndDidCurrentEnvUseCase>(),
              await getAsync<_i266.CreateProfilesUseCase>(),
              gh<_i1009.RemoveIdentityStateUseCase>(),
              gh<_i503.RemoveAllClaimsUseCase>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i989.UpdateInteractionUseCase>(
        () async => _i989.UpdateInteractionUseCase(
              await getAsync<_i1012.InteractionRepository>(),
              gh<_i192.CheckProfileValidityUseCase>(),
              await getAsync<_i743.GetIdentityUseCase>(),
              await getAsync<_i1031.AddInteractionUseCase>(),
            ));
    gh.factoryAsync<_i709.FetchCredentialsUseCase>(
        () async => _i709.FetchCredentialsUseCase(
              await getAsync<_i737.GetSelectedChainUseCase>(),
              await getAsync<_i732.GetDidIdentifierUseCase>(),
              await getAsync<_i871.GetAuthTokenUseCase>(),
              gh<_i968.GetFetchRequestsUseCase>(),
              gh<_i698.Iden3commCredentialRepository>(),
              gh<_i267.StacktraceManager>(),
              await getAsync<_i26.IdentityRepository>(),
              gh<_i22.LocalContractFilesDataSource>(),
              gh<_i78.GetDidUseCase>(),
              await getAsync<_i1054.FetchOnchainClaimUseCase>(),
              await getAsync<_i626.GetEnvUseCase>(),
            ));
    gh.factoryAsync<_i668.RemoveIdentityUseCase>(
        () async => _i668.RemoveIdentityUseCase(
              await getAsync<_i26.IdentityRepository>(),
              await getAsync<_i561.GetProfilesUseCase>(),
              await getAsync<_i829.RemoveProfileUseCase>(),
              gh<_i1009.RemoveIdentityStateUseCase>(),
              gh<_i503.RemoveAllClaimsUseCase>(),
              await getAsync<_i505.CheckProfileAndDidCurrentEnvUseCase>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i1050.AddProfileUseCase>(
        () async => _i1050.AddProfileUseCase(
              await getAsync<_i743.GetIdentityUseCase>(),
              await getAsync<_i816.UpdateIdentityUseCase>(),
              await getAsync<_i505.CheckProfileAndDidCurrentEnvUseCase>(),
              await getAsync<_i266.CreateProfilesUseCase>(),
              gh<_i136.LibPolygonIdCoreIdentityDataSource>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i340.GenerateIden3commProofUseCase>(
        () async => _i340.GenerateIden3commProofUseCase(
              await getAsync<_i26.IdentityRepository>(),
              gh<_i946.SMTRepository>(),
              await getAsync<_i341.ProofRepository>(),
              await getAsync<_i310.ProveUseCase>(),
              await getAsync<_i743.GetIdentityUseCase>(),
              gh<_i392.GetAuthClaimUseCase>(),
              await getAsync<_i344.GetGistMTProofUseCase>(),
              gh<_i78.GetDidUseCase>(),
              await getAsync<_i449.SignMessageUseCase>(),
              gh<_i754.GetLatestStateUseCase>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i143.RefreshCredentialUseCase>(
        () async => _i143.RefreshCredentialUseCase(
              gh<_i267.StacktraceManager>(),
              await getAsync<_i743.GetIdentityUseCase>(),
              await getAsync<_i871.GetAuthTokenUseCase>(),
              gh<_i698.Iden3commCredentialRepository>(),
              gh<_i958.RemoveClaimsUseCase>(),
              gh<_i635.SaveClaimsUseCase>(),
            ));
    gh.factoryAsync<_i561.AddIdentityUseCase>(
        () async => _i561.AddIdentityUseCase(
              await getAsync<_i26.IdentityRepository>(),
              await getAsync<_i845.CreateIdentityUseCase>(),
              await getAsync<_i798.CreateIdentityStateUseCase>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i657.RestoreProfilesUseCase>(
        () async => _i657.RestoreProfilesUseCase(
              await getAsync<_i26.IdentityRepository>(),
              await getAsync<_i816.UpdateIdentityUseCase>(),
            ));
    gh.factoryAsync<_i501.Credential>(() async => _i501.Credential(
          gh<_i635.SaveClaimsUseCase>(),
          gh<_i657.GetClaimsUseCase>(),
          gh<_i958.RemoveClaimsUseCase>(),
          await getAsync<_i610.GetClaimRevocationStatusUseCase>(),
          gh<_i168.UpdateClaimUseCase>(),
          gh<_i267.StacktraceManager>(),
          await getAsync<_i143.RefreshCredentialUseCase>(),
          gh<_i227.GetCredentialByIdUseCase>(),
          gh<_i158.GetCredentialByPartialIdUseCase>(),
          await getAsync<_i500.CacheCredentialsUseCase>(),
          gh<_i348.CacheCredentialUseCase>(),
        ));
    gh.factoryAsync<_i11.RestoreIdentityUseCase>(
        () async => _i11.RestoreIdentityUseCase(
              await getAsync<_i561.AddIdentityUseCase>(),
              await getAsync<_i743.GetIdentityUseCase>(),
              await getAsync<_i26.IdentityRepository>(),
              await getAsync<_i675.GetCurrentEnvDidIdentifierUseCase>(),
              await getAsync<_i657.RestoreProfilesUseCase>(),
            ));
    gh.factoryAsync<_i412.GetIden3commProofsUseCase>(
        () async => _i412.GetIden3commProofsUseCase(
              await getAsync<_i341.ProofRepository>(),
              await getAsync<_i347.GetIden3commClaimsUseCase>(),
              await getAsync<_i340.GenerateIden3commProofUseCase>(),
              await getAsync<_i735.IsProofCircuitSupportedUseCase>(),
              gh<_i627.GetProofRequestsUseCase>(),
              await getAsync<_i743.GetIdentityUseCase>(),
              gh<_i920.ProofGenerationStepsStreamManager>(),
              gh<_i267.StacktraceManager>(),
              await getAsync<_i143.RefreshCredentialUseCase>(),
            ));
    gh.factoryAsync<_i279.AddNewIdentityUseCase>(
        () async => _i279.AddNewIdentityUseCase(
              await getAsync<_i26.IdentityRepository>(),
              await getAsync<_i561.AddIdentityUseCase>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i17.Identity>(() async => _i17.Identity(
          await getAsync<_i548.CheckIdentityValidityUseCase>(),
          await getAsync<_i665.GetPrivateKeyUseCase>(),
          await getAsync<_i279.AddNewIdentityUseCase>(),
          await getAsync<_i11.RestoreIdentityUseCase>(),
          await getAsync<_i133.BackupIdentityUseCase>(),
          await getAsync<_i743.GetIdentityUseCase>(),
          await getAsync<_i348.GetIdentitiesUseCase>(),
          await getAsync<_i668.RemoveIdentityUseCase>(),
          await getAsync<_i732.GetDidIdentifierUseCase>(),
          await getAsync<_i449.SignMessageUseCase>(),
          await getAsync<_i484.FetchIdentityStateUseCase>(),
          await getAsync<_i1050.AddProfileUseCase>(),
          await getAsync<_i561.GetProfilesUseCase>(),
          await getAsync<_i829.RemoveProfileUseCase>(),
          gh<_i78.GetDidUseCase>(),
          gh<_i267.StacktraceManager>(),
        ));
    gh.factoryAsync<_i411.AuthenticateUseCase>(
        () async => _i411.AuthenticateUseCase(
              gh<_i88.Iden3commRepository>(),
              await getAsync<_i412.GetIden3commProofsUseCase>(),
              await getAsync<_i732.GetDidIdentifierUseCase>(),
              await getAsync<_i871.GetAuthTokenUseCase>(),
              await getAsync<_i626.GetEnvUseCase>(),
              await getAsync<_i737.GetSelectedChainUseCase>(),
              await getAsync<_i295.GetPackageNameUseCase>(),
              await getAsync<_i505.CheckProfileAndDidCurrentEnvUseCase>(),
              gh<_i920.ProofGenerationStepsStreamManager>(),
              gh<_i267.StacktraceManager>(),
            ));
    gh.factoryAsync<_i500.Iden3comm>(() async => _i500.Iden3comm(
          await getAsync<_i102.FetchAndSaveClaimsUseCase>(),
          await getAsync<_i146.FetchOnchainClaimsUseCase>(),
          gh<_i897.GetIden3MessageUseCase>(),
          gh<_i233.GetSchemasUseCase>(),
          gh<_i238.FetchSchemaUseCase>(),
          await getAsync<_i411.AuthenticateUseCase>(),
          await getAsync<_i539.GetFiltersUseCase>(),
          await getAsync<_i347.GetIden3commClaimsUseCase>(),
          await getAsync<_i369.GetIden3commClaimsRevNonceUseCase>(),
          await getAsync<_i412.GetIden3commProofsUseCase>(),
          await getAsync<_i484.GetInteractionsUseCase>(),
          await getAsync<_i1031.AddInteractionUseCase>(),
          await getAsync<_i975.RemoveInteractionsUseCase>(),
          await getAsync<_i989.UpdateInteractionUseCase>(),
          gh<_i359.CleanSchemaCacheUseCase>(),
          gh<_i267.StacktraceManager>(),
          gh<_i893.AddDidProfileInfoUseCase>(),
          gh<_i616.GetDidProfileInfoUseCase>(),
          gh<_i108.GetDidProfileInfoListUseCase>(),
          gh<_i646.RemoveDidProfileInfoUseCase>(),
          await getAsync<_i871.GetAuthTokenUseCase>(),
          await getAsync<_i709.FetchCredentialsUseCase>(),
        ));
    return this;
  }
}

class _$LoggerModule extends _i335.LoggerModule {}

class _$ChannelModule extends _i335.ChannelModule {}

class _$NetworkModule extends _i335.NetworkModule {}

class _$FilesManagerModule extends _i335.FilesManagerModule {}

class _$PlatformModule extends _i335.PlatformModule {}

class _$DatabaseModule extends _i335.DatabaseModule {}

class _$EncryptionModule extends _i335.EncryptionModule {}

class _$RepositoriesModule extends _i335.RepositoriesModule {}
