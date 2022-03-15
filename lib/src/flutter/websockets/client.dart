import 'dart:async';

import 'dart:io';

class WebsocketClient {
  final _completer = Completer();
  late WebSocket webSocket;

  Future sendCommand(String commandName, {String additionalData = ""}) async {
    webSocket = await WebSocket.connect("ws://10.0.2.2:9999/ws");
    webSocket.listen(_handleMessage);
    webSocket.add(commandName);
    webSocket.add(additionalData);
    return _completer.future;
  }

  void _handleMessage(dynamic message) {
    if (!_completer.isCompleted) {
      webSocket.close();
      _completer.complete(message);
    }
  }
}