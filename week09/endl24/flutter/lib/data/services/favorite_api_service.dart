import 'package:dio/dio.dart';
import 'package:movielog/data/models/common_response.dart';
import 'package:movielog/data/models/favorite_check_dto.dart';
import 'package:movielog/data/models/favorite_response_dto.dart';

/// MovieLog 즐겨찾기 API(/v8/favorites)를 호출합니다.
/// 네 API 모두 로그인이 필요해서 보호용 Client(JWT Interceptor 포함)만 받습니다.
class FavoriteApiService {
  FavoriteApiService(this._authDio);
  final Dio _authDio;

  /// 즐겨찾기 등록: 201, result에 등록된 즐겨찾기가 담깁니다.
  Future<FavoriteResponseDto> addFavorite({required int movieId}) async {
    final response = await _authDio.post(
      '/v8/favorites',
      data: {'movieId': movieId},
    );
    final body = CommonResponse<FavoriteResponseDto>.fromJson(
      response.data as Map<String, dynamic>,
      FavoriteResponseDto.fromJson,
    );
    final favorite = body.result;
    if (favorite == null) throw StateError('즐겨찾기 등록 result가 없습니다.');
    return favorite;
  }

  /// 내 즐겨찾기 조회: 200, result가 배열입니다. 없으면 빈 배열입니다.
  Future<List<FavoriteResponseDto>> fetchMyFavorites() async {
    final response = await _authDio.get('/v8/favorites');
    final body = CommonResponse<List<FavoriteResponseDto>>.fromJson(
      response.data as Map<String, dynamic>,
      (value) =>
          (value as List<dynamic>).map(FavoriteResponseDto.fromJson).toList(),
    );
    return body.result ?? const [];
  }

  /// 특정 영화의 즐겨찾기 여부 조회: 응답에 movieId가 없어서 요청한 값을 함께 넘깁니다.
  Future<FavoriteCheckDto> checkFavorite({required int movieId}) async {
    final response = await _authDio.get('/v8/favorites/$movieId');
    final body = CommonResponse<FavoriteCheckDto>.fromJson(
      response.data as Map<String, dynamic>,
      (value) => FavoriteCheckDto.fromJson(value, movieId: movieId),
    );
    final check = body.result;
    if (check == null) throw StateError('즐겨찾기 여부 result가 없습니다.');
    return check;
  }

  /// 즐겨찾기 해제: 200, result는 null입니다. 경로에는 favoriteId가 아니라 movieId를 씁니다.
  Future<void> deleteFavorite({required int movieId}) async {
    await _authDio.delete('/v8/favorites/$movieId');
  }
}
