import 'package:dio/dio.dart';
import 'package:movielog/models/rating_dto.dart';

class MemberApiService {
  MemberApiService(this._dio);
  final Dio _dio;

  Future<bool> isNicknameAvailable(String nickname) async {
    final response = await _dio.get(
      '/members/nickname/${Uri.encodeComponent(nickname)}',
    );
    return (response.data as Map<String, dynamic>)['available'] as bool;
  }

  Future<bool> isEmailAvailable(String email) async {
    final response = await _dio.get(
      '/members/email/${Uri.encodeComponent(email)}',
    );
    return (response.data as Map<String, dynamic>)['available'] as bool;
  }

  Future<List<RatingDto>> fetchMemberRatings(int memberId) async {
    final response = await _dio.get('/members/$memberId/ratings');
    final list = response.data as List<dynamic>;
    return list
        .map((item) => RatingDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
