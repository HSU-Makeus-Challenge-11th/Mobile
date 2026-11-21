import 'package:dio/dio.dart';
import 'package:movielog/data/models/common_response.dart';
import 'package:movielog/data/models/movie_record_models.dart';

/// 평점과 즐겨찾기를 서버 한 트랜잭션으로 저장한다. 하나라도 실패하면 모두 저장되지 않는다
class MovieRecordApiService {
  MovieRecordApiService(this._authDio);
  final Dio _authDio;

  Future<MovieRecordDto> createMovieRecord(
    CreateMovieRecordRequest request,
  ) async {
    final response = await _authDio.post(
      '/v8/movie-records',
      data: request.toJson(),
    );
    final body = CommonResponse<MovieRecordDto>.fromJson(
      response.data as Map<String, dynamic>,
      MovieRecordDto.fromJson,
    );
    final record = body.result;
    if (record == null) throw StateError('영화 기록 result가 없습니다.');
    return record;
  }
}
