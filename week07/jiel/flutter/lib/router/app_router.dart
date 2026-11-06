import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/data/services/member_check_service.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/screens/button_width_demo_screen.dart';
import 'package:movielog/screens/my_ratings_screen.dart';
import 'package:movielog/screens/sign_up_screen.dart';
import 'package:movielog/screens/start_screen.dart';
import 'package:movielog/screens/main_screen.dart';
import 'package:movielog/screens/home_screen.dart';
import 'package:movielog/screens/movie_list_screen.dart';
import 'package:movielog/screens/movie_detail_screen.dart';
import 'package:movielog/screens/profile_screen.dart';
import 'package:movielog/view_models/movie_home_view_model.dart';
import 'package:movielog/view_models/movie_list_view_model.dart';
import 'package:movielog/view_models/my_ratings_view_model.dart';
import 'package:movielog/view_models/sign_up_view_model.dart';

class AppRouter {
  AppRouter._();

  // root Navigator를 가리키는 키. 하단 탭 없이 띄울 자식 화면이 이 Navigator 위에 push된다.
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    initialLocation: '/start',
    navigatorKey: rootNavigatorKey,
    routes: [
      GoRoute(path: '/start', builder: (context, state) => const StartScreen()),
      GoRoute(
        path: '/register',
        // 회원가입 화면 전용 ViewModel. 화면을 벗어나면 함께 dispose된다.
        builder: (context, state) => ChangeNotifierProvider<SignUpViewModel>(
          create: (context) =>
              SignUpViewModel(context.read<MemberCheckService>()),
          child: const SignUpScreen(),
        ),
      ),
      // MovieLogButton width/상태 비교용 개발 화면 (마이페이지 디버그 항목에서 진입)
      GoRoute(
        path: '/dev/buttons',
        builder: (context, state) => const ButtonWidthDemoScreen(),
      ),
      // 하단 탭 바 없이 전체 화면으로 띄우기 위해 ShellRoute 밖에 둔다.
      GoRoute(
        path: '/movie/:id',
        builder: (context, state) => MovieDetailScreen(
          movieId: int.tryParse(state.pathParameters['id'] ?? ''),
          // 목록에서 이미 받은 DTO를 넘겨받아 추가 API 호출 없이 보여준다.
          movie: state.extra as TmdbMovieDto?,
        ),
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
            // 화면마다 ViewModel을 새로 만들고, 화면을 벗어나면 함께 dispose된다.
            builder: (context, state) =>
                ChangeNotifierProvider<MovieHomeViewModel>(
                  create: (context) =>
                      MovieHomeViewModel(context.read<TmdbMovieService>())
                        ..loadPopular(),
                  child: const HomeScreen(),
                ),
          ),
          GoRoute(
            path: '/movies',
            builder: (context, state) =>
                ChangeNotifierProvider<MovieListViewModel>(
                  create: (context) =>
                      MovieListViewModel(context.read<TmdbMovieService>())
                        ..loadInitial(),
                  child: const MovieListScreen(),
                ),
          ),
          GoRoute(
            path: '/my',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'ratings', // 최종 경로: /my/ratings
                // ShellRoute의 Navigator가 아니라 root Navigator 위에 띄워 하단 NavigationBar를 가린다.
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) =>
                    ChangeNotifierProvider<MyRatingsViewModel>(
                      create: (context) => MyRatingsViewModel(
                        context.read<RatingApiService>(),
                        context.read<TmdbMovieService>(),
                        sampleMemberId, // 6주차는 학습용 memberId 1
                      )..load(),
                      child: const MyRatingsScreen(),
                    ),
              ),
            ],
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
