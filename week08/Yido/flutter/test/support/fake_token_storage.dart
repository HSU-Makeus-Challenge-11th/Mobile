import 'dart:async';

import 'package:movielog/core/storage/token_storage.dart';

/// 메모리에만 두는 저장소. 실패와 지연을 흉내 낼 수 있다
class FakeTokenStorage implements TokenStorage {
  FakeTokenStorage([this.token]);

  String? token;
  bool failRead = false;
  bool failDelete = false;
  Completer<void>? writeGate;
  int deleteCount = 0;

  @override
  Future<void> saveAccessToken(String token) async {
    await writeGate?.future;
    this.token = token;
  }

  @override
  Future<String?> readAccessToken() async {
    if (failRead) throw StateError('read failed');
    return token;
  }

  @override
  Future<void> deleteAccessToken() async {
    deleteCount++;
    if (failDelete) throw StateError('delete failed');
    token = null;
  }
}
