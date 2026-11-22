import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/models/rating_dto.dart';
import '../data/models/rating_with_movie.dart';
import '../theme/app_colors.dart';
import '../view_models/my_ratings_view_model.dart';
import '../widgets/empty_view.dart';
import '../widgets/movielog_button.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/tmdb_poster_image.dart';

/// 마이페이지의 자식 화면. root Navigator 위에 열리므로 하단 NavigationBar가 없다.
/// 8주차: v7에는 토큰 기반 '내 평점 목록 GET'이 없으므로, 이번 로그인 세션에서 등록 response로
/// 받은 Rating을 앱 최상단 MyRatingsViewModel에서 읽고 v7 PATCH/DELETE로 변경한다.
class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  /// 수정 버튼: 평점 등록과 같은 RatingDialog를 기존 score·comment로 채워 다시 연다.
  /// 저장(PATCH)은 Dialog 안에서 끝나고, 성공하면 ViewModel이 목록을 다시 읽는다.
  static Future<void> onEditPressed(BuildContext context, RatingDto rating) async {
    final viewModel = context.read<MyRatingsViewModel>();
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 저장 중 바깥 탭으로 닫히는 것도 막는다.
      builder: (_) => RatingDialog(
        initialScore: rating.score,
        initialComment: rating.comment, // null이면 TextField가 빈 칸으로 시작한다.
        onSubmit: (score, comment) async {
          final error = await viewModel.updateRating(
            ratingId: rating.ratingId,
            score: score,
            comment: comment, // 유지하려면 기존 값이 그대로, 지우면 null이 전달된다.
          );
          // 쓰기 실패: 도메인 오류 문구를 Dialog 안에 보여주고 입력은 유지한다.
          if (error != null) throw StateError(error);
        },
      ),
    );
    // 취소하거나 저장에 실패하면(saved != true) 별도 처리 없이 목록에 머문다.
    if (!context.mounted || saved != true) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('평점을 수정했습니다.')));
  }

  /// 삭제 버튼: 확인 Dialog를 먼저 띄우고, "삭제"를 눌렀을 때만 DELETE를 보낸다.
  static Future<void> onDeletePressed(BuildContext context, RatingDto rating) async {
    final viewModel = context.read<MyRatingsViewModel>();
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 삭제 중 바깥 탭으로 닫히는 것도 막는다.
      builder: (_) => _DeleteRatingDialog(
        onConfirm: () async {
          final error = await viewModel.deleteRating(rating.ratingId);
          if (error != null) throw StateError(error);
        },
      ),
    );
    // confirmed는 실제로 삭제까지 마쳤을 때만 true다. 취소하면 요청 자체가 없다.
    if (!context.mounted || confirmed != true) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('평점을 삭제했습니다.')));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surfaceBase,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceBase,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(
          color: AppColors.onSurface,
          onPressed: () => context.pop(),
        ),
        title: Text(
          '내가 등록한 평점',
          style: textTheme.titleLarge?.copyWith(color: AppColors.primary500),
        ),
      ),
      body: Consumer<MyRatingsViewModel>(
        builder: (context, viewModel, child) {
          final ratings = viewModel.ratings;
          if (ratings.isEmpty) {
            return const EmptyView(
              message: '이번 로그인에서 등록한 평점이 없어요.\n영화 상세 화면에서 평점을 남겨 보세요.',
            );
          }
          return _RatingList(ratings: ratings, isWriting: viewModel.isWriting);
        },
      ),
    );
  }
}

class _RatingList extends StatelessWidget {
  const _RatingList({required this.ratings, required this.isWriting});

  final List<RatingWithMovie> ratings;

