import 'package:dio/dio.dart';

import '../models/tmdb_genre_dto.dart';
import '../models/tmdb_movie_dto.dart';
import '../models/tmdb_movie_page_dto.dart';

abstract interface class MovieService {
  Future<TmdbMoviePageDto> fetchPopular({int page = 1});

  Future<TmdbMoviePageDto> discoverMovies({int page = 1, int? genreId});

  Future<TmdbMoviePageDto> searchMovies(String query, {int page = 1});

  Future<List<TmdbGenreDto>> fetchGenres();

  Future<TmdbMovieDto> fetchMovieById(int movieId);
}

final class TmdbMovieService implements MovieService {
  TmdbMovieService(this._dio);

  final Dio _dio;

  @override
  Future<TmdbMoviePageDto> fetchPopular({int page = 1}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/movie/popular',
      queryParameters: {'language': 'ko-KR', 'page': page},
    );
    return TmdbMoviePageDto.fromJson(response.data ?? const {});
  }

  @override
  Future<TmdbMoviePageDto> discoverMovies({int page = 1, int? genreId}) async {
    final query = <String, dynamic>{
      'language': 'ko-KR',
      'page': page,
      'include_adult': false,
      'sort_by': 'popularity.desc',
    };
    if (genreId != null) {
      query['with_genres'] = genreId;
    }

    final response = await _dio.get<Map<String, dynamic>>(
      '/discover/movie',
      queryParameters: query,
    );
    return TmdbMoviePageDto.fromJson(response.data ?? const {});
  }

  @override
  Future<TmdbMoviePageDto> searchMovies(String query, {int page = 1}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const TmdbMoviePageDto(page: 1, totalPages: 0, results: []);
    }
    final response = await _dio.get<Map<String, dynamic>>(
      '/search/movie',
      queryParameters: {
        'query': trimmed,
        'language': 'ko-KR',
        'page': page,
        'include_adult': false,
      },
    );
    return TmdbMoviePageDto.fromJson(response.data ?? const {});
  }

  @override
  Future<List<TmdbGenreDto>> fetchGenres() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/genre/movie/list',
      queryParameters: {'language': 'ko-KR'},
    );
    final rawGenres = response.data?['genres'];
    if (rawGenres is! List) return const [];

    return rawGenres
        .whereType<Map>()
        .map((item) => TmdbGenreDto.fromJson(item.cast<String, dynamic>()))
        .where((genre) => genre.id > 0 && genre.name.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<TmdbMovieDto> fetchMovieById(int movieId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/movie/$movieId',
      queryParameters: {'language': 'ko-KR'},
    );
    return TmdbMovieDto.fromJson(response.data ?? const {});
  }
}
