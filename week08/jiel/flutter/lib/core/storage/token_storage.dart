import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 액세스 토큰 저장 규칙을 인증 흐름에서 분리한 추상화.
/// 로그인·로그아웃·Interceptor는 이 인터페이스에만 의존한다.
abstract interface class TokenStorage {
  Future<void> saveAccessToken(String token);
  Future<String?> readAccessToken();
  Future<void> deleteAccessToken();
}

/// Android Keystore / iOS Keychain 기반 보안 저장소 구현.
/// 비밀번호는 저장하지 않으며, 토큰 원문을 로그로 남기지 않는다.
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
