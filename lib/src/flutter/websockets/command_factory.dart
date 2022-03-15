import 'commandDefinitions/i_host_command.dart';

class CommandFactory {
  Future<dynamic> handleCommand(String commandName, String args) async {
    for (final command in _getCommands()) {
      if (command.name == commandName) {
        return command.action(args);
      }
    }
  }

  List<IHostCommand> _getCommands() {
    return [];
  }
}
