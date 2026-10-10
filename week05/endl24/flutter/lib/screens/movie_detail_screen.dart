import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:movielog/models/tmdb_movie_dto.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/widgets/rating_dialog.dart';
import 'package:movielog/widgets/tmdb_poster_image.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movie});

  final TmdbMovieDto? movie;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isFavorite = false;

  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? '즐겨찾기에 추가했습니다.' : '즐겨찾기에서 삭제했습니다.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _openRatingDialog(TmdbMovieDto movie) async {
    final rating = await showDialog<double>(
      context: context,
      builder: (context) => RatingDialog(movieTitle: movie.title),
    );

    if (rating == null) return;
    if (!mounted) return;

    // TODO(평점 API): CreateRatingRequest(movieId: movie.id, score: rating)로 전송
    debugPrint('[평점] movieId=${movie.id} score=$rating');

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$rating점으로 평점을 등록했습니다.'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    if (movie == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('영화를 찾을 수 없습니다.')),
      );
    }

    final year = movie.releaseDate?.split('-').first;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cinema Archive',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.violet,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TmdbPosterImage(
                      posterPath: movie.posterPath,
                      width: double.infinity,
                      height: 360,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                          ),
                          if (year != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              year,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.gray,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          _AverageRating(
                            rating: movie.voteAverage,
                            count: movie.voteCount,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            '시놉시스',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          movie.overview.isEmpty
                              ? const Center(child: Text('줄거리 정보가 없어요.'))
                              : Text(
                                  movie.overview,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.6,
                                    color: AppColors.grayDark,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _DetailActions(
              isFavorite: _isFavorite,
              onFavoriteTap: _toggleFavorite,
              onRatingTap: () => _openRatingDialog(movie),
            ),
          ],
        ),
      ),
    );
  }
}

class _AverageRating extends StatelessWidget {
  const _AverageRating({required this.rating, required this.count});

  final double rating;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RatingBarIndicator(
          rating: rating / 2,
          itemCount: 5,
          itemSize: 20,
          unratedColor: AppColors.grayLine,
          itemBuilder: (context, index) =>
              const Icon(Icons.star, color: AppColors.violet),
        ),
        const SizedBox(width: 8),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($count)',
          style: const TextStyle(fontSize: 14, color: AppColors.gray),
        ),
      ],
    );
  }
}

class _DetailActions extends StatelessWidget {
  const _DetailActions({
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onRatingTap,
  });

  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onRatingTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onFavoriteTap,
              icon: Icon(
                isFavorite ? Icons.bookmark : Icons.bookmark_border,
                size: 20,
              ),
              label: Text(isFavorite ? '즐겨찾기 해제' : '즐겨찾기'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: AppColors.violet,
                side: const BorderSide(color: AppColors.violet),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onRatingTap,
              icon: const Icon(Icons.rate_review_outlined, size: 20),
              label: const Text('평점 남기기'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: AppColors.violet,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
