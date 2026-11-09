import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/data/services/sign_up_service.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/screens/button_width_demo_screen.dart';
import 'package:movielog/screens/movie_detail_loader.dart';
import 'package:movielog/screens/my_ratings_screen.dart';
import 'package:movielog/screens/sign_up_screen.dart';
import 'package:movielog/screens/start_screen.dart';
import 'package:movielog/screens/main_screen.dart';
import 'package:movielog/screens/home_screen.dart';
import 'package:movielog/screens/movie_list_screen.dart';
import 'package:movielog/screens/profile_screen.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/view_models/learning_member_session.dart';
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
          create: (context) => SignUpViewModel(context.read<SignUpService>()),
          child: const SignUpScreen(),
        ),
      ),
      // MovieLogButton width/상태 비교용 개발 화면 (마이페이지 디버그 항목에서 진입)
      GoRoute(
        path: '/dev/buttons',
        builder: (context, state) => const ButtonWidthDemoScreen(),
      ),
      // 하단 탭 바 없이 전체 화면으로 띄우기 위해 ShellRoute 밖에 둔다.
      // movieId는 URL 식별자로만 쓰고, 실제 화면에 넘길 TmdbMovieDto는 state.extra에서 꺼낸다.
      // extra가 없으면(직접 접근·Deep Link) MovieDetailLoader가 TMDB에서 다시 조회한다.
      GoRoute(
        path: '/movie/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null || id < 1) {
            return const Scaffold(
              backgroundColor: AppColors.surfaceBase,
              body: Center(child: Text('영화 ID가 올바르지 않습니다.')),
            );
          }
          final extra = state.extra;
          return MovieDetailLoader(
            movieId: id,
            // URL의 id와 넘겨받은 영화의 id가 다르면 extra를 버리고 다시 조회한다.
            initialMovie: extra is TmdbMovieDto && extra.id == id ? extra : null,
          );
        },
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
                builder: (context, state) {
                  // 6주차의 고정 sampleMemberId(1) 대신 회원가입 결과를 보관한 학습용 세션에서 읽는다.
                  final id = context.read<LearningMemberSession>().memberId;
                  if (id == null) {
                    return Scaffold(
                      backgroundColor: AppColors.surfaceBase,
                      appBar: AppBar(
                        backgroundColor: AppColors.surfaceBase,
                        centerTitle: true,
                        title: const Text('내가 등록한 평점'),
                      ),
                      body: const Center(child: Text('학습용 회원가입이 필요합니다.')),
                    );
                  }
                  return ChangeNotifierProvider<MyRatingsViewModel>(
                    create: (context) => MyRatingsViewModel(
                      context.read<RatingApiService>(),
                      context.read<TmdbMovieService>(),
                      id,
                    )..load(),
                    child: const MyRatingsScreen(),
                  );
                },
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
