import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'core/network/movie_log_client.dart';
import 'core/network/tmdb_client.dart';
import 'data/services/member_check_service.dart';
import 'data/services/rating_api_service.dart';
import 'data/services/tmdb_movie_service.dart';
import 'router/app_router.dart';
import 'services/genre_preference.dart';
import 'services/movie_service.dart';
import 'theme/app_theme.dart';
import 'view_models/learning_member_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.movieService, this.genrePreferenceStore});

  final MovieService? movieService;
  final GenrePreferenceStore? genrePreferenceStore;

  @override
  Widget build(BuildContext context) {
    final movieLogClient = createMovieLogClient();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LearningMemberSession>(
          create: (_) => LearningMemberSession(),
        ),
        Provider<MovieService>(
          create: (_) =>
              movieService ??
              (dotenv.isInitialized
                  ? TmdbMovieService(createTmdbClient())
                  : FakeMovieService(delay: Duration.zero)),
        ),
        Provider<GenrePreferenceStore>(
          create: (_) => genrePreferenceStore ?? GenrePreference(),
        ),
        Provider<MemberCheckService>(
          create: (_) => MemberCheckService(movieLogClient),
        ),
        Provider<RatingApiService>(
          create: (_) => RatingApiService(movieLogClient),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'MovieLog',
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
