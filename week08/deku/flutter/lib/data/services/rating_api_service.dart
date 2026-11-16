import 'package:dio/dio.dart';

import '../models/common_response.dart';
import '../models/rating.dart';
import '../models/rating_request.dart';

class RatingApiService {
  RatingApiService(this._publicDio, {Dio? authDio})
    : _authDio = authDio ?? _publicDio;

  final Dio _publicDio;
  final Dio _authDio;

  /// Public endpoint. It needs an explicit memberId and cannot restore all of
  /// the current user's ratings from a JWT.
  Future<List<Rating>> fetchUserRatings(int memberId) async {
    final response = await _publicDio.get<dynamic>(
      '/v7/members/$memberId/ratings',
    );
    final data = response.data;
    final result = data is Map ? data['result'] : data;
    if (result is! List) throw const FormatException('평점 목록 응답은 배열이어야 합니다.');
    return result
        .whereType<Map>()
        .map((item) => Rating.fromJson(item.cast<String, dynamic>()))
        .toList(growable: false);
  }

  Future<Rating> createRating({required CreateRatingRequest request}) async {
    final response = await _authDio.post<dynamic>(
      '/v7/ratings',
      data: request.toJson(),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw StateError('예상하지 못한 등록 응답: ${response.statusCode}');
    }
    return _parseRatingResult(response.data);
  }

  Future<Rating> updateRating({
    required int ratingId,
    required int score,
    String? comment,
  }) async {
    final response = await _authDio.patch<dynamic>(
      '/v7/ratings/$ratingId',
      data: {'score': score, 'comment': comment},
    );
    if (response.statusCode != 200) {
      throw StateError('예상하지 못한 수정 응답: ${response.statusCode}');
    }
    return _parseRatingResult(response.data);
  }

  Future<void> deleteRating({required int ratingId}) async {
    final response = await _authDio.delete<dynamic>('/v7/ratings/$ratingId');
    if (response.statusCode != 200 || response.data is! Map) {
      throw StateError('예상하지 못한 삭제 응답: ${response.statusCode}');
    }
    final common = CommonResponse<Object>.fromJson(
      (response.data as Map).cast<String, dynamic>(),
      (value) => value as Object,
    );
    if (!common.isSuccess || common.result != null) {
      throw const FormatException('평점 삭제 응답 형식이 올바르지 않습니다.');
    }
  }

  Rating _parseRatingResult(Object? data) {
    if (data is! Map) throw const FormatException('평점 응답 형식이 올바르지 않습니다.');
    final common = CommonResponse<Rating>.fromJson(
      data.cast<String, dynamic>(),
      (value) => Rating.fromJson((value as Map).cast<String, dynamic>()),
    );
    return common.result ?? (throw const FormatException('평점 result가 없습니다.'));
  }
}
