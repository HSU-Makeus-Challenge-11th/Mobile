import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/core/network/movie_log_client.dart';
import 'package:movielog/core/network/tmdb_client.dart';
import 'package:movielog/core/session/auth_session_bridge.dart';
import 'package:movielog/core/session/session_guard.dart';
import 'package:movielog/core/storage/token_storage.dart';
import 'package:movielog/data/services/auth_api_service.dart';
import 'package:movielog/data/services/favorite_api_service.dart';
import 'package:movielog/data/services/member_api_service.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/data/services/sign_up_service.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/router/app_router.dart';
import 'package:movielog/theme/app_theme.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/view_models/session_rating_store.dart';
import 'package:provider/provider.dart';

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({
    super.key,
    this.movieService,
    this.signUpService,
    this.ratingApiService,
    this.authApiService,
    this.memberApiService,
    this.tokenStorage,
    this.favoriteApiService,
  });

  /// 테스트에서 가짜 Service를 넣을 때만 사용한다
  final TmdbMovieService? movieService;
  final SignUpService? signUpService;
  final RatingApiService? ratingApiService;
  final AuthApiService? authApiService;
  final MemberApiService? memberApiService;
  final TokenStorage? tokenStorage;
  final FavoriteApiService? favoriteApiService;

  @override
  Widget build(BuildContext context) {
    final storage =
        tokenStorage ?? SecureTokenStorage(const FlutterSecureStorage());
    // 공개 Client에는 Interceptor가 없고, 보호 Client에만 토큰을 붙인다
    final publicClient = createMovieLogClient();
    final authClient = createAuthMovieLogClient(storage);

    // 여러 Route가 함께 쓰는 Service는 MaterialApp.router 바깥 최상단에 둔다
    return MultiProvider(
      providers: [
        Provider<TokenStorage>.value(value: storage),
        // TMDB Client와 워크북 Client는 baseUrl과 토큰이 달라 합치지 않는다
        Provider<TmdbMovieService>(
          create: (_) => movieService ?? TmdbMovieService(createTmdbClient()),
        ),
        Provider<AuthApiService>(
          create: (_) => authApiService ?? AuthApiService(publicClient),
        ),
        Provider<SignUpService>(
          create: (_) => signUpService ?? SignUpService(publicClient),
        ),
        Provider<MemberApiService>(
          create: (_) => memberApiService ?? MemberApiService(authClient),
        ),
        Provider<RatingApiService>(
          create: (_) =>
              ratingApiService ?? RatingApiService(publicClient, authClient),
        ),
        // 즐겨찾기는 모두 보호 요청이라 authClient만 쓴다
        Provider<FavoriteApiService>(
          create: (_) => favoriteApiService ?? FavoriteApiService(authClient),
        ),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(
            context.read<AuthApiService>(),
            context.read<MemberApiService>(),
            context.read<TokenStorage>(),
          ),
        ),
        // 응답이 현재 계정·세션의 것인지 판정한다. email은 GET me로 확인된 값만 쓴다
        Provider<AuthSessionBridge>(
          lazy: false, // 앱 시작부터 로그인 상태 변화를 따라간다
          create: (context) {
            final auth = context.read<AuthViewModel>();
            return AuthSessionBridge(
              authSignals: auth,
              sessionVersion: () => auth.sessionVersion,
              verifiedEmail: () => auth.status == AuthStatus.signedIn
                  ? auth.member?.email
                  : null,
            );
          },
          dispose: (_, bridge) => bridge.dispose(),
        ),
        Provider<SessionGuard>(
          create: (context) => context.read<AuthSessionBridge>().guard,
        ),
        ChangeNotifierProvider<SessionRatingStore>(
          create: (context) =>
              SessionRatingStore(context.read<AuthViewModel>()),
        ),
      ],
      child: const _MovieLogRouterApp(),
    );
  }
}

/// build마다 Router를 새로 만들면 위치가 초기화되므로 initState에서 한 번만 만든다
class _MovieLogRouterApp extends StatefulWidget {
  const _MovieLogRouterApp();

  @override
  State<_MovieLogRouterApp> createState() => _MovieLogRouterAppState();
}

class _MovieLogRouterAppState extends State<_MovieLogRouterApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authViewModel = context.read<AuthViewModel>();
    _router = AppRouter.createRouter(authViewModel);
    // 첫 build 뒤에 저장된 토큰을 확인한다
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) authViewModel.restoreSession();
    });
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    title: 'MovieLog',
    theme: AppTheme.light,
    routerConfig: _router,
  );
}
