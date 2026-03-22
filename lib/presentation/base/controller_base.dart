abstract class ControllerBase<ControllerBindings, ControllerInputs> {
  ControllerBase({required this.bindings, required this.inputs});

  final ControllerBindings bindings;
  final ControllerInputs inputs;

  String get name => runtimeType.toString();
  Future<void> onInit() async {}
  void onDispose();
}

abstract class ControllerFactoryBase<
  Controller extends ControllerBase<ControllerBindings, ControllerInputs>,
  ControllerBindings,
  ControllerInputs
> {
  final ControllerBindings bindings;

  ControllerFactoryBase({required this.bindings});

  Controller create(ControllerInputs inputs);
}
