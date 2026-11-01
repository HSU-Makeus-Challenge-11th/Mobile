import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/data/models/rating_dto.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';
import 'package:movielog/view_models/my_ratings_view_model.dart';
import 'package:movielog/widgets/back_arrow_icon.dart';
import 'package:movielog/widgets/movielog_button.dart';
import 'package:movielog/widgets/movies/rating_dialog.dart';
import 'package:movielog/widgets/ratings/delete_rating_dialog.dart';
import 'package:movielog/widgets/ratings/my_rating_card.dart';
import 'package:movielog/widgets/ratings/my_ratings_states.dart';
import 'package:provider/provider.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  /// 상태별 화면 확인용: 디버그 모드에서 제목을 길게 누르면 조회 모드를 고른다
  Future<void> _pickDebugMode(BuildContext context) async {
    if (!kDebugMode) return;
    final viewModel = context.read<MyRatingsViewModel>();
    final mode = await showModalBottomSheet<MyRatingsDebugMode>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (mode, label) in const [
              (MyRatingsDebugMode.normal, '정상'),
              (MyRatingsDebugMode.empty, '빈 목록'),
              (MyRatingsDebugMode.failure, '실패'),
            ])
              ListTile(
                title: Text(label),
                trailing: mode == viewModel.debugMode
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.of(context).pop(mode),
              ),
          ],
        ),
      ),
    );
    if (mode == null || !context.mounted) return;
    viewModel.changeDebugMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBright,
      appBar: AppBar(
        toolbarHeight: 64,
        centerTitle: true,
        backgroundColor: AppColors.surfaceBright,
        leading: IconButton(
          icon: const BackArrowIcon(),
          onPressed: () => context.pop(),
        ),
        title: GestureDetector(
          onLongPress: () => _pickDebugMode(context),
          child: Text('내가 등록한 평점', style: _titleStyle),
        ),
      ),
      body: Consumer<MyRatingsViewModel>(
        builder: (context, viewModel, child) {
          return switch (viewModel.status) {
            MyRatingsLoadStatus.idle ||
            MyRatingsLoadStatus.loading => const MyRatingsLoading(),
            MyRatingsLoadStatus.error => MyRatingsError(
              message: viewModel.refreshWarning ?? viewModel.message,
              onRetry: viewModel.retry,
            ),
            MyRatingsLoadStatus.empty => const MyRatingsEmpty(),
            MyRatingsLoadStatus.success => _RatingList(viewModel: viewModel),
          };
        },
      ),
    );
  }
}

class _RatingList extends StatelessWidget {
  const _RatingList({required this.viewModel});

  final MyRatingsViewModel viewModel;

  Future<void> _onEdit(BuildContext context, RatingDto rating) async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: false, // 저장 중 바깥 탭으로 닫히는 것도 막는다
      barrierColor: ratingDialogBarrierColor,
      builder: (_) => RatingDialog(
        initialScore: rating.score,
        initialComment: rating.comment,
        onSubmit: (score, comment) => viewModel.updateRating(
          ratingId: rating.ratingId,
          score: score,
          comment: comment,
        ),
      ),
    );
  }

  Future<void> _onDelete(BuildContext context, RatingDto rating) async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: deleteRatingBarrierColor,
      builder: (_) => DeleteRatingDialog(
        onConfirm: () => viewModel.deleteRating(rating.ratingId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final message = viewModel.message;
    // 상태 확인용으로 다른 회원을 볼 때는 수정·삭제 버튼을 보여 주지 않는다
    final isOwner = viewModel.debugMode == MyRatingsDebugMode.normal;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      children: [
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(message, style: AppTextStyles.labelMedium),
          ),
        for (final (index, entry) in viewModel.ratings.indexed) ...[
          if (index > 0) const SizedBox(height: 18),
          MyRatingCard(
            entry: entry,
            onEdit: isOwner ? () => _onEdit(context, entry.rating) : null,
            onDelete: isOwner ? () => _onDelete(context, entry.rating) : null,
          ),
        ],
      ],
    );
  }
}

/// 회원가입 전에는 조회할 memberId가 없다
class MemberRequiredScreen extends StatelessWidget {
  const MemberRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBright,
      appBar: AppBar(
        toolbarHeight: 64,
        centerTitle: true,
        backgroundColor: AppColors.surfaceBright,
        leading: IconButton(
          icon: const BackArrowIcon(),
          onPressed: () => context.pop(),
        ),
        title: Text('내가 등록한 평점', style: _titleStyle),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            const Text('학습용 회원가입이 필요합니다.', style: AppTextStyles.bodyMedium),
            MovieLogButton(
              label: '회원가입',
              width: 120,
              horizontalPadding: 0,
              onPressed: () => context.push('/register'),
            ),
          ],
        ),
      ),
    );
  }
}

final _titleStyle = AppTextStyles.titleLarge.copyWith(
  fontSize: 20,
  height: 27 / 20,
  fontWeight: FontWeight.w700,
  color: AppColors.primary500,
);
