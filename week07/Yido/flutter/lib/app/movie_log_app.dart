import 'package:flutter/material.dart';
import 'package:movielog/core/network/movie_log_client.dart';
import 'package:movielog/core/network/tmdb_client.dart';
import 'package:movielog/data/services/sign_up_service.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/router/app_router.dart';
import 'package:movielog/theme/app_theme.dart';
import 'package:movielog/view_models/learning_member_session.dart';
import 'package:provider/provider.dart';

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({
    super.key,
    this.movieService,
    this.signUpService,
    this.ratingApiService,
  });

  /// 테스트에서 가짜 Service를 넣을 때만 사용한다
  final TmdbMovieService? movieService;
  final SignUpService? signUpService;
  final RatingApiService? ratingApiService;

  @override
  Widget build(BuildContext context) {
    // 같은 백엔드를 호출하는 두 Service는 Dio 하나를 함께 쓴다
    final movieLogClient = createMovieLogClient();

    // 여러 Route가 함께 쓰는 Service는 MaterialApp.router 바깥 최상단에 둔다
    return MultiProvider(
      providers: [
        Provider<TmdbMovieService>(
          create: (_) => movieService ?? TmdbMovieService(createTmdbClient()),
        ),
        ChangeNotifierProvider<LearningMemberSession>(
          create: (_) => LearningMemberSession(),
        ),
        Provider<SignUpService>(
          create: (_) => signUpService ?? SignUpService(movieLogClient),
        ),
        Provider<RatingApiService>(
          create: (_) => ratingApiService ?? RatingApiService(movieLogClient),
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
