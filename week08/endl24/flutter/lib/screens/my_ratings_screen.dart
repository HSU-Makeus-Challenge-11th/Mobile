import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/data/models/rating_with_movie.dart';
import 'package:movielog/data/services/rating_api_service.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';
import 'package:movielog/view_models/my_ratings_view_model.dart';
import 'package:movielog/widgets/common_app_bar.dart';
import 'package:movielog/widgets/movielog_button.dart';
import 'package:movielog/widgets/rating_dialog.dart';
import 'package:movielog/widgets/tmdb_poster_image.dart';
import 'package:provider/provider.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: '내가 등록한 평점',
        centerTitle: true,
        onBack: () => context.pop(),
      ),
      // bottomNavigationBar는 넣지 않아요 (하단 탭이 없는 화면)
      body: SafeArea(
        child: Consumer<MyRatingsViewModel>(
          builder: (context, viewModel, child) =>
              _buildBody(context, viewModel),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, MyRatingsViewModel viewModel) {
    // v7에는 토큰으로 내 평점 전체를 받는 API가 없어 이번 로그인에서 등록한 평점만 보여줘요.
    const notice = Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Text(
        '이번 로그인에서 등록한 평점만 보여요. 로그아웃하거나 앱을 다시 실행하면 목록이 비워져요.',
        style: AppTextStyles.bodySmall,
      ),
    );
    if (viewModel.ratings.isEmpty) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          notice,
          Expanded(child: Center(child: Text('이번 로그인에서 등록한 평점이 없어요.'))),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        notice,
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.ratings.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final entry = viewModel.ratings[index];
              return _RatingCard(
                entry: entry,
                onEdit: () => _onEditPressed(context, entry),
                onDelete: () => _onDeletePressed(context, entry),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _onEditPressed(
    BuildContext context,
    RatingWithMovie entry,
  ) async {
    final viewModel = context.read<MyRatingsViewModel>();
    final rating = entry.rating;
    await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 저장 중 바깥 탭으로 닫히는 것도 막아요.
      builder: (_) => RatingDialog(
        movieTitle: entry.movie?.title ?? '영화 #${rating.movieId}',
        initialScore: rating.score,
        initialComment: rating.comment, // null이면 빈 칸으로 시작해요.
        onSubmit: (score, comment) async {
          try {
            await viewModel.updateRating(
              ratingId: rating.ratingId,
              score: score,
              comment: comment,
            );
          } on DioException catch (error) {
            // Dialog 안에 서버 문구(403·404 등)를 보여주도록 바꿔 던져요.
            throw StateError(writeErrorMessage(error));
          }
        },
      ),
    );
    // 성공하면 updateRating이 수정 결과로 목록 카드를 바로 바꿔요.
  }

  Future<void> _onDeletePressed(
    BuildContext context,
    RatingWithMovie entry,
  ) async {
    final viewModel = context.read<MyRatingsViewModel>();
    await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 삭제 중 바깥 탭으로 닫히는 것도 막아요.
      builder: (_) => _DeleteRatingDialog(
        onConfirm: () => viewModel.deleteRating(entry.rating.ratingId),
      ),
    );
    // 삭제에 성공하면 deleteRating이 목록에서 바로 빼요.
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final RatingWithMovie entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final rating = entry.rating;
    final movie = entry.movie; // null일 수 있어요
    final date = rating.createdAt.toLocal();
    final dateText =
        '${date.year}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.day.toString().padLeft(2, '0')}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          // posterPath가 null이면 TmdbPosterImage가 placeholder를 그려요
          child: TmdbPosterImage(
            posterPath: movie?.posterPath,
            width: 60,
            height: 90,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie?.title ?? '영화 #${rating.movieId}', // 영화 정보가 없으면 movieId
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                '★ ${rating.score}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.violet,
                ),
              ),
              if (rating.comment != null) ...[
                // comment가 null이면 숨김
                const SizedBox(height: 4),
                Text(rating.comment!, style: AppTextStyles.bodyMedium),
              ],
              const SizedBox(height: 4),
              Text(dateText, style: AppTextStyles.bodySmall),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // 카드 오른쪽의 개별 수정·삭제 버튼
        Column(
          children: [
            _CardActionButton(
              label: '수정',
              color: AppColors.violet,
              onPressed: onEdit,
            ),
            const SizedBox(height: 6),
            _CardActionButton(
              label: '삭제',
              color: AppColors.red,
              onPressed: onDelete,
            ),
          ],
        ),
      ],
    );
  }
}

class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        minimumSize: const Size(56, 32),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }
}

/// 삭제 확인 Dialog입니다. 삭제 요청이 끝날 때까지 닫히지 않아요.
class _DeleteRatingDialog extends StatefulWidget {
  const _DeleteRatingDialog({required this.onConfirm});
  final Future<void> Function() onConfirm;

  @override
  State<_DeleteRatingDialog> createState() => _DeleteRatingDialogState();
}

class _DeleteRatingDialogState extends State<_DeleteRatingDialog> {
  bool _isDeleting = false;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDeleting,
      child: AlertDialog(
        title: const Text('평점을 삭제할까요?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('삭제한 평점은 복구할 수 없습니다.'),
            if (_errorText != null) ...[
              const SizedBox(height: 8),
              Text(_errorText!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
        actions: [
          MovieLogButton(
            label: '취소',
            onPressed: _isDeleting ? null : () => Navigator.pop(context, false),
          ),
          MovieLogButton(
            label: '삭제',
            isLoading: _isDeleting,
            onPressed: _isDeleting ? null : _onConfirm,
          ),
        ],
      ),
    );
  }

  Future<void> _onConfirm() async {
    setState(() {
      _isDeleting = true;
      _errorText = null;
    });
    try {
      await widget.onConfirm();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isDeleting = false;
        _errorText = error is DioException
            ? writeErrorMessage(error) // 403·404 서버 문구
            : '삭제하지 못했습니다. 잠시 후 다시 시도해 주세요.';
      });
    }
  }
}
