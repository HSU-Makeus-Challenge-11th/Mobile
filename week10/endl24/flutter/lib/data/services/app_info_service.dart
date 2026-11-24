import 'package:package_info_plus/package_info_plus.dart';

/// 설치된 앱의 버전 정보를 읽습니다.
/// pubspec.yaml의 version: 1.0.0+1에서 만들어진 값이라, version을 바꾸면 다시 빌드한 뒤 반영됩니다.
class AppInfoService {
  /// 예: 1.0.0 (1) — 버전 이름(1.0.0)과 빌드 번호(1)
  Future<String> getVersionLabel() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version} (${info.buildNumber})';
  }
}
