import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

import '../../models/movie.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/movie_rating_input.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movie});

  static const routePattern = '/movies/:movieId';

  final Movie movie;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isFavorite = false;
  double? _myRating;

  Future<void> _openRatingDialog() async {
    final rating = await showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RatingDialog(initialRating: _myRating ?? 3.5),
    );

    if (!mounted || rating == null) return;
    setState(() => _myRating = rating);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text('평점 ${rating.toStringAsFixed(1)}점을 남겼습니다.')),
    );
  }

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? '즐겨찾기에 추가했습니다.' : '즐겨찾기에서 삭제했습니다.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        leading: IconButton(
          tooltip: '뒤로 가기',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          'Cinema Archive',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            height: 28 / 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: '공유',
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('공유 링크를 준비했습니다.')));
            },
            icon: const Icon(Icons.share_outlined, size: 18),
          ),
        ],
      ),
      body: SingleChildScrollView(
        key: const Key('movie-detail-scroll-view'),
        padding: const EdgeInsets.only(bottom: AppSpacing.x2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              key: const Key('detail-hero-poster'),
              height: 585,
              child: Image.asset(movie.posterAsset, fit: BoxFit.cover),
            ),
            SizedBox(
              key: const Key('detail-information-section'),
              height: 216,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      key: const Key('detail-title-line'),
                      height: 36,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          movie.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleLargeMedium.copyWith(
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x0_5),
                    SizedBox(
                      key: const Key('detail-metadata-line'),
                      height: 20,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${movie.id == 1 ? 2024 : movie.year} · ${movie.id == 1 ? '로맨스/드라마' : movie.genre} · ${movie.runtimeMinutes}분',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMediumRegular.copyWith(
                            height: 1,
                            color: AppColors.gray,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x0_5),
                    SizedBox(
                      height: 36,
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.x1_5),
                        child: Row(
                          children: [
                            SizedBox(
                              key: const Key('average-rating-indicator'),
                              child: RatingBarIndicator(
                                rating: movie.rating,
                                itemCount: 5,
                                itemSize: 16.67,
                                unratedColor: AppColors.secondary300,
                                itemBuilder: (context, index) => const Icon(
                                  Icons.star_rounded,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.x1),
                            Text(
                              movie.rating.toStringAsFixed(1),
                              style: AppTextStyles.bodyLargeMedium.copyWith(
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.x0_5),
                            Text(
                              '(${movie.reviewCount == 1245 ? '1,245' : movie.reviewCount})',
                              style: AppTextStyles.bodyMediumRegular.copyWith(
                                height: 1,
                                color: AppColors.gray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x0_5),
                    SizedBox(
                      height: 48,
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.x2_5),
                        child: Wrap(
                          spacing: AppSpacing.x1,
                          children: [
                            if (movie.id == 1) const _GenreTag(label: '로맨스'),
                            _GenreTag(label: movie.genre),
                            const _GenreTag(label: '감동적인'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            SizedBox(
              key: const Key('detail-synopsis-section'),
              height: 562,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.x2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '시놉시스',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 22,
                        height: 28 / 22,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x1),
                    _SynopsisParagraphs(text: movie.synopsis),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 81,
          padding: const EdgeInsets.all(AppSpacing.x2),
          decoration: const BoxDecoration(
            color: AppColors.warmWhite,
            border: Border(top: BorderSide(color: AppColors.secondary300)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  key: const Key('favorite-button'),
                  onPressed: _toggleFavorite,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: AppColors.primary),
                    foregroundColor: AppColors.primary,
                    shape: const StadiumBorder(),
                  ),
                  icon: Icon(
                    _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                    size: 18,
                  ),
                  label: Text(_isFavorite ? '저장됨' : '즐겨찾기'),
                ),
              ),
              const SizedBox(width: AppSpacing.x1),
              Expanded(
                child: FilledButton.icon(
                  key: const Key('open-rating-dialog-button'),
                  onPressed: _openRatingDialog,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: const StadiumBorder(),
                  ),
                  icon: const Icon(Icons.rate_review_outlined, size: 18),
                  label: const Text('평점 남기기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key, required this.initialRating});

  final double initialRating;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late double _rating = widget.initialRating;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const Key('rating-dialog'),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
      backgroundColor: AppColors.warmWhite,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('영화는 어떠셨나요?', style: AppTextStyles.bodyLargeBold),
            const SizedBox(height: AppSpacing.x2),
            MovieRatingInput(
              rating: _rating,
              onChanged: (value) => setState(() => _rating = value),
            ),
            const SizedBox(height: AppSpacing.x3),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                key: const Key('confirm-rating-button'),
                onPressed: () => Navigator.pop(context, _rating),
                child: const Text('확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenreTag extends StatelessWidget {
  const _GenreTag({required this.label});

  final String label;

  double get _width => switch (label) {
    '로맨스' || '드라마' => 63,
    '감동적인' => 76,
    _ => 24 + (label.length * 14),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('detail-genre-$label'),
      width: _width,
      height: 28,
      decoration: const BoxDecoration(
        color: AppColors.secondary100,
        borderRadius: AppRadius.pill,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppTextStyles.bodyMediumMedium.copyWith(
          color: AppColors.profileOnSurfaceVariant,
        ),
      ),
    );
  }
}

class _SynopsisParagraphs extends StatelessWidget {
  const _SynopsisParagraphs({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final paragraphs = text.split('\n\n');
    const paragraphHeights = [130.0, 130.0, 104.0, 52.0];

    return SizedBox(
      width: 330,
      height: 494,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < paragraphs.length; index++) ...[
            SizedBox(
              height: paragraphHeights[index.clamp(0, 3)],
              child: Text(
                paragraphs[index],
                maxLines: (paragraphHeights[index.clamp(0, 3)] / 26).round(),
                overflow: TextOverflow.clip,
                style: const TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 16,
                  height: 26 / 16,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray,
                ),
              ),
            ),
            if (index != paragraphs.length - 1) const SizedBox(height: 26),
          ],
        ],
      ),
    );
  }
}
