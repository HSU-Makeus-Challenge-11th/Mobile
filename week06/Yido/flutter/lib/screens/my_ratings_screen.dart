import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';
import 'package:movielog/view_models/my_ratings_view_model.dart';
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
      appBar: AppBar(
        toolbarHeight: 64,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: GestureDetector(
          onLongPress: () => _pickDebugMode(context),
          child: Text(
            '내가 등록한 평점',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.primary500,
            ),
          ),
        ),
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

  @override
  Widget build(BuildContext context) {
    final message = viewModel.message;
    return ListView(
      padding: const EdgeInsets.fromLTRB(19, 31, 19, 24),
      children: [
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(message, style: AppTextStyles.labelMedium),
          ),
        for (final (index, entry) in viewModel.ratings.indexed) ...[
          if (index > 0) const SizedBox(height: 16),
          MyRatingCard(entry: entry),
        ],
      ],
    );
  }
}
