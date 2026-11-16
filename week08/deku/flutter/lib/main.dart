import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import 'core/network/auth_interceptor.dart';
import 'core/network/movie_log_client.dart';
import 'core/network/tmdb_client.dart';
import 'core/storage/token_storage.dart';
import 'data/services/auth_api_service.dart';
import 'data/services/member_check_service.dart';
import 'data/services/member_api_service.dart';
import 'data/services/rating_api_service.dart';
import 'data/services/tmdb_movie_service.dart';
import 'router/app_router.dart';
import 'services/genre_preference.dart';
import 'services/movie_service.dart';
import 'theme/app_theme.dart';
import 'view_models/auth_view_model.dart';
import 'view_models/learning_member_session.dart';
import 'view_models/session_ratings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.movieService, this.genrePreferenceStore});

  final MovieService? movieService;
  final GenrePreferenceStore? genrePreferenceStore;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final _publicDio = createMovieLogClient();
  late final _authDio = createMovieLogClient();
  late final TokenStorage _storage = SecureTokenStorage(
    const FlutterSecureStorage(),
  );
  late final _ratings = SessionRatingsStore();
  late final _auth = AuthViewModel(
    AuthApiService(_publicDio),
    MemberApiService(_authDio),
    _storage,
    _ratings,
  );
  late final _router = AppRouter.createRouter(_auth);

  @override
  void initState() {
    super.initState();
    _authDio.interceptors.add(
      AuthInterceptor(_storage, onExpired: _auth.expireSession),
    );
    _auth.restoreSession();
  }

  @override
  void dispose() {
    _router.dispose();
    _auth.dispose();
    _ratings.dispose();
    _publicDio.close(force: true);
    _authDio.close(force: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>.value(value: _auth),
        ChangeNotifierProvider<SessionRatingsStore>.value(value: _ratings),
        ChangeNotifierProvider<LearningMemberSession>(
          create: (_) => LearningMemberSession(),
        ),
        Provider<MovieService>(
          create: (_) =>
              widget.movieService ??
              (dotenv.isInitialized
                  ? TmdbMovieService(createTmdbClient())
                  : FakeMovieService(delay: Duration.zero)),
        ),
        Provider<GenrePreferenceStore>(
          create: (_) => widget.genrePreferenceStore ?? GenrePreference(),
        ),
        Provider<MemberCheckService>(
          create: (_) => MemberCheckService(_publicDio),
        ),
        Provider<RatingApiService>(
          create: (_) => RatingApiService(_publicDio, authDio: _authDio),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'MovieLog',
        theme: AppTheme.light,
        routerConfig: _router,
      ),
    );
  }
}
