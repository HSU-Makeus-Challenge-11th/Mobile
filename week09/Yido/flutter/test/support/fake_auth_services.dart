import 'dart:async';

import 'package:dio/dio.dart';
import 'package:movielog/data/models/login_models.dart';
import 'package:movielog/data/models/member_info.dart';
import 'package:movielog/data/services/auth_api_service.dart';
import 'package:movielog/data/services/member_api_service.dart';

DioException apiError(String path, int status, String code) {
  final options = RequestOptions(path: path);
  return DioException(
    requestOptions: options,
    response: Response(
      requestOptions: options,
      statusCode: status,
      data: {'isSuccess': false, 'code': code, 'message': '실패', 'result': null},
    ),
  );
}

DioException networkError(String path) =>
    DioException(requestOptions: RequestOptions(path: path));

MemberInfo fakeMember([String nickname = '시네필A']) => MemberInfo(
  email: 'a@umc.com',
  nickname: nickname,
  createdAt: DateTime(2026, 10, 10),
);

class FakeAuthApiService extends AuthApiService {
  FakeAuthApiService() : super(Dio());
  Object? error;
  Completer<void>? gate;
  final requests = <LoginRequest>[];

  @override
  Future<LoginResult> login(LoginRequest request) async {
    requests.add(request);
    await gate?.future;
    final failure = error;
    if (failure != null) throw failure;
    return const LoginResult(nickname: '시네필A', accessToken: 'new.token.value');
  }
}

class FakeMemberApiService extends MemberApiService {
  FakeMemberApiService() : super(Dio());
  Object? error;
  Completer<void>? gate;
  MemberInfo member = fakeMember();
  int fetchCount = 0;
  final updates = <String>[];

  @override
  Future<MemberInfo> fetchMe() async {
    fetchCount++;
    await gate?.future;
    final failure = error;
    if (failure != null) throw failure;
    return member;
  }

  @override
  Future<MemberInfo> updateNickname(String nickname) async {
    updates.add(nickname);
    await gate?.future;
    final failure = error;
    if (failure != null) throw failure;
    return member = fakeMember(nickname);
  }
}
