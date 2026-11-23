import 'package:dio/dio.dart';
import 'package:movielog/core/network/api_error.dart';
import 'package:movielog/data/models/common_response.dart';
import 'package:movielog/data/models/rating_dto.dart';
import 'package:movielog/data/models/rating_request.dart';

/// v7 평점 등록·수정 응답의 result(Rating 객체)를 파싱한다.
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

/// 공개 유저별 평점 조회의 성공 응답은 wrapper 없이 직접 배열이다.
List<RatingDto> parseRatingList(Object? data) {
  if (data is! List) throw StateError('평점 목록 응답은 배열이어야 합니다.');
  return data
      .map((value) => RatingDto.fromJson(value as Map<String, dynamic>))
      .toList();
}

/// 워크북 백엔드 평점 API. 9주차부터 /v8 경로를 쓴다(계약은 v7과 같다).
///
/// | 동작 | v6 | v7~v8 |
/// | 등록 | POST /v6/members/{memberId}/ratings | POST /v8/ratings (201, result=Rating) |
/// | 수정 | PATCH /v6/members/{memberId}/ratings/{id} | PATCH /v8/ratings/{id} (200, result=Rating) |
/// | 삭제 | DELETE ... 204 body 없음 | DELETE /v8/ratings/{id} (200, result=null) |
///
/// 사용자 식별은 path의 memberId가 아니라 `Authorization: Bearer ...`(AuthInterceptor)로 한다.
/// 공개 조회는 공개용 Client, 등록·수정·삭제는 보호용 Client로 보낸다.
class RatingApiService {
  RatingApiService(this._publicDio, this._authDio);

  final Dio _publicDio;
  final Dio _authDio;

  /// 공개 유저별 평점 조회. v7 로그인/내 정보 응답에 memberId가 없어 현재는 화면에서 쓰지 않는다.
  Future<List<RatingDto>> fetchMemberRatings(int memberId) async {
    final response = await _publicDio.get('/v8/members/$memberId/ratings');
    return parseRatingList(response.data);
  }

  /// 등록 body에는 memberId를 넣지 않는다.
  Future<RatingDto> createRating(CreateRatingRequest request) async {
    final response = await _authDio.post('/v8/ratings', data: request.toJson());
    return parseRatingResult(response.data);
  }

  /// PATCH는 부분 수정이 아니라 전체 교체다. comment를 생략하면 null로 덮이므로
  /// Dialog가 기존 score·comment를 채워 두 값을 항상 함께 보낸다.
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

  /// 삭제 성공은 204가 아니라 result=null인 200 wrapper다.
  Future<void> deleteRating(int ratingId) async {
    final response = await _authDio.delete('/v8/ratings/$ratingId');
    if (response.statusCode != 200) {
      throw StateError('예상하지 못한 삭제 응답: ${response.statusCode}');
    }
  }
}

/// v7 평점 쓰기 실패를 도메인 오류 code별 문구로 바꾼다.
/// 세션 만료(AUTH401_2/3/4)는 ViewModel이 expireSession()으로 따로 처리한다.
String ratingErrorMessage(DioException error) {
  return switch (apiErrorCode(error)) {
    'RATING403_1' => '본인이 작성한 평점만 변경할 수 있어요.',
    'RATING404_1' => '이미 삭제되었거나 존재하지 않는 평점이에요.',
    'RATING409_1' => '이미 이 영화에 평점을 남겼어요. 마이페이지에서 기존 기록을 확인해 주세요.',
    'COMMON400' => apiErrorMessage(error) ?? '별점은 1~5 사이로 입력해 주세요.',
    _ when error.response == null => '네트워크 상태를 확인하고 다시 시도해 주세요.',
    _ => apiErrorMessage(error) ?? '요청에 실패했습니다. 잠시 후 다시 시도해 주세요.',
  };
}
