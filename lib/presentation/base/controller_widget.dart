import 'package:flutter/widgets.dart';
import 'package:leithmail/core/logging/log.dart';
import 'package:leithmail/presentation/base/controller_base.dart';

abstract class ControllerWidget<C extends ControllerBase>
    extends StatefulWidget {
  const ControllerWidget({super.key, required this.controller});

  final C controller;

  Widget build(BuildContext context);

  @override
  State<ControllerWidget<C>> createState() => _ControllerWidgetState<C>();
}

class _ControllerWidgetState<C extends ControllerBase>
    extends State<ControllerWidget<C>> {
  @override
  void initState() {
    Log.info('[${widget.controller.name}] onInit');
    super.initState();
    widget.controller.onInit();
  }

  @override
  void dispose() {
    Log.info('[${widget.controller.name}] onDispose');
    widget.controller.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.build(context);
}
