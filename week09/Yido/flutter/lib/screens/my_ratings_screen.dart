import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/data/models/rating_dto.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';
import 'package:movielog/view_models/my_ratings_view_model.dart';
import 'package:movielog/widgets/back_arrow_icon.dart';
import 'package:movielog/widgets/movies/rating_dialog.dart';
import 'package:movielog/widgets/ratings/delete_rating_dialog.dart';
import 'package:movielog/widgets/ratings/my_rating_card.dart';
import 'package:movielog/widgets/ratings/my_ratings_states.dart';
import 'package:provider/provider.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

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
      body: Consumer<MyRatingsViewModel>(
        builder: (context, viewModel, child) {
          return switch (viewModel.status) {
            MyRatingsLoadStatus.idle ||
            MyRatingsLoadStatus.loading => const MyRatingsLoading(),
            MyRatingsLoadStatus.error => MyRatingsError(
              message: viewModel.message,
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
        // 평점 수정은 체크박스 없이 기존 PATCH를 그대로 쓴다
        onSubmit: (score, comment, _) => viewModel.updateRating(
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
            onEdit: () => _onEdit(context, entry.rating),
            onDelete: () => _onDelete(context, entry.rating),
          ),
        ],
      ],
    );
  }
}

final _titleStyle = AppTextStyles.titleLarge.copyWith(
  fontSize: 20,
  height: 27 / 20,
  fontWeight: FontWeight.w700,
  color: AppColors.primary500,
);
