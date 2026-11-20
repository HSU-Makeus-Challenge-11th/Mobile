import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/utils/safe_notify.dart';

class _Model extends ChangeNotifier with SafeNotify {}

void main() {
  test('notifyIfAlive is silent after dispose', () {
    final model = _Model();
    var calls = 0;
    model.addListener(() => calls++);
    model.notifyIfAlive();
    expect(calls, 1);
    model.dispose();
    expect(model.isDisposed, isTrue);
    expect(model.notifyIfAlive, returnsNormally);
  });
}
