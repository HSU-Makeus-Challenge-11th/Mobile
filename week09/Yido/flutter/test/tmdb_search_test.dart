import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';

import 'support/recording_adapter.dart';

void main() {
  test('search sends query and page and parses the page', () async {
    final adapter = RecordingAdapter(200, {
      'page': 2,
      'results': [
        {
          'id': 550,
          'title': '별빛 아래 우리',
          'overview': '',
          'poster_path': null,
          'backdrop_path': null,
          'release_date': '2025-01-01',
          'genre_ids': [18],
          'vote_average': 8.0,
          'popularity': 1.0,
        },
      ],
      'total_pages': 3,
      'total_results': 41,
    });
    final service = TmdbMovieService(
      Dio(BaseOptions(baseUrl: 'https://example.com'))
        ..httpClientAdapter = adapter,
    );
    final page = await service.searchMovies(page: 2, query: '별빛');
    expect(adapter.request!.path, '/search/movie');
    expect(adapter.request!.queryParameters['query'], '별빛');
    expect(adapter.request!.queryParameters['page'], 2);
    expect(adapter.request!.queryParameters['include_adult'], false);
    expect(page.page, 2);
    expect(page.totalPages, 3);
    expect(page.results.single.id, 550);
  });
}
