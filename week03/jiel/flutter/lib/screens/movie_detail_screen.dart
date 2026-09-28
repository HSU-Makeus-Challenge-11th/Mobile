import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/mock/movie.dart';
import '../theme/app_colors.dart';
import '../widgets/rating_dialog.dart';

const _outline = Color(0xFFCBC4D2);

class MovieDetailScreen extends StatelessWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  final int? movieId;

  @override
  Widget build(BuildContext context) {
    final movie = findMovieById(movieId);

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: const _DetailAppBar(),
      body: movie == null
          ? const Center(child: Text('영화를 찾을 수 없어요.'))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeroPoster(movie: movie),
                  _InformationSection(movie: movie),
                  _SynopsisSection(movie: movie),
                ],
              ),
            ),
      bottomNavigationBar: movie == null ? null : const _ActionButtons(),
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
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go('/home'),
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

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 390 / 585,
      child: Container(
        color: AppColors.surfaceHighest,
        child: Image.asset(movie.posterAsset, fit: BoxFit.cover),
      ),
    );
  }
}

// 2. 제목 · 정보 · 별점 · 태그
class _InformationSection extends StatelessWidget {
  const _InformationSection({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final runtime = movie.runtime;
    final reviewCount = movie.reviewCount;

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
          const SizedBox(height: 4),
          Text(
            [
              '${movie.year}',
              movie.genre,
              if (runtime != null) '$runtime분',
            ].join(' • '),
            style: const TextStyle(
              fontSize: 14,
              height: 20 / 14,
              letterSpacing: 0.25,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StarRating(rating: movie.rating),
              const SizedBox(width: 8),
              Text(
                movie.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 16,
                  height: 24 / 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.15,
                  color: AppColors.neutral900,
                ),
              ),
              if (reviewCount != null) ...[
                const SizedBox(width: 4),
                Text(
                  '(${_formatCount(reviewCount)})',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    letterSpacing: 0.25,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          if (movie.tags.isNotEmpty) ...[
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in movie.tags) _TagChip(label: tag),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // 1245 → 1,245
  static String _formatCount(int count) => count.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => ',',
      );
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating});

  final double rating; // 0~5

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            rating >= i
                ? Icons.star
                : rating >= i - 0.5
                    ? Icons.star_half
                    : Icons.star_border,
            size: 17,
            color: AppColors.primary500,
          ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceHighest,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          height: 20 / 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

// 3. 시놉시스
class _SynopsisSection extends StatelessWidget {
  const _SynopsisSection({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    if (movie.synopsis.isEmpty) return const SizedBox.shrink();

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
          for (var i = 0; i < movie.synopsis.length; i++) ...[
            if (i > 0) const SizedBox(height: 26),
            Text(
              movie.synopsis[i],
              style: const TextStyle(
                fontSize: 16,
                height: 26 / 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// 하단 고정 버튼: 즐겨찾기 / 평점 남기기
class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

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
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary500,
                      side: const BorderSide(color: AppColors.primary500),
                      shape: const StadiumBorder(),
                    ),
                    icon: const Icon(Icons.bookmark_border, size: 18),
                    label: const Text('즐겨찾기', style: _labelStyle),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => const RatingDialog(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      foregroundColor: Colors.white,
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
