import 'package:dio/dio.dart';
import 'package:movielog/data/models/common_response.dart';
import 'package:movielog/data/models/rating_dto.dart';
import 'package:movielog/data/models/rating_request.dart';

/// 워크북 자체 백엔드(v6)의 회원별 평점 CRUD API.
///
/// API별 성공 응답 계약이 다르므로 각각 다르게 파싱한다.
/// - 조회 GET  : 200 + 직접 배열
/// - 등록 POST : 201 + 공통 wrapper (result 계약 미확정 → 파싱하지 않음)
/// - 수정 PATCH: 200 + 공통 wrapper (result null)
/// - 삭제 DELETE: 204 + body 없음 (JSON으로 파싱하지 않음)
class RatingApiService {
  RatingApiService(this._dio);
  final Dio _dio;

  /// 평점이 없으면 빈 리스트를 돌려준다(Empty).
  /// memberId 형식 오류(400), 없는 회원(404), 통신 실패는 DioException으로 던진다(Error).
  Future<List<RatingDto>> fetchMyRatings(int memberId) async {
    final response = await _dio.get('/v6/members/$memberId/ratings');
    final list = response.data as List<dynamic>;
    return list
        .map((item) => RatingDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// 평점 등록. 201을 성공으로 처리한다.
  /// Swagger 설명은 result가 ratingId 숫자라고 하지만 schema 예시는 null이라,
  /// 계약이 확정되기 전에는 result를 강제 캐스팅하지 않는다. 등록 후 목록 GET으로 확인한다.
  Future<void> createRating({
    required int memberId,
    required CreateRatingRequest request,
  }) async {
    final response = await _dio.post(
      '/v6/members/$memberId/ratings',
      data: request.toJson(),
    );
    if (response.statusCode != 201) {
      throw StateError('예상하지 못한 등록 응답: ${response.statusCode}');
    }
  }

  /// 평점 수정. PATCH지만 score는 필수다.
  /// comment를 생략하면 기존 후기가 null로 덮이는 계약이므로, 유지하려면 기존 값을 명시적으로 보낸다.
  Future<void> updateRating({
    required int memberId,
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    await _dio.patch(
      '/v6/members/$memberId/ratings/$ratingId',
      data: {'score': score, 'comment': comment},
    );
  }

  /// 평점 삭제. 204는 body가 없으므로 response.data를 Map으로 캐스팅하지 않는다.
  Future<void> deleteRating({
    required int memberId,
    required int ratingId,
  }) async {
    final response = await _dio.delete(
      '/v6/members/$memberId/ratings/$ratingId',
    );
    if (response.statusCode != 204) {
      throw StateError('예상하지 못한 삭제 응답: ${response.statusCode}');
    }
  }
}

/// 조회 실패 원인을 하나의 "실패"로 뭉치지 않고 상태 코드별로 다른 문구를 만든다.
String writeMyRatingsErrorMessage(DioException error) {
  final status = error.response?.statusCode;
  if (status == 400) return 'memberId 형식을 다시 확인해 주세요.';
  if (status == 404) return '존재하지 않는 회원입니다.';
  return '평점을 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.';
}

/// 쓰기(등록·수정·삭제) 실패 응답의 서버 message를 그대로 돌려준다.
/// 같은 COMMON404라도 등록에서는 "유저", 수정·삭제에서는 "평점"을 가리키므로
/// code만 보고 문구를 새로 만들지 않는다. code는 다음 UI 행동을 정하는 데만 쓴다.
String writeErrorMessage(DioException error) {
  final data = error.response?.data;
  final common = data is Map<String, dynamic>
      ? CommonResponse<Object?>.fromJson(data, (value) => value)
      : null;
  return common?.message ?? '요청에 실패했습니다. 잠시 후 다시 시도해 주세요.';
}

/// 쓰기 실패 뒤 목록을 다시 조회해야 하는지.
/// 403(본인 평점 아님)·404(평점 없음)는 화면에 남은 목록이 서버 상태와 어긋났다는 뜻이라 다시 조회한다.
/// 400(별점 범위)·409(중복 등록)는 같은 화면에서 값만 고치면 되므로 다시 조회하지 않는다.
bool shouldRefreshAfterRatingError(DioException error) {
  final data = error.response?.data;
  final code = data is Map<String, dynamic> ? data['code'] as String? : null;
  return code == 'COMMON403' || code == 'COMMON404';
}
