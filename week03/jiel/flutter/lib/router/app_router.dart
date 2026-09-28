import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/screens/sign_up_screen.dart';
import 'package:movielog/screens/start_screen.dart';
import 'package:movielog/screens/main_screen.dart';
import 'package:movielog/screens/home_screen.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/start',
    routes: [
      GoRoute(
        path: '/start',
        builder: (context, state) => const StartScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const SignUpScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainScreen(
            currentIndex: indexFromLocation(state.uri.path),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/movies',
            builder: (context, state) => const Center(child:Text('영화목록')),//MovieListScreen(),
          ),
          GoRoute(
            path: '/my',
            builder: (context, state) => const Center(child:Text('마이페이지')),//MyPageScreen(),
          ),
        ],
      ),
    ],
  );

  static int indexFromLocation(String path) {
    if (path.startsWith('/movies')) return 1;
    if (path.startsWith('/my')) return 2;

    return 0;
  }
}