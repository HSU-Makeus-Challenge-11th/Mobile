import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/view_models/favorite_detail_view_model.dart';
import 'package:provider/provider.dart';

/// 영화 상세의 제목 오른쪽에 두는 북마크 버튼입니다.
/// 상위 Route에서 FavoriteDetailViewModel을 제공해야 합니다.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key});

  static const double _width = 62;

  /// 서버 결과를 받은 뒤 Snackbar로 안내합니다.
  Future<void> _toggle(BuildContext context, FavoriteDetailViewModel vm) async {
    final before = vm.isFavorite;
    await vm.toggle();
    if (!context.mounted || vm.isDisposed) return;

    // 요청이 무시되어 아무것도 바뀌지 않았으면 안내하지 않습니다.
    final error = vm.errorMessage;
    if (error == null && vm.isFavorite == before) return;

    final message =
        error ?? (vm.isFavorite ? '즐겨찾기에 추가했습니다.' : '즐겨찾기에서 삭제했습니다.');
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteDetailViewModel>(
      builder: (context, vm, _) {
        // 첫 여부 조회에 실패했을 때만 새로고침 버튼을 보여 줍니다.
        final loadFailed =
            !vm.hasLoadedStatus && !vm.isLoading && vm.errorMessage != null;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: _width,
              height: 48,
              child: vm.isLoading || vm.isSaving
                  ? const Center(
                      child: SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.violet,
                        ),
                      ),
                    )
                  : loadFailed
                  ? IconButton(
                      tooltip: '즐겨찾기 여부 다시 확인',
                      color: AppColors.violet,
                      onPressed: vm.load,
                      icon: const Icon(Icons.refresh),
                    )
                  : IconButton(
                      tooltip: vm.isFavorite ? '즐겨찾기 해제' : '즐겨찾기 추가',
                      color: AppColors.violet,
                      onPressed: vm.hasLoadedStatus
                          ? () => _toggle(context, vm)
                          : null,
                      icon: Icon(
                        vm.isFavorite ? Icons.bookmark : Icons.bookmark_border,
                        size: 28,
                      ),
                    ),
            ),
            Text(
              loadFailed ? '다시 확인' : '즐겨찾기',
              style: const TextStyle(fontSize: 12, color: AppColors.violet),
            ),
          ],
        );
      },
    );
  }
}
