import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class TokenStorage {
  Future<void> saveAccessToken(String token);
  Future<String?> readAccessToken();
  Future<void> deleteAccessToken();
}

final class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage(this._storage);

  static const accessTokenKey = 'movielog.access_token';
  final FlutterSecureStorage _storage;

  @override
  Future<void> saveAccessToken(String token) =>
      _storage.write(key: accessTokenKey, value: token);

  @override
  Future<String?> readAccessToken() => _storage.read(key: accessTokenKey);

  @override
  Future<void> deleteAccessToken() => _storage.delete(key: accessTokenKey);
}
