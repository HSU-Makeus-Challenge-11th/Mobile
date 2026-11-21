import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/view_models/favorite_detail_view_model.dart';
import 'package:movielog/widgets/auth/figma_text.dart';
import 'package:movielog/widgets/favorites/bookmark_icon.dart';
import 'package:provider/provider.dart';

/// W9 상세 즐겨찾기 버튼: 62x72 상자 안의 북마크와 아래 "즐겨찾기" 라벨
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key});

  /// 3주차처럼 결과를 Snackbar로 알린다. 문구는 서버 요청 결과를 따른다
  Future<void> _toggle(BuildContext context, FavoriteDetailViewModel vm) async {
    final messenger = ScaffoldMessenger.of(context);
    await vm.toggle();
    if (!context.mounted) return;
    final message =
        vm.errorMessage ?? (vm.isFavorite ? '즐겨찾기에 추가했습니다.' : '즐겨찾기에서 삭제했습니다.');
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FavoriteDetailViewModel>();
    final busy = vm.isLoading || vm.isSaving;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: vm.isFavorite ? '즐겨찾기 해제' : '즐겨찾기 등록',
          child: Material(
            color: AppColors.surfaceBright,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: const Key('favoriteButton'),
              // 첫 여부 조회가 끝나기 전과 요청 중에는 누를 수 없다
              onTap: busy || !vm.hasLoadedStatus
                  ? null
                  : () => _toggle(context, vm),
              child: SizedBox(
                width: 62,
                height: 72,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: busy ? 19 : 17),
                    child: busy
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary500,
                            ),
                          )
                        : BookmarkIcon(filled: vm.isFavorite),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '즐겨찾기',
          strutStyle: const StrutStyle(fontSize: 11, height: 15 / 11),
          style: w8Text(
            11,
            FontWeight.w700,
            AppColors.primary500,
          ).copyWith(height: 15 / 11),
        ),
        // 첫 여부 조회에 실패했을 때만 다시 확인할 수 있게 한다
        if (!vm.hasLoadedStatus && !vm.isLoading)
          GestureDetector(
            key: const Key('favoriteRetryButton'),
            onTap: vm.load,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '다시 확인',
                style: w8Text(11, FontWeight.w700, AppColors.primary500),
              ),
            ),
          ),
      ],
    );
  }
}

/// W9 실패 프레임: 이전 상태를 유지한 채 아래에 오류 상자를 보여 준다
class FavoriteErrorBox extends StatelessWidget {
  const FavoriteErrorBox({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    constraints: const BoxConstraints(minHeight: 58),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF1EF),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      message,
      style: w8Text(
        13,
        FontWeight.w400,
        AppColors.error,
      ).copyWith(height: 18 / 13),
    ),
  );
}
