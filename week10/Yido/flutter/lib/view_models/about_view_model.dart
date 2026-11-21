import 'package:flutter/foundation.dart';
import 'package:movielog/core/utils/safe_notify.dart';
import 'package:movielog/data/services/app_info_service.dart';

/// 앱 정보 화면의 버전 문구. 읽기에 실패해도 화면 전체를 오류로 만들지 않는다
class AboutViewModel extends ChangeNotifier with SafeNotify {
  AboutViewModel(this._service);
  final AppInfoService _service;

  String _versionLabel = '확인 중...';
  String get versionLabel => _versionLabel;

  Future<void> load() async {
    try {
      _versionLabel = await _service.getVersionLabel();
    } catch (_) {
      _versionLabel = '확인할 수 없음';
    }
    notifyIfAlive(); // 읽는 동안 화면을 벗어났다면 알리지 않는다
  }
}
