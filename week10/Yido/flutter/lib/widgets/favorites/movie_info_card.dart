import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/widgets/auth/figma_text.dart';
import 'package:movielog/widgets/tmdb_poster_image.dart';

/// W9 목록 카드: 342x144, 포스터 78x116, 제목·설명·태그 세 줄
class MovieInfoCard extends StatelessWidget {
  const MovieInfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.tag,
    this.posterPath,
    this.posterFailed = false,
    this.onTap,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String? tag;
  final String? posterPath;

  /// 영화 정보 조회에 실패한 카드는 포스터 자리를 연보라 상자로 둔다
  final bool posterFailed;
  final VoidCallback? onTap;
  final String? actionLabel;
  final VoidCallback? onAction;

  TextStyle _style(double size, double line, FontWeight weight, Color color) =>
      w8Text(size, weight, color).copyWith(height: line / size);

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surfaceBright,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppColors.cardBorder),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: posterFailed
                    ? Container(
                        width: 78,
                        height: 116,
                        color: const Color(0xFFEEE8F3),
                      )
                    : TmdbPosterImage(
                        posterPath: posterPath,
                        width: 78,
                        height: 116,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _style(17, 23, FontWeight.w700, AppColors.ink),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _style(
                          12,
                          16,
                          FontWeight.w400,
                          AppColors.mutedText,
                        ),
                      ),
                      if (tag != null) ...[
                        const SizedBox(height: 13),
                        Text(
                          tag!,
                          style: _style(
                            13,
                            18,
                            FontWeight.w700,
                            AppColors.primary500,
                          ),
                        ),
                      ],
                      if (actionLabel != null)
                        GestureDetector(
                          key: const Key('cardActionButton'),
                          behavior: HitTestBehavior.opaque,
                          onTap: onAction,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              actionLabel!,
                              style: _style(
                                12,
                                16,
                                FontWeight.w700,
                                AppColors.primary500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
