abstract class ControllerBase {
  String get name => runtimeType.toString();
  Future<void> onInit() async {}
  void onDispose();
}
