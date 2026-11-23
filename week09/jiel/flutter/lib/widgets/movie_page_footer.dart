import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../view_models/load_phase.dart';
import '../view_models/paged_movies_view_model.dart';
import 'movielog_button.dart';

/// 영화 목록·검색 결과 아래에 붙는 footer.
///
/// - 다음 page가 있으면 "더 보기"
/// - 요청 중에는 기존 카드를 둔 채 버튼에 로딩 표시
/// - 실패하면 오류 문구와 "다음 페이지 다시 시도"(같은 page를 다시 요청)
/// - 마지막 page면 버튼을 숨기고 끝 문구
class MoviePageFooter extends StatelessWidget {
  const MoviePageFooter({super.key, required this.vm});

  final PagedMoviesViewModel vm;

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 14,
      height: 20 / 14,
      color: AppColors.onSurfaceVariant,
    );

    if (!vm.hasMore && !vm.isLoadingMore && vm.loadMoreError == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          '더 이상 조회할 페이지가 없습니다.',
          textAlign: TextAlign.center,
          style: textStyle,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (vm.loadMoreError != null) ...[
            Text(
              vm.loadMoreError!,
              textAlign: TextAlign.center,
              style: textStyle,
            ),
            const SizedBox(height: 12),
          ],
          MovieLogButton(
            width: double.infinity,
            label: vm.loadMoreError == null ? '더 보기' : '다음 페이지 다시 시도',
            isLoading: vm.isLoadingMore,
            onPressed: vm.phase == LoadPhase.ready ? vm.loadNextPage : null,
          ),
        ],
      ),
    );
  }
}
