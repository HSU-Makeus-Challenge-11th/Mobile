import 'package:dio/dio.dart';
import 'package:movielog/data/models/member_info.dart';

/// 보호 Client로 내 정보를 조회·수정한다. 회원은 토큰이 알려 준다
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
