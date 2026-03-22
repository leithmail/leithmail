import 'package:leithmail/presentation/base/controller_base.dart';

abstract class ControllerFactoryBase<C extends ControllerBase, I> {
  C create(I input);

  C call(I input) {
    return create(input);
  }
}
