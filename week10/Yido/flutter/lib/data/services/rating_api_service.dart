import 'package:dio/dio.dart';
import 'package:movielog/core/network/api_error.dart';
import 'package:movielog/data/models/common_response.dart';
import 'package:movielog/data/models/rating_dto.dart';
import 'package:movielog/data/models/rating_request.dart';

RatingDto parseRatingResult(Object? data) {
  if (data is! Map<String, dynamic>) {
    throw StateError('평점 응답 형식이 올바르지 않습니다.');
  }
  final common = CommonResponse<RatingDto>.fromJson(
    data,
    (value) => RatingDto.fromJson(value as Map<String, dynamic>),
  );
  final rating = common.result;
  if (rating == null) throw StateError('평점 result가 없습니다.');
  return rating;
}

List<RatingDto> parseRatingList(Object? data) {
  if (data is! List) throw StateError('평점 목록 응답은 배열이어야 합니다.');
  return data
      .map((value) => RatingDto.fromJson(value as Map<String, dynamic>))
      .toList();
}

/// 조회는 공개 Client, 등록·수정·삭제는 토큰을 붙이는 보호 Client로 보낸다
class RatingApiService {
  RatingApiService(this._publicDio, this._authDio);
  final Dio _publicDio;
  final Dio _authDio;

  /// 공개 API라 memberId path를 유지한다. 성공은 공통 형식 없이 배열이다
  Future<List<RatingDto>> fetchMemberRatings(int memberId) async {
    final response = await _publicDio.get('/v8/members/$memberId/ratings');
    return parseRatingList(response.data);
  }

  /// 요청 어디에도 memberId가 없다. 토큰이 회원을 알려 준다
  Future<RatingDto> createRating(CreateRatingRequest request) async {
    final response = await _authDio.post('/v8/ratings', data: request.toJson());
    return parseRatingResult(response.data);
  }

  /// PATCH는 전체 교체라 comment를 생략하면 null로 덮이므로 항상 함께 보낸다
  Future<RatingDto> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    final response = await _authDio.patch(
      '/v8/ratings/$ratingId',
      data: {'score': score, 'comment': comment},
    );
    return parseRatingResult(response.data);
  }

  /// v8 삭제 성공은 204가 아니라 result가 null인 200이다
  Future<void> deleteRating(int ratingId) async {
    final response = await _authDio.delete('/v8/ratings/$ratingId');
    if (response.statusCode != 200) {
      throw StateError('예상하지 못한 삭제 응답: ${response.statusCode}');
    }
  }
}

/// 서버 message를 우선 쓰고, 없으면 통신 실패 문구를 보여 준다
String writeErrorMessage(DioException error) {
  return CommonResponse.tryParseError(error.response?.data)?.message ??
      '요청에 실패했습니다. 잠시 후 다시 시도해 주세요.';
}

/// 평점이 이미 없어졌다는 뜻이라 현재 세션 목록에서도 뺀다
bool isRatingGone(DioException error) => apiErrorCode(error) == 'RATING404_1';
