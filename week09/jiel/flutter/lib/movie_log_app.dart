import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:movielog/core/network/movie_log_client.dart'; // createMovieLogClient(), createAuthMovieLogClient()
import 'package:movielog/core/network/tmdb_client.dart'; // createTmdbClient()
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
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/view_models/my_ratings_view_model.dart';
import 'theme/app_theme.dart';

class MovieLogApp extends StatefulWidget {
  const MovieLogApp({super.key});

  @override
  State<MovieLogApp> createState() => _MovieLogAppState();
}

class _MovieLogAppState extends State<MovieLogApp> {
  // Client·저장소는 앱이 살아 있는 동안 한 번만 만든다.
  // - TMDB Client: TMDB Read Access Token만 보낸다(AuthInterceptor 없음).
  // - 공개 워크북 Client: 로그인·회원가입·중복 체크·공개 평점 조회(토큰 없음).
  // - 보호 워크북 Client: 내 정보·평점 등록/수정/삭제·즐겨찾기(AuthInterceptor가 MovieLog JWT 부착).
  final TokenStorage _tokenStorage = SecureTokenStorage(
    const FlutterSecureStorage(),
  );
  late final _publicClient = createMovieLogClient();
  late final _authClient = createAuthMovieLogClient(_tokenStorage);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TokenStorage>.value(value: _tokenStorage),
        Provider<TmdbMovieService>(
          create: (_) => TmdbMovieService(createTmdbClient()),
        ),
        // 공개 Client
        Provider<AuthApiService>(create: (_) => AuthApiService(_publicClient)),
        Provider<SignUpService>(create: (_) => SignUpService(_publicClient)),
        // 보호 Client (RatingApiService는 공개 조회용 publicClient도 함께 받는다)
        Provider<MemberApiService>(create: (_) => MemberApiService(_authClient)),
        Provider<RatingApiService>(
          create: (_) => RatingApiService(_publicClient, _authClient),
        ),
        // 9주차: 즐겨찾기 API. 새 Client를 만들지 않고 8주차의 보호용 Client를 그대로 쓴다.
        Provider<FavoriteApiService>(
          create: (_) => FavoriteApiService(_authClient),
        ),
        // Service를 주입받는 ViewModel
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(
            context.read<AuthApiService>(),
            context.read<MemberApiService>(),
            context.read<TokenStorage>(),
          ),
        ),
        // 9주차: AuthViewModel의 세션 변화를 SessionGuard에 전달한다.
        // 앱 시작부터 Auth 알림을 놓치지 않도록 lazy를 끈다.
        Provider<AuthSessionBridge>(
          lazy: false,
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
        // 사용자별 화면이 "지금 응답이 현재 세션의 것인지" 확인할 때 쓴다.
        Provider<SessionGuard>(
          create: (context) => context.read<AuthSessionBridge>().guard,
        ),
        // 현재 로그인 세션에서 등록한 평점 저장소. 로그아웃·만료 시 스스로 비운다.
        ChangeNotifierProvider<MyRatingsViewModel>(
          create: (context) => MyRatingsViewModel(
            context.read<RatingApiService>(),
            context.read<AuthViewModel>(),
          ),
        ),
      ],
      child: const _MovieLogRouterApp(),
    );
  }
}

/// GoRouter를 한 번만 만들기 위한 Stateful 호스트.
/// build()에서 Router를 만들면 다시 그려질 때마다 위치가 초기화된다.
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
    // 첫 build 이후 세션 복원을 시작한다.
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
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MovieLog',
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
