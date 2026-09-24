import 'package:go_router/go_router.dart';
import 'package:movielog/screens/home_screen.dart';
import 'package:movielog/screens/main_screen.dart';
import 'package:movielog/screens/movie_detail_screen.dart';
import 'package:movielog/screens/movie_list_screen.dart';
import 'package:movielog/screens/profile_screen.dart';
import 'package:movielog/screens/sign_up_screen.dart';
import 'package:movielog/screens/start_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(path: '/start', builder: (context, state) => const StartScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/movies',
            builder: (context, state) => const MovieListScreen(),
          ),
          GoRoute(
            path: '/my',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/movies/:movieId',
        builder: (context, state) {
          final movieId = state.pathParameters['movieId']!;
          return MovieDetailScreen(movieId: movieId);
        },
      ),
    ],
  );
}
