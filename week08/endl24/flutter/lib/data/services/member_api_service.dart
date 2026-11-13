import 'package:dio/dio.dart';
import 'package:movielog/data/models/member_info.dart';

/// 내 정보는 보호 API라 AuthInterceptor가 등록된 보호용 Client를 받습니다.
class MemberApiService {
  MemberApiService(this._authDio);
  final Dio _authDio;

  Future<MemberInfo> fetchMe() async {
    final response = await _authDio.get('/v7/members/me');
    return parseMemberInfo(response.data);
  }

  /// 닉네임만 바꿀 수 있습니다. 성공 result는 수정된 내 정보 전체입니다.
  Future<MemberInfo> updateNickname(String nickname) async {
    final response = await _authDio.patch(
      '/v7/members/me',
      data: {'nickname': nickname},
    );
    return parseMemberInfo(response.data);
  }
}
