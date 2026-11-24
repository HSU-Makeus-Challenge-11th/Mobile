import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 액세스 토큰 저장 규칙입니다.
/// 로그인·로그아웃·Interceptor는 이 인터페이스만 알고, 실제 저장 방식은 모릅니다.
abstract interface class TokenStorage {
  Future<void> saveAccessToken(String token);
  Future<String?> readAccessToken();
  Future<void> deleteAccessToken();
}

/// 운영체제 보안 저장소(iOS Keychain / Android Keystore)에 토큰을 보관합니다.
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage(this._storage);

  static const _accessTokenKey = 'movielog.access_token';
  final FlutterSecureStorage _storage;

  @override
  Future<void> saveAccessToken(String token) {
    return _storage.write(key: _accessTokenKey, value: token);
  }

  @override
  Future<String?> readAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  @override
  Future<void> deleteAccessToken() {
    return _storage.delete(key: _accessTokenKey);
  }
}
