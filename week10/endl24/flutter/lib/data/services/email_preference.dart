import 'package:shared_preferences/shared_preferences.dart';

/// 로그인 화면의 "이메일 저장"용 저장소입니다.
/// 민감하지 않은 이메일만 shared_preferences에 저장합니다.
/// 비밀번호와 토큰은 절대 여기에 저장하지 않습니다(토큰은 TokenStorage).
class EmailPreference {
  EmailPreference({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _savedEmailKey = 'movielog.saved_email';

  final SharedPreferencesAsync _preferences;

  Future<String?> read() {
    return _preferences.getString(_savedEmailKey);
  }

  /// email이 null이면 저장된 이메일을 지웁니다(체크박스 해제).
  Future<void> save(String? email) async {
    if (email == null) {
      await _preferences.remove(_savedEmailKey);
      return;
    }
    await _preferences.setString(_savedEmailKey, email);
  }
}
