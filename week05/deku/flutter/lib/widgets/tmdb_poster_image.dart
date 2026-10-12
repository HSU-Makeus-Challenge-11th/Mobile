import 'package:flutter/material.dart';

import '../core/config/tmdb_config.dart';
import '../data/models/tmdb_movie_dto.dart';
import '../theme/app_colors.dart';

class TmdbPosterImage extends StatelessWidget {
  const TmdbPosterImage({
    super.key,
    required this.movie,
    this.fit = BoxFit.cover,
  });

  final TmdbMovieDto movie;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final localAsset = movie.localPosterAsset;
    if (localAsset != null) {
      return Image.asset(localAsset, fit: fit);
    }

    final posterPath = movie.posterPath;
    if (posterPath == null) return _placeholder();

    return Image.network(
      '${TmdbConfig.imageBaseUrl}$posterPath',
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return const ColoredBox(
          color: AppColors.surfaceLow,
          child: Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stackTrace) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return ColoredBox(
      key: ValueKey('tmdb-poster-placeholder-${movie.id}'),
      color: AppColors.surfaceLow,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.movie_outlined, size: 42, color: AppColors.gray),
            SizedBox(height: 8),
            Text('포스터가 없어요', style: TextStyle(color: AppColors.gray)),
          ],
        ),
      ),
    );
  }
}
