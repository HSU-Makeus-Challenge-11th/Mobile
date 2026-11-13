import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/data/services/sign_up_service.dart';
import 'package:movielog/data/services/member_api_service.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/screens/edit_profile_screen.dart';
import 'package:movielog/screens/home_screen.dart';
import 'package:movielog/screens/login_screen.dart';
import 'package:movielog/screens/main_screen.dart';
import 'package:movielog/screens/movie_detail_screen.dart';
import 'package:movielog/screens/movie_list_screen.dart';
import 'package:movielog/screens/my_ratings_screen.dart';
import 'package:movielog/screens/profile_screen.dart';
import 'package:movielog/screens/sign_up_screen.dart';
import 'package:movielog/screens/start_screen.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/view_models/edit_profile_view_model.dart';
import 'package:movielog/view_models/movie_detail_view_model.dart';
import 'package:movielog/view_models/movie_home_view_model.dart';
import 'package:movielog/view_models/movie_list_view_model.dart';
import 'package:movielog/view_models/my_ratings_view_model.dart';
import 'package:movielog/view_models/session_ratings.dart';
import 'package:movielog/view_models/sign_up_view_model.dart';
import 'package:movielog/widgets/common_app_bar.dart';
import 'package:movielog/widgets/movielog_button.dart';
import 'package:provider/provider.dart';

/// 인증 상태와 이동하려는 경로를 보고, 다른 경로로 보내야 하면 그 경로를 돌려줍니다.
/// 상태만 읽고 판단합니다. API 호출 같은 비동기 작업은 하지 않습니다.
String? authRedirect(AuthStatus status, String location) {
  const publicPaths = {'/login', '/signup'};
  final atStart = location == '/start';
  final atPublic = publicPaths.contains(location);

  return switch (status) {
    // 토큰 확인 중 또는 확인 실패(재시도 버튼): 스플래시 유지
    AuthStatus.initializing || AuthStatus.retryRequired =>
      atStart ? null : '/start',
    // 로그아웃 또는 로그인 요청 중: 로그인·회원가입만 허용
    AuthStatus.signedOut || AuthStatus.authenticating =>
      atPublic ? null : '/login',
    // 로그인됨: 스플래시·로그인·회원가입은 홈으로
    AuthStatus.signedIn => (atStart || atPublic) ? '/home' : null,
  };
}

/// AuthViewModel의 알림 중 로그인 상태(status)가 바뀐 경우만 Router에 전달합니다.
/// 내 정보 수정처럼 status는 그대로인 알림까지 Router가 다시 계산하면,
/// 바로 뒤에 실행한 화면 이동(pop)이 이전 위치로 되돌려질 수 있습니다.
class AuthStatusListenable extends ChangeNotifier {
  AuthStatusListenable(this._auth) : _status = _auth.status {
    _auth.addListener(_onAuthChanged);
  }

  final AuthViewModel _auth;
  AuthStatus _status;

  void _onAuthChanged() {
    if (_auth.status == _status) return;
    _status = _auth.status;
    notifyListeners();
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }
}

class AppRouter {
  AppRouter._();
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthViewModel authViewModel) => GoRouter(
    initialLocation: '/start',
    navigatorKey: rootNavigatorKey,
    // 로그인 상태(status)가 바뀔 때만 redirect를 다시 실행합니다.
    refreshListenable: AuthStatusListenable(authViewModel),
    redirect: (context, state) =>
        authRedirect(authViewModel.status, state.uri.path),
    routes: [
      GoRoute(
        path: '/start', // 스플래시: 토큰 확인 중 / 확인 실패 시 재시도
        builder: (context, state) {
          final auth = context.watch<AuthViewModel>();
          return StartScreen(
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
        path: '/signup',
        builder: (context, state) => ChangeNotifierProvider<SignUpViewModel>(
          create: (context) =>
              SignUpViewModel(context.read<SignUpService>()),
          child: const SignUpScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => ChangeNotifierProvider(
              create: (context) =>
                  MovieHomeViewModel(context.read<TmdbMovieService>())
                    ..loadPopular(),
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/movies',
            builder: (context, state) => ChangeNotifierProvider(
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
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) =>
                    ChangeNotifierProvider<MyRatingsViewModel>(
                      create: (context) => MyRatingsViewModel(
                        context.read<RatingApiService>(),
                        context.read<SessionRatings>(),
                        context.read<AuthViewModel>(),
                      ),
                      child: const MyRatingsScreen(),
                    ),
              ),
              GoRoute(
                path: 'profile/edit', // 최종 경로: /my/profile/edit
                parentNavigatorKey: rootNavigatorKey, // 하단 탭 없이 전체 화면
                builder: (context, state) {
                  final auth = context.watch<AuthViewModel>();
                  if (auth.member == null) {
                    // 내 정보를 아직 못 불러왔으면 로딩 또는 재시도를 보여줍니다.
                    return Scaffold(
                      appBar: CommonAppBar(
                        title: '프로필 수정',
                        centerTitle: true,
                        onBack: () => context.pop(),
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
      GoRoute(
        path: '/movies/:movieId',
        builder: (context, state) {
          final extra = state.extra;
          if (extra is! TmdbMovieDto) {
            return const MovieDetailScreen(movie: null); // 영화를 찾을 수 없음 화면
          }
          return ChangeNotifierProvider<MovieDetailViewModel>(
            create: (context) => MovieDetailViewModel(
              context.read<RatingApiService>(),
              context.read<AuthViewModel>(),
              context.read<SessionRatings>(),
              extra,
            ),
            child: MovieDetailScreen(movie: extra),
          );
        },
      ),
    ],
  );
}
