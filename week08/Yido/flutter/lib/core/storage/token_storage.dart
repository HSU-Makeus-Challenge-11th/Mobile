import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 토큰 저장·조회·삭제를 한곳에 모은다. 인증 로직은 구체 저장소를 모른다
abstract interface class TokenStorage {
  Future<void> saveAccessToken(String token);
  Future<String?> readAccessToken();
  Future<void> deleteAccessToken();
}

/// iOS Keychain, Android Keystore에 암호화해 저장한다
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage(this._storage);
  static const _accessTokenKey = 'movielog.access_token';
  final FlutterSecureStorage _storage;

  @override
  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  @override
  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  @override
  Future<void> deleteAccessToken() => _storage.delete(key: _accessTokenKey);
}
