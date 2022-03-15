import 'dart:io';

import 'package:flutter_gherkin/src/flutter/websockets/command_factory.dart';

class WebsocketServer {
  static const port = 9999;
  late WebSocket webSocket;

  Future startServer() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    server.listen((HttpRequest req) async {
      if (req.uri.path == "/ws") {
        webSocket = await WebSocketTransformer.upgrade(req);
        String? command;
        final stream = webSocket.asBroadcastStream();
        stream.listen((event) {
          if (command == null) {
            command = event.toString();
          } else {
            _handleCommand(command!, event.toString());
            command = null;
          }
        });
      }
    });
  }

  void _handleCommand(String command, String args) {
    CommandFactory().handleCommand(command, args).then((result) {
      webSocket.add(result);
      webSocket.close();
    });
  }
}
