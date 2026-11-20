import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/models/movie_record_models.dart';
import 'package:movielog/data/services/movie_record_api_service.dart';

import 'support/recording_adapter.dart';

void main() {
  final rating = {
    'ratingId': 9,
    'movieId': 550,
    'score': 3,
    'comment': '예시 후기',
    'createdAt': '2026-11-20T09:00:00.000Z',
    'updatedAt': '2026-11-20T09:00:00.000Z',
  };

  MovieRecordApiService service(RecordingAdapter adapter) =>
      MovieRecordApiService(
        Dio(BaseOptions(baseUrl: 'https://example.com'))
          ..httpClientAdapter = adapter,
      );

  test('sends the record body and reads rating and favorite', () async {
    final adapter = RecordingAdapter(
      201,
      ok({
        'rating': rating,
        'favorite': {
          'favoriteId': 4,
          'movieId': 550,
          'createdAt': '2026-11-20T09:00:00.000Z',
        },
      }, code: 'COMMON201'),
    );
    final record = await service(adapter).createMovieRecord(
      const CreateMovieRecordRequest(
        movieId: 550,
        score: 3,
        comment: '예시 후기',
        addToFavorites: true,
      ),
    );
    expect(adapter.request!.path, '/v8/movie-records');
    expect(adapter.request!.data, {
      'movieId': 550,
      'score': 3,
      'comment': '예시 후기',
      'addToFavorites': true,
    });
    expect(record.rating.ratingId, 9);
    expect(record.favorite!.favoriteId, 4);
  });

  test('favorite is null when addToFavorites is false', () async {
    final adapter = RecordingAdapter(
      201,
      ok({'rating': rating, 'favorite': null}, code: 'COMMON201'),
    );
    final record = await service(adapter).createMovieRecord(
      const CreateMovieRecordRequest(
        movieId: 550,
        score: 3,
        addToFavorites: false,
      ),
    );
    expect(adapter.request!.data, {
      'movieId': 550,
      'score': 3,
      'addToFavorites': false,
    });
    expect(record.favorite, isNull);
  });
}
