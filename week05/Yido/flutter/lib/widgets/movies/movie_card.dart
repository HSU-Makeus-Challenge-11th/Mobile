import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/models/movie.dart';

class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.movie,
    this.width,
    this.posterHeight,
  });
  final Movie movie;
  final double? width;
  final double? posterHeight;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final resolvedWidth = width ?? constraints.maxWidth;
      final resolvedHeight = posterHeight ?? resolvedWidth * 1.5;
      return Semantics(
        button: true,
        label: '${movie.title} 상세 보기',
        child: GestureDetector(
          onTap: () => context.push('/movies/${movie.id}'),
          child: SizedBox(
            width: resolvedWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        movie.posterAsset,
                        width: resolvedWidth,
                        height: resolvedHeight,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        height: 24,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xCC322F35),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '★ ${movie.rating}',
                          style: const TextStyle(
                            fontSize: 12,
                            height: 16 / 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFF5EFF7),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 24,
                  child: Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: true,
                      applyHeightToLastDescent: true,
                    ),
                    strutStyle: const StrutStyle(
                      fontFamily: 'Manrope',
                      fontSize: 16,
                      height: 1.5,
                      forceStrutHeight: true,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      height: 24 / 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1D1B20),
                    ),
                  ),
                ),
                SizedBox(
                  height: 24,
                  child: Text(
                    '${movie.year} · ${movie.genre}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: true,
                      applyHeightToLastDescent: true,
                    ),
                    strutStyle: const StrutStyle(
                      fontFamily: 'Manrope',
                      fontSize: 16,
                      height: 1.5,
                      forceStrutHeight: true,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      height: 24 / 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xCC494551),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
