import 'package:flutter/material.dart';
import 'package:movielog/data/services/favorite_api_service.dart';
import 'package:movielog/screens/favorites_screen.dart';
import 'package:movielog/screens/movie_search_screen.dart';
import 'package:movielog/view_models/favorites_view_model.dart';
import 'package:movielog/view_models/favorite_detail_view_model.dart';
import 'package:movielog/widgets/member_ready_gate.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/data/services/sign_up_service.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/screens/home_screen.dart';
import 'package:movielog/screens/main_screen.dart';
import 'package:movielog/screens/movie_detail_loader.dart';
import 'package:movielog/screens/movie_detail_screen.dart';
import 'package:movielog/screens/movie_list_screen.dart';
import 'package:movielog/screens/my_ratings_screen.dart';
import 'package:movielog/screens/profile_screen.dart';
import 'package:movielog/screens/sign_up_screen.dart';
import 'package:movielog/screens/splash_screen.dart';
import 'package:movielog/screens/login_screen.dart';
import 'package:movielog/screens/edit_profile_screen.dart';
import 'package:movielog/data/services/member_api_service.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/view_models/edit_profile_view_model.dart';
import 'package:movielog/widgets/movielog_button.dart';
import 'package:movielog/view_models/movie_home_view_model.dart';
import 'package:movielog/view_models/paged_movies_view_model.dart';
import 'package:movielog/view_models/my_ratings_view_model.dart';
import 'package:movielog/view_models/session_rating_store.dart';
import 'package:movielog/view_models/sign_up_view_model.dart';
import 'package:provider/provider.dart';

/// 인증 상태만 보고 갈 곳을 정한다. 비동기 작업은 하지 않는다
String? authRedirect(AuthStatus status, String location) {
  const publicPaths = {'/login', '/register'};
  final atStart = location == '/start';
  final atPublic = publicPaths.contains(location);
  return switch (status) {
    // 토큰 확인 중이거나 확인 실패: 스플래시를 유지한다
    AuthStatus.initializing ||
    AuthStatus.retryRequired => atStart ? null : '/start',
    // 로그아웃·로그인 요청 중: 공개 화면만 허용한다
    AuthStatus.signedOut ||
    AuthStatus.authenticating => atPublic ? null : '/login',
    // 로그인됨: 스플래시·로그인·회원가입은 홈으로 보낸다
    AuthStatus.signedIn => (atStart || atPublic) ? '/home' : null,
  };
}

abstract final class AppRouter {
  // 자식 화면이 하단 NavigationBar를 가리도록 root Navigator 키를 한 번만 선언한다
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter? _current;

  /// 마지막으로 만든 Router. 테스트에서 경로를 바꿀 때 쓴다
  static GoRouter get router => _current!;

  /// 앱이 살아 있는 동안 한 번만 만든다. 인증 상태가 바뀌면 redirect를 다시 실행한다
  static GoRouter createRouter(AuthViewModel authViewModel) {
    return _current = GoRouter(
      initialLocation: '/start',
      navigatorKey: rootNavigatorKey,
      refreshListenable: authViewModel,
      redirect: (context, state) =>
          authRedirect(authViewModel.status, state.uri.path),
      routes: [
        GoRoute(
          path: '/start',
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
          builder: (context, state) => ChangeNotifierProvider<SignUpViewModel>(
            create: (context) => SignUpViewModel(context.read<SignUpService>()),
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
                // 5주차의 30개 수집 대신 첫 page만 불러오고 더 보기로 이어 붙인다
                child: ChangeNotifierProvider<PagedMoviesViewModel>(
                  create: (context) =>
                      PagedMoviesViewModel(
                          tmdbApi: context.read<TmdbMovieService>(),
                        )
                        ..loadGenres()
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
              routes: [
                GoRoute(
                  path: 'profile/edit', // 최종 경로: /my/profile/edit
                  parentNavigatorKey: rootNavigatorKey,
                  builder: (context, state) {
                    final auth = context.watch<AuthViewModel>();
                    if (auth.member == null) {
                      return Scaffold(
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
                GoRoute(
                  path: 'favorites', // 최종 경로: /my/favorites
                  parentNavigatorKey: rootNavigatorKey,
                  // 즐겨찾기 API에는 memberId를 보내지 않는다. email은 화면 쪽 세션 구분에만 쓴다
                  builder: (_, state) => MemberReadyGate(
                    builder: (context, member, guard, sessionKey) =>
                        ChangeNotifierProvider<FavoritesViewModel>(
                          key: sessionKey,
                          create: (context) => FavoritesViewModel(
                            favoriteApi: context.read<FavoriteApiService>(),
                            tmdbApi: context.read<TmdbMovieService>(),
                            sessionGuard: guard,
                            accountId: member.email,
                            onSessionExpired: context
                                .read<AuthViewModel>()
                                .expireSession,
                          ),
                          child: FavoritesScreen(
                            onOpenMovie: (movie) => context.push(
                              '/movies/${movie.id}',
                              extra: MovieDetailArgs(movie: movie),
                            ),
                          ),
                        ),
                  ),
                ),
                GoRoute(
                  path: 'ratings', // 최종 경로: /my/ratings
                  parentNavigatorKey: rootNavigatorKey,
                  // 토큰 기반 내 평점 목록 GET이 없어 이번 세션에 등록한 평점을 보여 준다
                  builder: (context, state) =>
                      ChangeNotifierProvider<MyRatingsViewModel>(
                        create: (context) => MyRatingsViewModel(
                          context.read<RatingApiService>(),
                          context.read<TmdbMovieService>(),
                          context.read<SessionRatingStore>(),
                          context.read<AuthViewModel>(),
                        )..load(),
                        child: const MyRatingsScreen(),
                      ),
                ),
              ],
            ),
          ],
        ),
        // 정적인 search를 동적인 :movieId보다 먼저 등록해야 영화 ID로 해석되지 않는다
        GoRoute(
          path: '/movies/search',
          builder: (context, state) =>
              ChangeNotifierProvider<PagedMoviesViewModel>(
                // 영화 목록과 따로 만든 인스턴스라 검색이 목록 상태를 바꾸지 않는다
                create: (context) => PagedMoviesViewModel(
                  tmdbApi: context.read<TmdbMovieService>(),
                ),
                child: MovieSearchScreen(
                  onOpenMovie: (movie) => context.push(
                    '/movies/${movie.id}',
                    extra: MovieDetailArgs(movie: movie),
                  ),
                ),
              ),
        ),
        GoRoute(
          path: '/movies/:movieId',
          // 계정·세션이 바뀌면 key가 달라져 즐겨찾기 ViewModel을 새로 만든다
          builder: (_, state) => MemberReadyGate(
            builder: (context, member, guard, sessionKey) {
              final movieId =
                  int.tryParse(state.pathParameters['movieId']!) ?? -1;
              return ChangeNotifierProvider<FavoriteDetailViewModel>(
                key: sessionKey,
                create: (context) => FavoriteDetailViewModel(
                  movieId: movieId,
                  favoriteApi: context.read<FavoriteApiService>(),
                  sessionGuard: guard,
                  accountId: member.email,
                  onSessionExpired: context.read<AuthViewModel>().expireSession,
                ),
                child: MovieDetailLoader(
                  movieId: movieId,
                  args: state.extra as MovieDetailArgs?,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
