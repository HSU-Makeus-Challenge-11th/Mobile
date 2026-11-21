import 'package:flutter/foundation.dart';

/// 화면이 사라져 ViewModel이 dispose된 뒤에는 notifyListeners()를 부르지 않게 막습니다.
/// 서버 응답이 화면을 벗어난 뒤에 늦게 도착해도 오류가 나지 않습니다.
///
/// 사용법: `class XxxViewModel extends ChangeNotifier with SafeNotify`
/// - notifyListeners() 대신 notifyIfAlive()를 호출합니다.
/// - 응답을 상태에 반영하기 전에 isDisposed를 확인합니다.
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
