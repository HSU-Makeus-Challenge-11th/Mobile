import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/view_models/favorite_detail_view_model.dart';
import 'package:movielog/view_models/movie_detail_view_model.dart';
import 'package:movielog/view_models/submit_status.dart';
import 'package:movielog/widgets/favorites/favorite_button.dart';
import 'package:movielog/widgets/movies/rating_dialog.dart';
import 'package:movielog/widgets/tmdb_poster_image.dart';
import 'package:provider/provider.dart';

/// 목록·홈에서 상세로 넘기는 값. 장르 이름은 Genre API 결과에서 찾아 둔다
class MovieDetailArgs {
  const MovieDetailArgs({required this.movie, this.genreNames = const []});
  final TmdbMovieDto movie;
  final List<String> genreNames;
}

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.args});

  final MovieDetailArgs args;
  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  @override
  void initState() {
    super.initState();
    // 화면이 처음 만들어질 때 서버의 즐겨찾기 여부를 한 번 조회한다. build에서는 조회하지 않는다
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<FavoriteDetailViewModel>().load();
    });
  }

  Future<void> _openRatingDialog() async {
    final messenger = ScaffoldMessenger.of(context);
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 저장 중 바깥 탭으로 닫히는 것도 막는다
      barrierColor: ratingDialogBarrierColor,
      builder: (_) => RatingDialog(
        onSubmit: (score, comment) async {
          final viewModel = context.read<MovieDetailViewModel>();
          await viewModel.createRating(score: score, comment: comment);
          if (viewModel.submitStatus != SubmitStatus.success) {
            final message = viewModel.submitMessage ?? '저장에 실패했습니다.';
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
            throw StateError(message);
          }
        },
      ),
    );

    if (!mounted || saved != true) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('평점을 등록했습니다. 마이페이지의 "내가 등록한 평점"에서 수정·삭제할 수 있습니다.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    final movie = args.movie;
    final signedIn = context.select<AuthViewModel, bool>(
      (auth) => auth.status == AuthStatus.signedIn,
    );
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            size: 16,
            color: Color(0xFF6750A4),
          ),
        ),
        title: const Text(
          'Cinema Archive',
          style: TextStyle(
            fontSize: 22,
            height: 28 / 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6750A4),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.ios_share,
              size: 18,
              color: Color(0xFF494551),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 81),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) => TmdbPosterImage(
                posterPath: movie.posterPath,
                width: constraints.maxWidth,
                height: 585,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목·정보 텍스트 오른쪽에 W9 즐겨찾기 버튼을 둔다
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title,
                              style: const TextStyle(
                                fontSize: 28,
                                height: 36 / 28,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1B1C1A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              [
                                ?movie.releaseYear,
                                ...args.genreNames.take(2),
                              ].join(' • '),
                              style: const TextStyle(
                                fontSize: 14,
                                height: 20 / 14,
                                letterSpacing: .25,
                                color: Color(0xFF494551),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const FavoriteButton(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: movie.voteAverage / 2,
                        itemCount: 5,
                        itemSize: 16.67,
                        itemBuilder: (context, index) =>
                            const Icon(Icons.star, color: Color(0xFF6750A4)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        (movie.voteAverage / 2).toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 16,
                          height: 24 / 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final name in args.genreNames) _GenreChip(name),
                    ],
                  ),
                  Selector<FavoriteDetailViewModel, String?>(
                    selector: (_, vm) => vm.isSaving ? null : vm.errorMessage,
                    builder: (context, message, _) => message == null
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: FavoriteErrorBox(message: message),
                          ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFCBC4D2))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '시놉시스',
                    style: TextStyle(
                      fontSize: 22,
                      height: 28 / 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (movie.overview.isEmpty)
                    const SizedBox(
                      height: 120,
                      child: Center(
                        child: Text(
                          '줄거리 정보가 없어요.',
                          style: TextStyle(
                            fontSize: 16,
                            height: 26 / 16,
                            color: Color(0xFF494551),
                          ),
                        ),
                      ),
                    )
                  else
                    Text(
                      movie.overview,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 26 / 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: .5,
                        color: Color(0xFF494551),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 81,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFAF9F5),
              border: Border(top: BorderSide(color: Color(0xFFCBC4D2))),
            ),
            // 3주차 mock 즐겨찾기 버튼을 제목 옆으로 옮겨 평점 버튼이 전체 너비를 쓴다
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                key: const Key('openRatingButton'),
                onPressed: signedIn ? _openRatingDialog : null,
                icon: const Icon(Icons.star, size: 20),
                label: const Text('평점 남기기'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    height: 28,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFE3E2DF),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w500,
        letterSpacing: .1,
        color: Color(0xFF494551),
      ),
    ),
  );
}
