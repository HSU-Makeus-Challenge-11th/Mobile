import 'package:dio/dio.dart';
import 'package:movielog/data/models/rating_dto.dart';

/// 워크북 자체 백엔드(v5)의 유저별 평점 조회 API.
class RatingApiService {
  RatingApiService(this._dio);
  final Dio _dio;

  /// 평점이 없으면 빈 리스트를 돌려준다(Empty).
  /// memberId 형식 오류(400), 없는 회원(404), 통신 실패는 DioException으로 던진다(Error).
  Future<List<RatingDto>> fetchMyRatings(int memberId) async {
    final response = await _dio.get('/v5/members/$memberId/ratings');
    final list = response.data as List<dynamic>;
    return list
        .map((item) => RatingDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

/// 실패 원인을 하나의 "실패"로 뭉치지 않고 상태 코드별로 다른 문구를 만든다.
String writeMyRatingsErrorMessage(DioException error) {
  final status = error.response?.statusCode;
  if (status == 400) return 'memberId 형식을 다시 확인해 주세요.';
  if (status == 404) return '존재하지 않는 회원입니다.';
  return '평점을 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.';
}
