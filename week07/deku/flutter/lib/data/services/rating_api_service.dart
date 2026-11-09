import 'package:dio/dio.dart';

import '../models/rating.dart';
import '../models/rating_request.dart';

class RatingApiService {
  RatingApiService(this._dio);

  final Dio _dio;

  Future<List<Rating>> fetchMyRatings(int memberId) async {
    final response = await _dio.get<dynamic>('/v6/members/$memberId/ratings');
    final data = response.data;
    if (data is! List) throw const FormatException('평점 목록 응답은 배열이어야 합니다.');
    final rawRatings = data;

    return rawRatings
        .whereType<Map>()
        .map((item) => Rating.fromJson(item.cast<String, dynamic>()))
        .toList(growable: false);
  }

  Future<void> createRating({
    required int memberId,
    required CreateRatingRequest request,
  }) async {
    final response = await _dio.post<dynamic>(
      '/v6/members/$memberId/ratings',
      data: request.toJson(),
    );
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
    final response = await _dio.patch<dynamic>(
      '/v6/members/$memberId/ratings/$ratingId',
      data: {'score': score, 'comment': comment},
    );
    if (response.statusCode != 200) {
      throw StateError('예상하지 못한 수정 응답: ${response.statusCode}');
    }
  }

  Future<void> deleteRating({
    required int memberId,
    required int ratingId,
  }) async {
    final response = await _dio.delete<dynamic>(
      '/v6/members/$memberId/ratings/$ratingId',
    );
    if (response.statusCode != 204) {
      throw StateError('예상하지 못한 삭제 응답: ${response.statusCode}');
    }
  }
}
