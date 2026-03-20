import 'package:leithmail/presentation/base/controller_base.dart';

class ControllerFactory<C extends ControllerBase> {
  const ControllerFactory(this._create);

  final C Function() _create;

  C create() => _create();
}
