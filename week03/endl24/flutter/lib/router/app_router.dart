import 'package:go_router/go_router.dart';
import 'package:movielog/screens/home_screen.dart';       // 아직 없으면 임시로 만들거나 SignUpScreen으로 대체
import 'package:movielog/screens/movie_list_screen.dart';
import 'package:movielog/screens/movie_detail_screen.dart';
import 'package:movielog/screens/profile_screen.dart';    // 마이페이지로 재사용 가능

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/home',
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
        path: '/movies/:movieId',
        builder: (context, state) {
          final movieId = state.pathParameters['movieId']!;
          return MovieDetailScreen(movieId: movieId);
        },
      ),
      GoRoute(
        path: '/my',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}