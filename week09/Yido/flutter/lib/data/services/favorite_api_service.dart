import 'package:dio/dio.dart';
import 'package:movielog/data/models/common_response.dart';
import 'package:movielog/data/models/favorite_check_dto.dart';
import 'package:movielog/data/models/favorite_response_dto.dart';

/// MovieLog 즐겨찾기 API(/v8/favorites). JWT를 붙이는 보호용 Client만 받는다.
/// 회원은 토큰으로 구분하므로 memberId를 보내지 않는다
class FavoriteApiService {
  FavoriteApiService(this._authDio);
  final Dio _authDio;

  /// 등록: 201, result에 FavoriteResponseDto
  Future<FavoriteResponseDto> addFavorite({required int movieId}) async {
    final response = await _authDio.post(
      '/v8/favorites',
      data: {'movieId': movieId},
    );
    final body = CommonResponse<FavoriteResponseDto>.fromJson(
      response.data as Map<String, dynamic>,
      FavoriteResponseDto.fromJson,
    );
    return body.result!;
  }

  /// 내 목록: 200, result가 배열이고 없으면 빈 배열이다. page 파라미터는 없다
  Future<List<FavoriteResponseDto>> fetchMyFavorites() async {
    final response = await _authDio.get('/v8/favorites');
    final body = CommonResponse<List<FavoriteResponseDto>>.fromJson(
      response.data as Map<String, dynamic>,
      (value) =>
          (value as List<dynamic>).map(FavoriteResponseDto.fromJson).toList(),
    );
    return body.result ?? const [];
  }

  /// 특정 영화 여부: 경로에는 favoriteId가 아니라 TMDB movieId를 넣는다
  Future<FavoriteCheckDto> checkFavorite({required int movieId}) async {
    final response = await _authDio.get('/v8/favorites/$movieId');
    final body = CommonResponse<FavoriteCheckDto>.fromJson(
      response.data as Map<String, dynamic>,
      (value) => FavoriteCheckDto.fromJson(value, movieId: movieId),
    );
    return body.result!;
  }

  /// 해제: 200이고 result가 null이라 본문을 DTO로 파싱하지 않는다
  Future<void> deleteFavorite({required int movieId}) async {
    await _authDio.delete('/v8/favorites/$movieId');
  }
}
