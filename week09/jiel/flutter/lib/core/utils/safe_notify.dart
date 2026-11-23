import 'package:flutter/foundation.dart';

/// 화면이 사라진(dispose) 뒤에는 notifyListeners()를 호출하지 않게 막는 mixin.
/// 서버 응답은 늦게 도착할 수 있으므로, 결과를 반영하기 전에 isDisposed를 확인한다.
mixin SafeNotify on ChangeNotifier {
  bool _disposed = false;
  bool get isDisposed => _disposed;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void notifyIfAlive() {
    if (!_disposed) notifyListeners();
  }
}
