import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:polygonid_flutter_sdk/proof/data/dtos/circuits_to_download_param.dart';
import 'package:polygonid_flutter_sdk/proof/domain/entities/download_info_entity.dart';
import 'package:polygonid_flutter_sdk/sdk/polygon_id_sdk.dart';
import 'package:polygonid_flutter_sdk_example/src/presentation/ui/splash/splash_event.dart';
import 'package:polygonid_flutter_sdk_example/src/presentation/ui/splash/splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashState.init()) {
    on<StartDownloadSplashEvent>(onStartDownloadSplashEvent);
    on<DownloadProgressSplashEvent>(onDownloadProgressSplashEvent);
    on<CancelDownloadSplashEvent>(onCancelDownloadSplashEvent);
  }

  StreamSubscription? _subscription;

  /// Simulation of a possible loading time
  Future<void> onStartDownloadSplashEvent(
      StartDownloadSplashEvent event, Emitter<SplashState> emit) async {
    Stream<DownloadInfo> stream =
        PolygonIdSdk.I.proof.initCircuitsDownloadAndGetInfoStream(
      circuitsToDownload: [
        CircuitsToDownloadParam(
          circuitsName: "circuits",
          bucketUrl: "https://circuits.privado.id/v1.0.1/keys.zip",
        ),
      ],
    );

    _subscription = stream.listen((downloadInfo) {
      add(DownloadProgressSplashEvent(downloadInfo));
    });
  }

  Future<void> onDownloadProgressSplashEvent(
      DownloadProgressSplashEvent event, Emitter<SplashState> emit) async {
    if (event.downloadInfo is DownloadInfoOnProgress) {
      DownloadInfoOnProgress downloadInfoOnProgress =
          event.downloadInfo as DownloadInfoOnProgress;
      emit(
        SplashState.downloadProgress(
          downloaded: downloadInfoOnProgress.downloaded,
          contentLength: downloadInfoOnProgress.contentLength,
        ),
      );
    } else if (event.downloadInfo is DownloadInfoOnDone) {
      _subscription?.cancel();

      emit(SplashState.waitingTimeEnded());
    } else if (event.downloadInfo is DownloadInfoOnError) {
      _subscription?.cancel();
      emit(SplashState.error(
          errorMessage:
              (event.downloadInfo as DownloadInfoOnError).errorMessage));
    }
  }

  ///
  Future<void> onCancelDownloadSplashEvent(
    CancelDownloadSplashEvent event,
    Emitter<SplashState> emit,
  ) async {
    PolygonIdSdk.I.proof.cancelDownloadCircuits();

    emit(SplashState.error(errorMessage: "Download cancelled"));
  }
}
