import 'package:dio/dio.dart';

import '../models/common_response.dart';
import '../models/favorite.dart';

class FavoriteApiService {
  FavoriteApiService(this._authDio);

  final Dio _authDio;

  Future<List<Favorite>> fetchFavorites() async {
    final response = await _authDio.get<dynamic>('/v8/favorites');
    final result = _parse(response.data, (raw) {
      if (raw is! List) throw const FormatException('즐겨찾기 목록이 배열이 아닙니다.');
      return raw
          .map((item) {
            if (item is! Map) {
              throw const FormatException('즐겨찾기 항목이 올바르지 않습니다.');
            }
            return Favorite.fromJson(item.cast<String, dynamic>());
          })
          .toList(growable: false);
    });
    return result ?? const [];
  }

  Future<bool> isFavorite(int movieId) async {
    final response = await _authDio.get<dynamic>('/v8/favorites/$movieId');
    final result = _parse(response.data, (raw) {
      if (raw is! Map || raw['isFavorite'] is! bool) {
        throw const FormatException('즐겨찾기 여부 응답이 올바르지 않습니다.');
      }
      return raw['isFavorite'] as bool;
    });
    return result ?? (throw const FormatException('즐겨찾기 여부가 없습니다.'));
  }

  Future<Favorite> addFavorite(int movieId) async {
    final response = await _authDio.post<dynamic>(
      '/v8/favorites',
      data: {'movieId': movieId},
    );
    if (response.statusCode != 201) {
      throw StateError('예상하지 못한 즐겨찾기 등록 응답: ${response.statusCode}');
    }
    final result = _parse(response.data, (raw) {
      if (raw is! Map) throw const FormatException('즐겨찾기 등록 응답이 올바르지 않습니다.');
      return Favorite.fromJson(raw.cast<String, dynamic>());
    });
    return result ?? (throw const FormatException('즐겨찾기 등록 결과가 없습니다.'));
  }

  Future<void> removeFavorite(int movieId) async {
    final response = await _authDio.delete<dynamic>('/v8/favorites/$movieId');
    if (response.statusCode != 200 || response.data is! Map) {
      throw StateError('예상하지 못한 즐겨찾기 해제 응답: ${response.statusCode}');
    }
    final common = CommonResponse<Object>.fromJson(
      (response.data as Map).cast<String, dynamic>(),
      (raw) => raw as Object,
    );
    if (!common.isSuccess || common.result != null) {
      throw const FormatException('즐겨찾기 해제 응답이 올바르지 않습니다.');
    }
  }

  T? _parse<T>(Object? data, T Function(Object?) parseResult) {
    if (data is! Map) throw const FormatException('즐겨찾기 응답이 올바르지 않습니다.');
    final common = CommonResponse<T>.fromJson(
      data.cast<String, dynamic>(),
      parseResult,
    );
    if (!common.isSuccess) throw StateError(common.message);
    return common.result;
  }
}
