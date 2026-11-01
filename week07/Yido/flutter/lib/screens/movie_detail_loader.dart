import 'package:flutter/material.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/screens/movie_detail_screen.dart';
import 'package:movielog/view_models/learning_member_session.dart';
import 'package:movielog/view_models/movie_detail_view_model.dart';
import 'package:provider/provider.dart';

/// 목록에서 넘긴 영화가 없으면(직접 접근·Deep Link) TMDB에서 다시 조회한다
class MovieDetailLoader extends StatefulWidget {
  const MovieDetailLoader({super.key, required this.movieId, this.args});

  final int movieId;
  final MovieDetailArgs? args;

  @override
  State<MovieDetailLoader> createState() => _MovieDetailLoaderState();
}

class _MovieDetailLoaderState extends State<MovieDetailLoader> {
  late final Future<MovieDetailArgs> _argsFuture;

  @override
  void initState() {
    super.initState();
    final args = widget.args;
    _argsFuture = args != null && args.movie.id == widget.movieId
        ? Future.value(args)
        : context
              .read<TmdbMovieService>()
              .fetchMovieDetail(widget.movieId)
              .then((movie) => MovieDetailArgs(movie: movie));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movieId < 1) {
      return const Scaffold(body: Center(child: Text('영화 ID가 올바르지 않습니다.')));
    }
    return FutureBuilder<MovieDetailArgs>(
      future: _argsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final args = snapshot.data;
        if (snapshot.hasError || args == null) {
          return const Scaffold(body: Center(child: Text('영화를 불러오지 못했습니다.')));
        }
        return ChangeNotifierProvider<MovieDetailViewModel>(
          create: (context) => MovieDetailViewModel(
            context.read<RatingApiService>(),
            context.read<LearningMemberSession>().memberId,
            args.movie.id,
          ),
          child: MovieDetailScreen(args: args),
        );
      },
    );
  }
}
