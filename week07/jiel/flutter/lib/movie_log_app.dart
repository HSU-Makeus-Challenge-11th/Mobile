import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'package:movielog/router/app_router.dart';
import 'package:movielog/core/network/tmdb_client.dart';          // createTmdbClient()
import 'package:movielog/core/network/movie_log_client.dart';     // createMovieLogClient()
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/data/services/sign_up_service.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/view_models/learning_member_session.dart';

class MovieLogApp extends StatelessWidget {
  const MovieLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 두 Service는 같은 워크북 백엔드를 호출하므로 Dio 인스턴스 하나를 공유한다.
    // TMDB Client와는 baseUrl·헤더가 다르므로 분리한다.
    final movieLogClient = createMovieLogClient();

    return MultiProvider(
      providers: [
        Provider<TmdbMovieService>(
          create: (_) => TmdbMovieService(createTmdbClient()),
        ),
        Provider<SignUpService>(
          create: (_) => SignUpService(movieLogClient),
        ),
        Provider<RatingApiService>(
          create: (_) => RatingApiService(movieLogClient),
        ),
        // 회원가입 성공 응답의 memberId를 앱 최상단에 보관한다(학습용, 인증 아님).
        // 영화 상세·마이페이지 Route가 같은 값을 읽어 평점 요청 path에 쓴다.
        ChangeNotifierProvider<LearningMemberSession>(
          create: (_) => LearningMemberSession(),
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
