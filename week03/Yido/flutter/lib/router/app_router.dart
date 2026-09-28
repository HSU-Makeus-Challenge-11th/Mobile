import 'package:go_router/go_router.dart';
import 'package:movielog/home_screen.dart';
import 'package:movielog/main_screen.dart';
import 'package:movielog/movie_detail_screen.dart';
import 'package:movielog/movie_list_screen.dart';
import 'package:movielog/profile_screen.dart';
import 'package:movielog/sign_up_screen.dart';
import 'package:movielog/start_screen.dart';

abstract final class AppRouter {
  static final router = GoRouter(
    initialLocation: '/start',
    routes: [
      GoRoute(path: '/start', builder: (context, state) => const StartScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const SignUpScreen(),
      ),
      ShellRoute(
        builder: (_, state, child) =>
            MainScreen(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) =>
                NoTransitionPage(key: state.pageKey, child: const HomeScreen()),
          ),
          GoRoute(
            path: '/movies',
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: const MovieListScreen(),
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
        builder: (_, state) =>
            MovieDetailScreen(movieId: state.pathParameters['movieId']!),
      ),
    ],
  );
}