  /// 수정·삭제 요청이 진행 중이면 다른 카드의 버튼도 잠근다.
  final bool isWriting;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: ratings.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '이번 로그인에서 등록한 평점 ${ratings.length}개',
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'v7에는 토큰 기반 내 평점 목록 조회가 없어 앱 재시작 후에는 복원되지 않아요.',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.neutral800,
                ),
              ),
            ],
          );
        }
        final entry = ratings[index - 1];
        return _RatingCard(
          entry: entry,
          // 현재 토큰으로 등록한 평점이므로 수정·삭제를 보여준다.
          // 서버가 RATING403_1로 거부하면 ViewModel이 안내만 하고 로그아웃하지 않는다.
          onEdit: isWriting
              ? null
              : () => MyRatingsScreen.onEditPressed(context, entry.rating),
          onDelete: isWriting
              ? null
              : () => MyRatingsScreen.onDeletePressed(context, entry.rating),
        );
      },
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final RatingWithMovie entry;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  String _formatDate(DateTime dateTime) {
    final local = dateTime.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${local.year}.${two(local.month)}.${two(local.day)}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final rating = entry.rating;
    final movie = entry.movie;
    final comment = rating.comment;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLowest,
        border: Border.all(color: AppColors.primary200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            // movie가 null이면 posterPath도 null → TmdbPosterImage가 placeholder를 그린다.
            child: TmdbPosterImage(
              posterPath: movie?.posterPath,
              width: 64,
              height: 96,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // TMDB 정보가 없어도 평점은 지우지 않고 placeholder로 표시한다.
                  movie?.title ?? '영화 #${rating.movieId}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: movie == null
                        ? AppColors.neutral800
                        : AppColors.onSurface,
                  ),
                ),
                if (movie == null)
                  Text(
                    'movieId ${rating.movieId}',
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.neutral800,
                    ),
                  ),
                const SizedBox(height: 6),
                _ScoreStars(score: rating.score),
                // comment가 null(또는 빈 문자열)이면 표시하지 않는다.
                if (comment != null && comment.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    comment,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  _formatDate(rating.createdAt),
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.neutral800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 카드 오른쪽: 개별 수정 / 삭제 버튼 (Figma W7-REQ)
          Column(
            children: [
              _CardActionButton(
                label: '수정',
                background: AppColors.primary200,
                foreground: AppColors.primary600,
                onPressed: onEdit,
              ),
              const SizedBox(height: 8),
              _CardActionButton(
                label: '삭제',
                background: const Color(0xFFFFDAD6),
                foreground: Theme.of(context).colorScheme.error,
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 32,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: AppColors.neutral400,
          disabledForegroundColor: AppColors.neutral800,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: onPressed == null ? AppColors.neutral800 : foreground,
          ),
        ),
      ),
    );
  }
}

/// 평점 삭제 확인 Dialog (Figma W7-REQ 평점 삭제 확인).
/// 삭제 API 요청 중에는 Dialog를 유지하고 임의로 닫히지 않게 한다.
/// "취소"를 누르면 onConfirm을 호출하지 않으므로 삭제 요청을 보내지 않는다.
class _DeleteRatingDialog extends StatefulWidget {
  const _DeleteRatingDialog({required this.onConfirm});
  final Future<void> Function() onConfirm;

  @override
  State<_DeleteRatingDialog> createState() => _DeleteRatingDialogState();
}

class _DeleteRatingDialogState extends State<_DeleteRatingDialog> {
  bool _isDeleting = false;

  Future<void> _onConfirm() async {
    if (_isDeleting) return;
    setState(() => _isDeleting = true);
    try {
      await widget.onConfirm();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      // 실패하면 로딩을 풀고 Dialog를 유지해 다시 시도할 수 있게 둔다.
      setState(() => _isDeleting = false);
      // 403(본인 평점 아님)과 404(평점 없음)는 서버 message가 달라 그대로 구분해 보여준다.
      final text = error is StateError
          ? error.message
          : '삭제하지 못했습니다. 잠시 후 다시 시도해 주세요.';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(text)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: !_isDeleting,
      child: Dialog(
        backgroundColor: AppColors.surfaceBase,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '평점을 삭제할까요?',
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(color: AppColors.onSurface),
              ),
              const SizedBox(height: 12),
              Text(
                '삭제한 평점은 복구할 수 없습니다.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: MovieLogButton(
                      label: '취소',
                      height: 48,
                      onPressed: _isDeleting
                          ? null
                          : () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: MovieLogButton(
                      label: '삭제',
                      height: 48,
                      isLoading: _isDeleting,
                      onPressed: _isDeleting ? null : _onConfirm,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreStars extends StatelessWidget {
  const _ScoreStars({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= score ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 18,
            color: AppColors.tertiary200,
          ),
        const SizedBox(width: 6),
        Text(
          '$score',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }
}
