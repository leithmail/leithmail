import 'package:signals/signals.dart';
import 'package:leithmail/core/logging/log.dart';

class SignalsLogObserver implements SignalsObserver {
  const SignalsLogObserver();

  String _label(ReadonlySignal s) => s.debugLabel ?? s.globalId.toString();
  String _effectLabel(Effect e) => e.debugLabel ?? e.globalId.toString();

  @override
  void onSignalCreated<T>(Signal<T> signal, T value) {
    Log.debug(
      '[signals] signal created ${_label(signal)} = ${_preview(value)}',
    );
  }

  @override
  void onSignalUpdated<T>(Signal<T> signal, T value) {
    Log.debug(
      '[signals] signal updated ${_label(signal)} → ${_preview(value)}',
    );
  }

  @override
  void onComputedCreated<T>(Computed<T> signal) {
    Log.debug('[signals] computed created ${_label(signal)}');
  }

  @override
  void onComputedUpdated<T>(Computed<T> signal, T value) {
    Log.debug(
      '[signals] computed updated ${_label(signal)} → ${_preview(value)}',
    );
  }

  @override
  void onEffectCreated(Effect instance) {
    Log.debug('[signals] effect created ${_effectLabel(instance)}');
  }

  @override
  void onEffectCalled(Effect instance) {
    Log.debug('[signals] effect called ${_effectLabel(instance)}');
  }

  @override
  void onEffectRemoved(Effect instance) {
    Log.debug('[signals] effect removed ${_effectLabel(instance)}');
  }

  String _preview(Object? value) {
    final s = value.toString().replaceAll('\n', ' ');
    return s.length > 60 ? '${s.substring(0, 60)}…' : s;
  }
}
