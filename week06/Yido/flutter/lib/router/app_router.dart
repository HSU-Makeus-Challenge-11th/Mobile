import 'package:go_router/go_router.dart';
import 'package:movielog/data/services/member_check_service.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/screens/home_screen.dart';
import 'package:movielog/screens/main_screen.dart';
import 'package:movielog/screens/movie_detail_screen.dart';
import 'package:movielog/screens/movie_list_screen.dart';
import 'package:movielog/screens/profile_screen.dart';
import 'package:movielog/screens/sign_up_screen.dart';
import 'package:movielog/screens/start_screen.dart';
import 'package:movielog/view_models/movie_home_view_model.dart';
import 'package:movielog/view_models/movie_list_view_model.dart';
import 'package:movielog/view_models/sign_up_view_model.dart';
import 'package:provider/provider.dart';

abstract final class AppRouter {
  static final router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/start', builder: (context, state) => const StartScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => ChangeNotifierProvider<SignUpViewModel>(
          create: (context) =>
              SignUpViewModel(context.read<MemberCheckService>()),
          child: const SignUpScreen(),
        ),
      ),
      ShellRoute(
        builder: (_, state, child) =>
            MainScreen(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/home',
            // 화면마다 ViewModel을 따로 만들고, 생성 직후 첫 요청을 한 번만 보낸다
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: ChangeNotifierProvider<MovieHomeViewModel>(
                create: (context) =>
                    MovieHomeViewModel(context.read<TmdbMovieService>())
                      ..loadPopular(),
                child: const HomeScreen(),
              ),
            ),
          ),
          GoRoute(
            path: '/movies',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: ChangeNotifierProvider<MovieListViewModel>(
                create: (context) =>
                    MovieListViewModel(context.read<TmdbMovieService>())
                      ..loadInitial(),
                child: const MovieListScreen(),
              ),
            ),
          ),
          GoRoute(
            path: '/my',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const ProfileScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/movies/:movieId',
        builder: (_, state) => MovieDetailScreen(
          movieId: int.tryParse(state.pathParameters['movieId']!) ?? -1,
          args: state.extra as MovieDetailArgs?,
        ),
      ),
    ],
  );
}
