import 'package:dio/dio.dart';

import '../models/member_info.dart';

/// 내 정보 조회·수정. 둘 다 보호 API이므로 보호용 Client(AuthInterceptor 등록)를 받는다.
class MemberApiService {
  MemberApiService(this._authDio);

  final Dio _authDio;

  Future<MemberInfo> fetchMe() async {
    final response = await _authDio.get('/v7/members/me');
    return parseMemberInfo(response.data);
  }

  Future<MemberInfo> updateNickname(String nickname) async {
    final response = await _authDio.patch(
      '/v7/members/me',
      data: {'nickname': nickname},
    );
    return parseMemberInfo(response.data);
  }
}
