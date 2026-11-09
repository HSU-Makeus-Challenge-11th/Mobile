import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/services/api_error_message.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../view_models/my_ratings_view_model.dart';
import '../../widgets/common_app_bar.dart';
import '../../widgets/movie_log_button.dart';
import '../movies/rating_dialog.dart';
import 'widgets/my_rating_card.dart';

class MyRatingsScreen extends StatefulWidget {
  const MyRatingsScreen({super.key, required this.viewModel});

  static const routeName = '/my/ratings';
  final MyRatingsViewModel viewModel;

  @override
  State<MyRatingsScreen> createState() => _MyRatingsScreenState();
}

class _MyRatingsScreenState extends State<MyRatingsScreen> {
  MyRatingsViewModel get viewModel => widget.viewModel;

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _edit(MyRatingItem item) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RatingDialog(
        isEditing: true,
        initialScore: item.rating.score,
        initialComment: item.rating.comment,
        onSubmit: (score, comment) => viewModel.updateRating(
          ratingId: item.rating.ratingId,
          score: score,
          comment: comment,
        ),
      ),
    );
    if (saved == true) {
      _showMessage(viewModel.refreshWarning ?? '평점을 수정했습니다.');
    }
  }

  Future<void> _deleteOne(MyRatingItem item) async {
    final deleted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DeleteConfirmDialog(
        onDelete: () => viewModel.deleteRating(item.rating.ratingId),
      ),
    );
    if (deleted == true) {
      _showMessage(viewModel.refreshWarning ?? '평점을 삭제했습니다.');
    }
  }

  Future<void> _deleteSelected() async {
    if (viewModel.selectedRatingIds.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _DeleteConfirmDialog(),
    );
    if (confirmed != true || !mounted) return;
    final failed = await viewModel.deleteSelectedRatings();
    if (!mounted) return;
    _showMessage(
      viewModel.message ??
          viewModel.refreshWarning ??
          (failed == 0 ? '선택한 평점을 삭제했습니다.' : '$failed개 항목을 삭제하지 못했습니다.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) => PopScope(
        canPop: !viewModel.isDeletingSelected,
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.screenBackground,
              appBar: CommonAppBar(
                title: '내가 등록한 평점',
                centerTitle: true,
                titleStyle: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
                onBack: () {
                  if (viewModel.isDeletingSelected) return;
                  if (GoRouter.maybeOf(context) != null) {
                    context.pop();
                  } else {
                    Navigator.maybePop(context);
                  }
                },
              ),
              body: SafeArea(
                top: false,
                child: Column(
                  children: [
                    if (viewModel.status == MyRatingsStatus.success) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                        child: Row(
                          children: [
                            if (viewModel.isEditing)
                              Text(
                                '${viewModel.selectedRatingIds.length}개 선택됨',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            const Spacer(),
                            TextButton(
                              key: const Key('ratings-edit-mode-button'),
                              onPressed: viewModel.toggleEditing,
                              child: Text(viewModel.isEditing ? '취소' : '편집'),
                            ),
                          ],
                        ),
                      ),
                    ],
                    Expanded(child: _body()),
                    if (viewModel.isEditing &&
                        viewModel.status == MyRatingsStatus.success)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                        child: MovieLogButton(
                          label:
                              '선택한 ${viewModel.selectedRatingIds.length}개 삭제',
                          width: double.infinity,
                          height: 48,
                          onPressed: viewModel.selectedRatingIds.isEmpty
                              ? null
                              : _deleteSelected,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (viewModel.isDeletingSelected) ...[
              const Positioned.fill(
                child: ModalBarrier(dismissible: false, color: Colors.black45),
              ),
              const Center(
                child: CircularProgressIndicator(color: AppColors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _body() => switch (viewModel.status) {
    MyRatingsStatus.idle || MyRatingsStatus.loading => const Center(
      child: CircularProgressIndicator(
        key: Key('my-ratings-loading'),
        color: AppColors.primary,
      ),
    ),
    MyRatingsStatus.empty => const Center(
      key: Key('my-ratings-empty'),
      child: Text('아직 등록한 평점이 없어요.'),
    ),
    MyRatingsStatus.error => Center(
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
            onPressed: () => viewModel.load(),
          ),
        ],
      ),
    ),
    MyRatingsStatus.success => ListView.separated(
      key: const Key('my-ratings-list'),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemCount: viewModel.items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = viewModel.items[index];
        return MyRatingCard(
          item: item,
          isEditing: viewModel.isEditing,
          isSelected: viewModel.selectedRatingIds.contains(
            item.rating.ratingId,
          ),
          onSelected: (_) => viewModel.toggleSelection(item.rating.ratingId),
          onEdit: () => _edit(item),
          onDelete: () => _deleteOne(item),
        );
      },
    ),
  };
}

class _DeleteConfirmDialog extends StatefulWidget {
  const _DeleteConfirmDialog({this.onDelete});

  final Future<void> Function()? onDelete;

  @override
  State<_DeleteConfirmDialog> createState() => _DeleteConfirmDialogState();
}

class _DeleteConfirmDialogState extends State<_DeleteConfirmDialog> {
  bool _deleting = false;
  String? _error;

  Future<void> _confirm() async {
    if (_deleting) return;
    if (widget.onDelete == null) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() => _deleting = true);
    try {
      await widget.onDelete!();
      if (mounted) Navigator.of(context).pop(true);
    } on DioException catch (error) {
      if (mounted) setState(() => _error = apiErrorMessage(error));
    } catch (_) {
      if (mounted) setState(() => _error = '평점을 삭제하지 못했습니다. 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_deleting,
    child: Dialog(
      key: const Key('delete-rating-dialog'),
      backgroundColor: AppColors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 31),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '평점을 삭제할까요?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: Color(0xFF25232A),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '삭제한 평점은 복구할 수 없습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF655F6C)),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error),
              ),
            ],
            const SizedBox(height: 34),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _deleting
                        ? null
                        : () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF0EAF8),
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MovieLogButton(
                    label: '삭제',
                    buttonKey: const Key('confirm-delete-rating-button'),
                    onPressed: _confirm,
                    isLoading: _deleting,
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
