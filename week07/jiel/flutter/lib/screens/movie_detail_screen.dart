import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/tmdb_movie_dto.dart';
import '../theme/app_colors.dart';
import '../view_models/movie_detail_view_model.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/tmdb_poster_image.dart';

const _outline = Color(0xFFCBC4D2);

/// 영화 상세 화면. 영화 DTO와 평점 등록 상태는 MovieDetailLoader가 제공한 MovieDetailViewModel에서 읽는다.
/// 이 화면은 평점 **등록**만 하고, 조회·수정·삭제는 마이페이지의 "내가 등록한 평점" 화면에서 한다.
class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  // 즐겨찾기는 API 없이 화면 내부 상태로만 관리한다.
  bool _isFavorite = false;

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    _showSnackBar(_isFavorite ? '즐겨찾기에 추가했어요.' : '즐겨찾기에서 삭제했어요.');
  }

  Future<void> _openRatingDialog() async {
    final viewModel = context.read<MovieDetailViewModel>();
    if (!viewModel.canRate) {
      // 회원가입 결과의 memberId가 없는 상태에서는 등록하지 않고 학습용 회원가입으로 안내한다.
      _showSnackBar('먼저 회원가입을 완료해 주세요.');
      return;
    }

    // 저장은 Dialog 안에서 끝낸다. 성공하면 true, 취소하면 false(요청 없음), 뒤로가기면 null.
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 저장 중 바깥 탭으로 닫히는 것도 막는다.
      builder: (_) => RatingDialog(
        onSubmit: (score, comment) async {
          await viewModel.createRating(score: score, comment: comment);
          if (viewModel.submitStatus != SubmitStatus.success) {
            // 실패 문구는 Dialog가 받아 그 자리에서 보여주고, 입력은 유지된다.
            throw StateError(viewModel.submitMessage ?? '저장에 실패했습니다.');
          }
        },
      ),
    );
    // 저장 요청과 Snackbar 표시는 서로 다른 비동기 경계다. await 뒤에는 mounted를 다시 확인한다.
    if (!mounted || saved != true) return;

    _showSnackBar('평점을 등록했습니다. 마이페이지의 "내가 등록한 평점"에서 확인할 수 있습니다.');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MovieDetailViewModel>();
    final movie = viewModel.movie;

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: const _DetailAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeroPoster(movie: movie),
            _InformationSection(movie: movie, canRate: viewModel.canRate),
            _SynopsisSection(movie: movie),
          ],
        ),
      ),
      bottomNavigationBar: _ActionButtons(
        isFavorite: _isFavorite,
        onFavoriteTap: _toggleFavorite,
        // memberId가 없으면 버튼을 비활성화한다. 저장 중 중복 탭은 Dialog가 막는다.
        onRateTap: viewModel.canRate ? _openRatingDialog : null,
      ),
    );
  }
}

// 상단바: 뒤로가기 / 제목 / 공유
class _DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _DetailAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceBase,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: preferredSize.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () =>
                      context.canPop() ? context.pop() : context.go('/home'),
                  icon: const Icon(Icons.arrow_back, size: 20),
                  color: AppColors.primary500,
                ),
                const Expanded(
                  child: Text(
                    'Cinema Archive',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      height: 28 / 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary500,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined, size: 20),
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 1. 포스터
class _HeroPoster extends StatelessWidget {
  const _HeroPoster({required this.movie});

  final TmdbMovieDto movie;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 390 / 585,
      child: Container(
        color: AppColors.surfaceHighest,
        child: TmdbPosterImage(
          posterPath: movie.posterPath,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}

// 2. 제목 · 연도 · 별점
class _InformationSection extends StatelessWidget {
  const _InformationSection({required this.movie, required this.canRate});

  final TmdbMovieDto movie;

  /// 학습용 회원가입(memberId)이 끝났는지. 아니면 평점 등록 안내 문구를 보여준다.
  final bool canRate;

  @override
  Widget build(BuildContext context) {
    // release_date는 'YYYY-MM-DD' 형식이라 앞 4자리만 연도로 쓴다.
    final releaseDate = movie.releaseDate ?? '';
    final year = releaseDate.length >= 4 ? releaseDate.substring(0, 4) : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movie.title,
            style: const TextStyle(
              fontSize: 28,
              height: 36 / 28,
              fontWeight: FontWeight.w500,
              color: AppColors.neutral900,
            ),
          ),
          if (year != null) ...[
            const SizedBox(height: 4),
            Text(
              year,
              style: const TextStyle(
                fontSize: 14,
                height: 20 / 14,
                letterSpacing: 0.25,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              // 평균 평점: 읽기 전용. TMDB는 10점 만점이라 별 5개에 맞춰 절반으로 표시한다.
              RatingBarIndicator(
                rating: movie.voteAverage / 2,
                itemCount: 5,
                itemSize: 17,
                unratedColor: AppColors.primary200,
                itemBuilder: (context, index) =>
                    const Icon(Icons.star, color: AppColors.primary500),
              ),
              const SizedBox(width: 8),
              Text(
                movie.voteAverage.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 16,
                  height: 24 / 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.15,
                  color: AppColors.neutral900,
                ),
              ),
            ],
          ),
          if (!canRate) ...[
            const SizedBox(height: 8),
            const Text(
              '평점을 남기려면 먼저 학습용 회원가입을 완료해 주세요.',
              style: TextStyle(
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primary500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// 3. 시놉시스
class _SynopsisSection extends StatelessWidget {
  const _SynopsisSection({required this.movie});

  final TmdbMovieDto movie;

  @override
  Widget build(BuildContext context) {
    if (movie.overview.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _outline)),
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
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.overview,
            style: const TextStyle(
              fontSize: 16,
              height: 26 / 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// 하단 고정 버튼: 즐겨찾기 / 평점 남기기
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onRateTap,
  });

  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  /// null이면 비활성화(학습용 회원가입 전).
  final VoidCallback? onRateTap;

  static const _labelStyle = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceBase,
        border: Border(top: BorderSide(color: _outline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: onFavoriteTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary500,
                      side: const BorderSide(color: AppColors.primary500),
                      shape: const StadiumBorder(),
                    ),
                    icon: Icon(
                      isFavorite ? Icons.bookmark : Icons.bookmark_border,
                      size: 18,
                    ),
                    label: const Text('즐겨찾기', style: _labelStyle),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: onRateTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.neutral600,
                      disabledForegroundColor: AppColors.neutral800,
                      shape: const StadiumBorder(),
                      elevation: 1,
                    ),
                    icon: const Icon(Icons.star_outline, size: 20),
                    label: const Text('평점 남기기', style: _labelStyle),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
