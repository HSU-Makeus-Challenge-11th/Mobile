import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../view_models/my_ratings_view_model.dart';
import '../../widgets/common_app_bar.dart';
import '../../widgets/movie_log_button.dart';
import 'widgets/my_rating_card.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key, required this.viewModel});

  static const routeName = '/my/ratings';
  static const memberId = 999;

  final MyRatingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: '내가 등록한 평점',
        centerTitle: true,
        onBack: () {
          if (GoRouter.maybeOf(context) != null) {
            context.pop();
          } else {
            Navigator.maybePop(context);
          }
        },
      ),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: viewModel,
          builder: (context, _) => _MyRatingsBody(viewModel: viewModel),
        ),
      ),
    );
  }
}

class _MyRatingsBody extends StatelessWidget {
  const _MyRatingsBody({required this.viewModel});

  final MyRatingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return switch (viewModel.status) {
      MyRatingsStatus.idle || MyRatingsStatus.loading => const Center(
        child: CircularProgressIndicator(
          key: Key('my-ratings-loading'),
          color: AppColors.primary,
        ),
      ),
      MyRatingsStatus.empty => const _EmptyState(),
      MyRatingsStatus.error => _ErrorState(
        onRetry: () {
          viewModel.load(memberId: MyRatingsScreen.memberId);
        },
      ),
      MyRatingsStatus.success => ListView.separated(
        key: const Key('my-ratings-list'),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.x2,
          AppSpacing.x3,
          AppSpacing.x2,
          AppSpacing.x4,
        ),
        itemCount: viewModel.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.x2),
        itemBuilder: (context, index) {
          return MyRatingCard(item: viewModel.items[index]);
        },
      ),
    };
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      key: Key('my-ratings-empty'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_border_rounded, size: 52, color: AppColors.gray),
          SizedBox(height: AppSpacing.x2),
          Text('아직 등록한 평점이 없어요.'),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('my-ratings-error'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 52, color: AppColors.error),
          const SizedBox(height: AppSpacing.x2),
          const Text(
            '평점 목록을 불러오지 못했어요.\n잠시 후 다시 시도해주세요.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.x2),
          MovieLogButton(
            key: const Key('my-ratings-retry-button'),
            label: '다시 시도',
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
