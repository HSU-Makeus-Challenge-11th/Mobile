import 'package:dio/dio.dart';

import '../models/rating.dart';

class RatingApiService {
  RatingApiService(this._dio);

  final Dio _dio;

  Future<List<Rating>> fetchMyRatings(int memberId) async {
    final response = await _dio.get<dynamic>('/members/$memberId/ratings');
    final data = response.data;
    final rawRatings = switch (data) {
      List<dynamic> values => values,
      Map<String, dynamic> values when values['content'] is List<dynamic> =>
        values['content'] as List<dynamic>,
      _ => const <dynamic>[],
    };

    return rawRatings
        .whereType<Map>()
        .map((item) => Rating.fromJson(item.cast<String, dynamic>()))
        .toList(growable: false);
  }
}
