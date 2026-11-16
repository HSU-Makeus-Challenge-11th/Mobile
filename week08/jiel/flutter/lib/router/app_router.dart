import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/data/services/member_api_service.dart';
import 'package:movielog/data/services/sign_up_service.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/screens/button_width_demo_screen.dart';
import 'package:movielog/screens/edit_profile_screen.dart';
import 'package:movielog/screens/login_screen.dart';
import 'package:movielog/screens/movie_detail_loader.dart';
import 'package:movielog/screens/my_ratings_screen.dart';
import 'package:movielog/screens/sign_up_screen.dart';
import 'package:movielog/screens/start_screen.dart';
import 'package:movielog/screens/main_screen.dart';
import 'package:movielog/screens/home_screen.dart';
import 'package:movielog/screens/movie_list_screen.dart';
import 'package:movielog/screens/profile_screen.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/view_models/edit_profile_view_model.dart';
import 'package:movielog/view_models/movie_home_view_model.dart';
import 'package:movielog/view_models/movie_list_view_model.dart';
import 'package:movielog/view_models/sign_up_view_model.dart';
import 'package:movielog/widgets/movielog_button.dart';

/// 인증 상태별 화면 이동 규칙. redirect 안에서는 상태만 읽고 비동기 작업을 하지 않는다.
String? authRedirect(AuthStatus status, String location) {
  const publicPaths = {'/login', '/register'};
  final atStart = location == '/start';
  final atPublic = publicPaths.contains(location);

  return switch (status) {
    // 토큰 확인 중 또는 확인 실패(재시도 버튼): 스플래시 화면 유지
    AuthStatus.initializing || AuthStatus.retryRequired => atStart ? null : '/start',
    // 로그아웃 또는 로그인 요청 중: 공개 화면만 허용
    AuthStatus.signedOut || AuthStatus.authenticating => atPublic ? null : '/login',
    // 로그인됨: 스플래시와 로그인·회원가입 화면은 홈으로 보냄
    AuthStatus.signedIn => (atStart || atPublic) ? '/home' : null,
  };
}

class AppRouter {
  AppRouter._();

  // root Navigator를 가리키는 키. 하단 탭 없이 띄울 자식 화면이 이 Navigator 위에 push된다.
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  /// 앱 생명주기 동안 한 번만 만든다(_MovieLogRouterApp.initState).
  static GoRouter createRouter(AuthViewModel authViewModel) => GoRouter(
    initialLocation: '/start',
    navigatorKey: rootNavigatorKey,
    refreshListenable: authViewModel, // 인증 상태가 바뀌면 redirect를 다시 실행한다.
    redirect: (context, state) =>
        authRedirect(authViewModel.status, state.uri.path),
    routes: [
      GoRoute(
        path: '/start', // 스플래시: 토큰 확인 중 / 확인 실패 시 재시도
        builder: (context, state) {
          final auth = context.watch<AuthViewModel>();
          return SplashScreen(
            message: auth.message,
            onRetry: auth.status == AuthStatus.retryRequired
                ? auth.restoreSession
                : null,
          );
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
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
                // 8주차: memberId 대신 앱 최상단 MyRatingsViewModel(토큰 기반, 현재 세션 평점)을 사용한다.
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const MyRatingsScreen(),
              ),
              GoRoute(
                path: 'profile/edit', // 최종 경로: /my/profile/edit
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) {
                  final auth = context.watch<AuthViewModel>();
                  if (auth.member == null) {
                    return Scaffold(
                      backgroundColor: AppColors.surfaceBase,
                      appBar: AppBar(
                        centerTitle: true,
                        title: const Text('프로필 수정'),
                      ),
                      body: Center(
                        child: auth.memberStatus == MemberLoadStatus.error
                            ? MovieLogButton(
                                label: '다시 시도',
                                onPressed: () => auth.loadMember(force: true),
                              )
                            : const CircularProgressIndicator(),
                      ),
                    );
                  }
                  return ChangeNotifierProvider<EditProfileViewModel>(
                    create: (context) => EditProfileViewModel(
                      context.read<MemberApiService>(),
                      auth,
                    ),
                    child: const EditProfileScreen(),
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
