import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../data/services/member_check_service.dart';
import '../data/services/favorite_api_service.dart';
import '../data/services/rating_api_service.dart';
import '../data/services/tmdb_movie_service.dart';
import '../screens/home/home_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/main/main_screen.dart';
import '../screens/movies/movie_detail_loader.dart';
import '../screens/movies/movie_detail_screen.dart';
import '../screens/movies/movie_list_screen.dart';
import '../screens/movies/movie_search_screen.dart';
import '../screens/my_favorites/favorites_screen.dart';
import '../screens/my_ratings/my_ratings_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/sign_up/sign_up_screen.dart';
import '../screens/start/start_screen.dart';
import '../services/genre_preference.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/favorite_detail_view_model.dart';
import '../view_models/favorites_view_model.dart';
import '../view_models/movie_home_view_model.dart';
import '../view_models/movie_list_view_model.dart';
import '../view_models/paged_movies_view_model.dart';
import '../view_models/my_ratings_view_model.dart';
import '../view_models/session_ratings_store.dart';

String? authRedirect(AuthStatus status, String location) {
  const publicPaths = {'/login', '/register'};
  final atStart = location == '/start';
  final atPublic = publicPaths.contains(location);
  return switch (status) {
    AuthStatus.initializing ||
    AuthStatus.retryRequired => atStart ? null : '/start',
    AuthStatus.signedOut ||
    AuthStatus.authenticating => atPublic ? null : '/login',
    AuthStatus.signedIn => (atStart || atPublic) ? '/home' : null,
  };
}

abstract final class AppRouter {
  static GoRouter createRouter(AuthViewModel auth) => GoRouter(
    initialLocation: StartScreen.routeName,
    refreshListenable: auth,
    redirect: (context, state) => authRedirect(auth.status, state.uri.path),
    routes: [
      GoRoute(
        path: StartScreen.routeName,
        builder: (context, state) => const StartScreen(),
      ),
      GoRoute(
        path: LoginScreen.routeName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: SignUpScreen.routeName,
        builder: (context, state) => SignUpScreen(
          memberCheckService: context.read<MemberCheckService>(),
        ),
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
        path: EditProfileScreen.routeName,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: MyRatingsScreen.routeName,
        builder: (context, state) {
          final viewModel = MyRatingsViewModel(
            context.read<RatingApiService>(),
            context.read<MovieService>(),
            sessionStore: context.read<SessionRatingsStore>(),
            auth: context.read<AuthViewModel>(),
          )..load();
          return MyRatingsScreen(viewModel: viewModel);
        },
      ),
      GoRoute(
        path: FavoritesScreen.routeName,
        builder: (context, state) => ChangeNotifierProvider(
          key: ValueKey('favorites-${auth.sessionVersion}'),
          create: (context) => FavoritesViewModel(
            context.read<FavoriteApiService>(),
            context.read<MovieService>(),
            auth,
          )..refresh(),
          child: const FavoritesScreen(),
        ),
      ),
      GoRoute(
        path: MovieSearchScreen.routeName,
        builder: (context, state) => ChangeNotifierProvider(
          create: (context) => PagedMoviesViewModel(
            context.read<MovieService>(),
            mode: MoviePageMode.search,
          ),
          child: const MovieSearchScreen(),
        ),
      ),
      GoRoute(
        path: MovieDetailScreen.routePattern,
        builder: (context, state) {
          final movieId = int.tryParse(state.pathParameters['movieId'] ?? '');
          final movie = state.extra;
          if (movieId == null || movieId < 1) {
            return const Scaffold(
              body: Center(child: Text('영화 ID가 올바르지 않습니다.')),
            );
          }
          return ChangeNotifierProvider(
            key: ValueKey('favorite-$movieId-${auth.sessionVersion}'),
            create: (context) => FavoriteDetailViewModel(
              context.read<FavoriteApiService>(),
              auth,
              movieId,
            )..load(),
            child: MovieDetailLoader(
              movieId: movieId,
              initialMovie: movie is TmdbMovieDto && movie.id == movieId
                  ? movie
                  : null,
            ),
          );
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
