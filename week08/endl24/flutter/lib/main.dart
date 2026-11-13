import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/core/network/movie_api_client.dart';
import 'package:movielog/core/network/tmdb_client.dart';
import 'package:movielog/core/storage/token_storage.dart';
import 'package:movielog/data/services/auth_api_service.dart';
import 'package:movielog/data/services/member_api_service.dart';
import 'package:movielog/data/services/sign_up_service.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/router/app_router.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/view_models/learning_member_session.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MovieLogApp());
}

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tokenStorage = SecureTokenStorage(const FlutterSecureStorage());
    final movieApiClient = createMovieApiClient(); // 공개용: Interceptor 없음
    final authMovieApiClient = createAuthMovieApiClient(tokenStorage); // 보호용

    return MultiProvider(
      providers: [
        Provider<TokenStorage>.value(value: tokenStorage),
        ChangeNotifierProvider<LearningMemberSession>(
          create: (_) => LearningMemberSession(),
        ),
        // 공개 Client
        Provider<AuthApiService>(create: (_) => AuthApiService(movieApiClient)),
        Provider<SignUpService>(create: (_) => SignUpService(movieApiClient)),
        Provider<RatingApiService>(
          create: (_) => RatingApiService(movieApiClient),
        ),
        // 보호 Client
        Provider<MemberApiService>(
          create: (_) => MemberApiService(authMovieApiClient),
        ),
        Provider<TmdbMovieService>(
          create: (_) => TmdbMovieService(createTmdbClient()),
        ),
        ChangeNotifierProvider<AuthViewModel>(
          create: (context) => AuthViewModel(
            context.read<AuthApiService>(),
            context.read<MemberApiService>(),
            context.read<TokenStorage>(),
          ),
        ),
      ],
      child: const _MovieLogRouterApp(),
    );
  }
}

/// GoRouter를 앱이 살아있는 동안 한 번만 만들기 위한 StatefulWidget입니다.
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
    // 첫 build가 끝난 뒤 세션 복원을 시작합니다.
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
