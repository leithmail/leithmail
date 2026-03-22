import 'package:flutter/widgets.dart';
import 'package:leithmail/core/logging/log.dart';
import 'package:leithmail/presentation/base/controller_base.dart';

abstract class ControllerWidget<
  Controller extends ControllerBase<ControllerBindings, ControllerInputs>,
  ControllerBindings,
  ControllerInputs
>
    extends StatefulWidget {
  const ControllerWidget({
    super.key,
    required this.factory,
    required this.inputs,
  });

  final ControllerFactoryBase<Controller, ControllerBindings, ControllerInputs>
  factory;
  final ControllerInputs inputs;

  Widget build(BuildContext context, Controller controller);

  @override
  State<ControllerWidget<Controller, ControllerBindings, ControllerInputs>>
  createState() =>
      _ControllerWidgetState<
        Controller,
        ControllerBindings,
        ControllerInputs
      >();
}

class _ControllerWidgetState<
  Controller extends ControllerBase<ControllerBindings, ControllerInputs>,
  ControllerBindings,
  ControllerInputs
>
    extends
        State<
          ControllerWidget<Controller, ControllerBindings, ControllerInputs>
        > {
  late final Controller controller;

  @override
  void initState() {
    super.initState();
    controller = widget.factory.create(widget.inputs);
    Log.info('[${controller.name}] onInit');
    controller.onInit();
  }

  @override
  void dispose() {
    Log.info('[${controller.name}] onDispose');
    controller.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.build(context, controller);
}
