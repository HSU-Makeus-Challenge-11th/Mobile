import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/data/models/tmdb_movie_page.dart';

void main() {
  test('snake_case, null, num 값을 Dart Model로 변환한다', () {
    final page = TmdbMoviePageDto.fromJson({
      'page': 1,
      'total_pages': 3,
      'total_results': 50,
      'results': [
        {
          'id': 550,
          'title': null,
          'overview': null,
          'poster_path': null,
          'release_date': '',
          'genre_ids': [18, 53.0],
          'vote_average': 8,
          'popularity': 120.5,
        },
      ],
    });

    final movie = page.results.single;
    expect(page.totalPages, 3);
    expect(movie.id, 550);
    expect(movie.title, '제목 없음');
    expect(movie.overview, '');
    expect(movie.posterPath, isNull);
    expect(movie.releaseYear, isNull);
    expect(movie.genreIds, [18, 53]);
    expect(movie.voteAverage, 8.0);
  });

  test('release_date에서 연도만 꺼낸다', () {
    final movie = TmdbMovieDto.fromJson({
      'id': 1,
      'release_date': '2024-05-01',
    });
    expect(movie.releaseYear, '2024');
  });
}
