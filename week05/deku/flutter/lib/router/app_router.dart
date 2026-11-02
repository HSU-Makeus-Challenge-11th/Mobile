import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../data/services/tmdb_movie_service.dart';
import '../screens/home/home_screen.dart';
import '../screens/main/main_screen.dart';
import '../screens/movies/movie_detail_screen.dart';
import '../screens/movies/movie_list_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/sign_up/sign_up_screen.dart';
import '../screens/start/start_screen.dart';
import '../services/genre_preference.dart';
import '../view_models/movie_home_view_model.dart';
import '../view_models/movie_list_view_model.dart';

abstract final class AppRouter {
  static final router = GoRouter(
    initialLocation: HomeScreen.routeName,
    routes: [
      GoRoute(
        path: StartScreen.routeName,
        builder: (context, state) => const StartScreen(),
      ),
      GoRoute(
        path: SignUpScreen.routeName,
        builder: (context, state) => const SignUpScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScreen(
          currentIndex: _indexFromLocation(state.uri.path),
          child: child,
        ),
        routes: [
          GoRoute(
            path: HomeScreen.routeName,
            builder: (context, state) => ChangeNotifierProvider(
              create: (_) =>
                  MovieHomeViewModel(context.read<MovieService>())..load(),
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: MovieListScreen.routeName,
            builder: (context, state) => ChangeNotifierProvider(
              create: (_) => MovieListViewModel(
                context.read<MovieService>(),
                context.read<GenrePreferenceStore>(),
              )..load(),
              child: const MovieListScreen(),
            ),
          ),
          GoRoute(
            path: ProfileScreen.routeName,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: MovieDetailScreen.routePattern,
        builder: (context, state) {
          final movieId = int.tryParse(state.pathParameters['movieId'] ?? '');
          final movie = state.extra;
          if (movie is! TmdbMovieDto || movie.id != movieId) {
            return const Scaffold(body: Center(child: Text('영화를 찾을 수 없습니다.')));
          }
          return MovieDetailScreen(movie: movie);
        },
      ),
    ],
  );

  static int _indexFromLocation(String path) {
    if (path.startsWith('/movies')) return 1;
    if (path.startsWith('/my')) return 2;
    return 0;
  }
}
