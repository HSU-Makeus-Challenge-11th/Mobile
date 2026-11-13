import 'package:dio/dio.dart';
import 'package:movielog/data/models/common_response.dart';
import 'package:movielog/data/models/rating_dto.dart';
import 'package:movielog/data/models/rating_request.dart';

class RatingApiService {
  RatingApiService(this._dio);
  final Dio _dio;

  Future<List<RatingDto>> fetchMyRatings(int memberId) async {
    final response = await _dio.get('/v6/members/$memberId/ratings');
    final list = response.data as List<dynamic>;
    return list
        .map((item) => RatingDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> createRating({
    required int memberId,
    required CreateRatingRequest request,
  }) async {
    final response = await _dio.post(
      '/v6/members/$memberId/ratings',
      data: request.toJson(),
    );
    // 201을 성공으로 봅니다. 등록 결과는 목록을 다시 조회해서 확인합니다.
    if (response.statusCode != 201) {
      throw StateError('예상하지 못한 등록 응답: ${response.statusCode}');
    }
  }

  Future<void> updateRating({
    required int memberId,
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    // PATCH지만 전체 교체입니다. comment를 빼면 기존 후기가 null로 덮이므로 항상 보냅니다.
    await _dio.patch(
      '/v6/members/$memberId/ratings/$ratingId',
      data: {'score': score, 'comment': comment},
    );
  }

  Future<void> deleteRating({
    required int memberId,
    required int ratingId,
  }) async {
    final response = await _dio.delete(
      '/v6/members/$memberId/ratings/$ratingId',
    );
    // 204는 본문이 없으므로 response.data를 파싱하지 않습니다.
    if (response.statusCode != 204) {
      throw StateError('예상하지 못한 삭제 응답: ${response.statusCode}');
    }
  }
}

String writeMyRatingsErrorMessage(DioException error) {
  final status = error.response?.statusCode;
  if (status == 400) return 'memberId 형식을 다시 확인해 주세요.';
  if (status == 404) return '존재하지 않는 회원입니다.';
  return '평점을 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.';
}

/// 평점 쓰기 실패 응답의 서버 message를 그대로 꺼냅니다.
String writeErrorMessage(DioException error) {
  final data = error.response?.data;
  final common = data is Map<String, dynamic>
      ? CommonResponse<Object?>.fromJson(data, (value) => value)
      : null;
  return common?.message ?? '요청에 실패했습니다. 잠시 후 다시 시도해 주세요.';
}

/// 403·404는 화면 목록이 서버와 어긋났다는 뜻이라 다시 조회합니다.
bool shouldRefreshAfterRatingError(DioException error) {
  final data = error.response?.data;
  final code = data is Map<String, dynamic> ? data['code'] as String? : null;
  return code == 'COMMON403' || code == 'COMMON404';
}
