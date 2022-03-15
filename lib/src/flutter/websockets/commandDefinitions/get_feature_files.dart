import 'package:flutter_gherkin/src/flutter/websockets/commandDefinitions/i_host_command.dart';
import 'package:gherkin/gherkin.dart';

import '../command_definitions.dart';

class GetFeatureFiles implements IHostCommand {
  final _featureFileReader = const IoFeatureFileAccessor();
  final _featureFileMatcher = const IoFeatureFileAccessor();

  String get name => WebSocketCommands.GetFeatureFile;

  Future action(dynamic path) async {
    final paths = await _featureFileMatcher.listFiles(path);
    var featureFiles = [];

    for (var path in paths) {
      featureFiles.add(await _featureFileReader.read(path));
    }
    return featureFiles;
  }
}
