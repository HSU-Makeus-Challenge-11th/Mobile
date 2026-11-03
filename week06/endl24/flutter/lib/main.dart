import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:movielog/core/network/movie_api_client.dart';
import 'package:movielog/core/network/tmdb_client.dart';
import 'package:movielog/data/services/member_check_service.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/router/app_router.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
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
    final movieApiClient = createMovieApiClient();

    return MultiProvider(
      providers: [
        Provider<RatingApiService>(
          create: (_) => RatingApiService(movieApiClient),
        ),
        Provider<MemberCheckService>(
          create: (_) => MemberCheckService(movieApiClient),
        ),
        Provider<TmdbMovieService>(
          create: (_) => TmdbMovieService(createTmdbClient()),
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
