abstract class IHostCommand {
  String get name;

  Future action(dynamic action);
}
