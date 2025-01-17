import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:polygonid_flutter_sdk/proof/domain/exceptions/proof_generation_exceptions.dart';
import 'package:polygonid_flutter_sdk/sdk/di/injector.dart';
import 'package:path/path.dart' as pathLib;

class CircuitsFilesDataSource {
  final Directory directory;

  CircuitsFilesDataSource(this.directory);

  Future<Uint8List> loadGraphFile(String circuitId) async {
    try {
      final path = "assets/$circuitId.wcd";
      final circuitGraphFile = await rootBundle.load(path);
      return circuitGraphFile.buffer.asUint8List();
    } catch (_) {
      throw CircuitNotDownloadedException(
        circuit: circuitId,
        errorMessage:
            "Circuit $circuitId not found at assets path \"assets/$circuitId.wcd\"",
      );
    }
  }

  Future<String> getZkeyFilePath(String circuitId) async {
    final circuitZkeyFileName = '$circuitId.zkey';
    final circuitZkeyFilePath = '${directory.path}/$circuitZkeyFileName';

    final circuitZkeyFile = File(circuitZkeyFilePath);
    if (!circuitZkeyFile.existsSync()) {
      throw CircuitNotDownloadedException(
        circuit: circuitId,
        errorMessage: "Circuit $circuitId not downloaded or not found",
      );
    }

    return circuitZkeyFilePath;
  }

  ///
  Future<bool> circuitsFilesExist({required String circuitsFileName}) async {
    String fileName = '${circuitsFileName.trim()}.zip';
    String path = directory.path;
    var file = File('$path/$fileName');

    return file.exists();
  }

  Future<String> getPathToCircuitZipFile(
      {required String circuitsFileName}) async {
    String path = directory.path;
    String fileName = '${circuitsFileName.trim()}.zip';

    return '$path/$fileName';
  }

  Future<String> getPathToCircuitZipFileTemp(
      {required String circuitsFileName}) async {
    String path = directory.path;
    String fileName = '${circuitsFileName.trim()}_temp.zip';

    return '$path/$fileName';
  }

  Future<String> getPath() async {
    return Future.value(directory.path);
  }

  Future<void> deleteFile(String pathToFile) async {
    try {
      var file = File(pathToFile);
      await file.delete();
    } catch (_) {
      // file not found? no problem, we don't need it
    }
  }

  void renameFile(String pathTofile, String newPathToFile) {
    var file = File(pathTofile);
    file.renameSync(newPathToFile);
  }

  void writeZipFile({
    required String pathToFile,
    required List<int> zipBytes,
  }) {
    var file = File(pathToFile);
    file.writeAsBytesSync(
      zipBytes,
      mode: FileMode.append,
    );
  }

  int zipFileSize({required String pathToFile}) {
    var file = File(pathToFile);
    return file.lengthSync();
  }

  Future<void> writeCircuitsFileFromZip({
    required String path,
    required String zipPath,
  }) async {
    var zipFile = File(zipPath);
    Uint8List zipBytes = zipFile.readAsBytesSync();
    final zipDecoder = getItSdk.get<ZipDecoder>();
    var archive = zipDecoder.decodeBytes(zipBytes);

    for (var file in archive) {
      var filename = pathLib.join(path, pathLib.basename(file.name));
      if (file.isFile) {
        var outFile = File(filename);
        outFile = await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content);
      }
    }
  }
}
