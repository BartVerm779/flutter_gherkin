import 'dart:convert';
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_gherkin/src/flutter/websockets/server.dart';
import 'package:integration_test/common.dart';
import 'package:integration_test/integration_test_driver.dart' as integration_test_driver;
import 'package:path/path.dart' as path;

Future<void> main() async {
  integration_test_driver.testOutputsDirectory = 'integration_test/reports';

  WebsocketServer().startServer();

  return integrationDriver(
    timeout: const Duration(minutes: 90),
  );
}

Future<Map<String, int>> writeGherkinReports(List<dynamic> reports, DateTime currentTime) async {
  //For each report we are going to save the json file.
  for (var i = 0; i < reports.length; i += 1) {
    final reportData = reports.elementAt(i) as List<dynamic>;

    //create the directory if it does not exist.
    await fs.directory(integration_test_driver.testOutputsDirectory).create(recursive: true);

    final version = reports.length == 1 ? "" : "_v${i + 1}";

    //The filename of the report
    final fileName = "${currentTime.day}-${currentTime.month}-${currentTime.year}T${currentTime.hour}_${currentTime.minute}$version.json";

    //Creating the file object to save the data in.
    final File file = fs.file(path.join(
      integration_test_driver.testOutputsDirectory,
      fileName,
    ));

    //Encoding the List<dynamic> to a stringified JSON object.
    final String resultString = _encodeJson(reportData, true);

    //Saving the encoded JSON object into a .json file.
    await file.writeAsString(resultString);
  }
  return {};
}

const JsonEncoder _prettyEncoder = JsonEncoder.withIndent('  ');

String _encodeJson(Object jsonObject, bool pretty) {
  return pretty ? _prettyEncoder.convert(jsonObject) : json.encode(jsonObject);
}

Future<void> integrationDriver({
  Duration timeout = const Duration(minutes: 20),
}) async {
  final FlutterDriver driver = await FlutterDriver.connect();

  final startDateTime = DateTime.now();

  final String jsonResult = await driver.requestData(null, timeout: timeout);
  final Response response = Response.fromJson(jsonResult);

  await driver.close();

  final now = DateTime.now();
  final reports = json.decode(response.data!['gherkin_reports'].toString()) as List<dynamic>;

  await writeGherkinReports(reports, now);

  exit(1);
}
