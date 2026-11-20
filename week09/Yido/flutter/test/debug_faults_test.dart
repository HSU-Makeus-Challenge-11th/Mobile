import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/core/debug/debug_faults.dart';

void main() {
  final faults = DebugFaults.instance;
  tearDown(faults.clear);

  RequestOptions request(String path, {String method = 'GET', int? page}) =>
      RequestOptions(
        baseUrl: 'https://example.com',
        path: path,
        method: method,
        queryParameters: {'page': ?page},
      );

  test('each switch fails exactly one matching request', () {
    faults.nextPage = true;
    expect(faults.consume(request('/3/discover/movie', page: 1)), isFalse);
    expect(faults.consume(request('/3/discover/movie', page: 2)), isTrue);
    expect(faults.consume(request('/3/discover/movie', page: 2)), isFalse);

    faults.favoriteList = true;
    expect(faults.consume(request('/v8/favorites', method: 'POST')), isFalse);
    expect(faults.consume(request('/v8/favorites')), isTrue);

    faults.movieDetail = true;
    expect(faults.consume(request('/3/movie/550')), isTrue);
    expect(faults.consume(request('/3/movie/551')), isFalse);

    faults.favoriteWrite = true;
    expect(
      faults.consume(request('/v8/favorites/550', method: 'DELETE')),
      isTrue,
    );

    faults.search = true;
    expect(faults.consume(request('/3/search/movie', page: 1)), isTrue);
  });
}
