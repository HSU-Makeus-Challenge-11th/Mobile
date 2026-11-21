import 'package:package_info_plus/package_info_plus.dart';

/// 설치된 앱의 버전 정보. pubspec.yaml의 version(1.0.0+1)에서 만들어진 값을 읽는다
class AppInfoService {
  Future<String> getVersionLabel() async {
    final info = await PackageInfo.fromPlatform();
    return '${info.version} (${info.buildNumber})';
  }
}
