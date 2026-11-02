import 'package:dio/dio.dart';
import 'package:movielog/data/models/check_result.dart';

/// 워크북 자체 백엔드(v5)의 닉네임·이메일 중복 확인 API.
/// 상태를 갖지 않으므로 앱 최상단 Provider에 하나만 등록해 공유한다.
class MemberCheckService {
  MemberCheckService(this._dio);
  final Dio _dio;

  /// 사용 가능하면 true, 이미 사용 중이면 false.
  /// 통신 자체가 실패하면 DioException을 그대로 던진다.
  Future<bool> checkNickname(String nickname) async {
    final encoded = Uri.encodeComponent(nickname.trim());
    final response = await _dio.get('/v5/members/nickname/$encoded');
    return CheckResult.fromJson(response.data as Map<String, dynamic>).available;
  }

  Future<bool> checkEmail(String email) async {
    final encoded = Uri.encodeComponent(email.trim());
    final response = await _dio.get('/v5/members/email/$encoded');
    return CheckResult.fromJson(response.data as Map<String, dynamic>).available;
  }
}
