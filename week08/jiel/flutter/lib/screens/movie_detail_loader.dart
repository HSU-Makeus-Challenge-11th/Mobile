import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';
import '../theme/app_colors.dart';
import '../view_models/movie_detail_view_model.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/loading_view.dart';
import 'movie_detail_screen.dart';

/// 영화 상세 화면의 시작점.
///
/// 목록에서 push될 때는 [initialMovie](GoRouter extra)를 그대로 쓰고,
/// 직접 접근·Deep Link처럼 extra가 없으면 TMDB GET /movie/{movie_id}로 다시 조회한다.
/// 영화 DTO가 준비되면 MovieDetailViewModel을 만들어 MovieDetailScreen에 제공한다.
class MovieDetailLoader extends StatefulWidget {
  const MovieDetailLoader({super.key, required this.movieId, this.initialMovie});

  final int movieId;
  final TmdbMovieDto? initialMovie;

  @override
  State<MovieDetailLoader> createState() => _MovieDetailLoaderState();
}

class _MovieDetailLoaderState extends State<MovieDetailLoader> {
  late final Future<TmdbMovieDto> _movieFuture;

  @override
  void initState() {
    super.initState();
    // build마다 새 Future를 만들지 않도록 initState에서 한 번만 만든다.
    final initial = widget.initialMovie;
    _movieFuture = initial != null
        ? Future.value(initial)
        : context.read<TmdbMovieService>().fetchMovieDetail(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TmdbMovieDto>(
      future: _movieFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppColors.surfaceBase,
            body: LoadingView(),
          );
        }
        final movie = snapshot.data;
        if (snapshot.hasError || movie == null) {
          return const Scaffold(
            backgroundColor: AppColors.surfaceBase,
            body: Center(child: Text('영화를 불러오지 못했습니다.')),
          );
        }
        return ChangeNotifierProvider<MovieDetailViewModel>(
          create: (context) => MovieDetailViewModel(
            // 8주차: memberId 대신 토큰 기반 평점 저장소(MyRatingsViewModel)를 사용한다.
            context.read<MyRatingsViewModel>(),
            movie,
          ),
          child: const MovieDetailScreen(),
        );
      },
    );
  }
}
