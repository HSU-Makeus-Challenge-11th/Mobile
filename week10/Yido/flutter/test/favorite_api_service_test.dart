import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/models/favorite_check_dto.dart';
import 'package:movielog/data/services/favorite_api_service.dart';

import 'support/recording_adapter.dart';

void main() {
  (FavoriteApiService, RecordingAdapter) service(int status, [Object? body]) {
    final adapter = RecordingAdapter(status, body);
    final dio = Dio(BaseOptions(baseUrl: 'https://example.com'))
      ..httpClientAdapter = adapter;
    return (FavoriteApiService(dio), adapter);
  }

  final favorite = {
    'favoriteId': 3,
    'movieId': 550,
    'createdAt': '2026-09-06T12:14:03.000Z',
  };

  test('add posts only movieId and reads the created favorite', () async {
    final (api, adapter) = service(201, ok(favorite, code: 'COMMON201'));
    final created = await api.addFavorite(movieId: 550);
    expect(adapter.request!.method, 'POST');
    expect(adapter.request!.path, '/v8/favorites');
    expect(adapter.request!.data, {'movieId': 550});
    expect(created.favoriteId, 3);
    expect(created.movieId, 550);
  });

  test('my favorites read the result array, and null becomes empty', () async {
    var (api, adapter) = service(200, ok([favorite]));
    final list = await api.fetchMyFavorites();
    expect(adapter.request!.path, '/v8/favorites');
    expect(list.single.movieId, 550);

    (api, adapter) = service(200, ok([]));
    expect(await api.fetchMyFavorites(), isEmpty);
  });

  test('check uses movieId in the path and keeps it in the DTO', () async {
    final (api, adapter) = service(200, ok({'isFavorite': true}));
    final checked = await api.checkFavorite(movieId: 550);
    expect(adapter.request!.path, '/v8/favorites/550');
    expect(checked.movieId, 550);
    expect(checked.isFavorite, isTrue);
  });

  test('check rejects a result without a boolean isFavorite', () {
    expect(
      () => FavoriteCheckDto.fromJson({'isFavorite': 'yes'}, movieId: 1),
      throwsFormatException,
    );
  });

  test('delete succeeds on 200 with a null result', () async {
    final (api, adapter) = service(200, ok(null));
    await api.deleteFavorite(movieId: 550);
    expect(adapter.request!.method, 'DELETE');
    expect(adapter.request!.path, '/v8/favorites/550');
  });

  test('error codes stay on the DioException', () async {
    final (api, _) = service(409, failBody('FAVORITE409_1'));
    await expectLater(
      api.addFavorite(movieId: 550),
      throwsA(
        isA<DioException>().having(
          (e) => (e.response!.data as Map)['code'],
          'code',
          'FAVORITE409_1',
        ),
      ),
    );
  });
}
