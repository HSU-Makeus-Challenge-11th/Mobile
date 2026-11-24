import 'package:flutter/foundation.dart';
import 'package:movielog/core/utils/safe_notify.dart';
import 'package:movielog/data/services/app_info_service.dart';

/// 앱 정보 화면에 보여 줄 버전 문구를 들고 있습니다.
class AboutViewModel extends ChangeNotifier with SafeNotify {
  AboutViewModel(this._service);

  final AppInfoService _service;

  String _versionLabel = '확인 중...';
  String get versionLabel => _versionLabel;

  Future<void> load() async {
    try {
      _versionLabel = await _service.getVersionLabel();
    } catch (_) {
      // 버전을 못 읽어도 화면 전체를 오류로 만들지 않고 문구만 바꿉니다.
      _versionLabel = '확인할 수 없음';
    }
    // 버전을 읽는 사이 화면을 벗어났으면 알리지 않습니다.
    notifyIfAlive();
  }
}
