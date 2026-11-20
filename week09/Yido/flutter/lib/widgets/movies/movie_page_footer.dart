import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/view_models/load_phase.dart';
import 'package:movielog/view_models/paged_movies_view_model.dart';
import 'package:movielog/widgets/auth/figma_text.dart';
import 'package:movielog/widgets/movielog_button.dart';

/// W9 목록 아래: 더 보기 / 추가 로딩 / 다음 페이지 다시 시도 / 마지막 페이지
class MoviePageFooter extends StatelessWidget {
  const MoviePageFooter({
    super.key,
    required this.vm,
    this.moreLabel = '더 보기',
    this.endLabel = '모든 영화를 확인했습니다.',
  });

  final PagedMoviesViewModel vm;
  final String moreLabel;
  final String endLabel;

  static final _message = w8Text(
    14,
    FontWeight.w400,
    AppColors.mutedText,
  ).copyWith(height: 19 / 14);

  @override
  Widget build(BuildContext context) {
    if (!vm.hasMore && !vm.isLoadingMore && vm.loadMoreError == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 19),
        child: Text(
          endLabel,
          key: const Key('pageEndText'),
          textAlign: TextAlign.center,
          style: _message,
        ),
      );
    }
    final error = vm.loadMoreError;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (error != null) ...[
          Text(error, textAlign: TextAlign.center, style: _message),
          const SizedBox(height: 19),
        ],
        MovieLogButton(
          key: const Key('loadMoreButton'),
          width: double.infinity,
          label: error == null ? moreLabel : '다음 페이지 다시 시도',
          labelStyle: w8Text(
            14,
            FontWeight.w700,
            AppColors.white,
          ).copyWith(height: 19 / 14),
          isLoading: vm.isLoadingMore,
          onPressed: vm.phase == LoadPhase.ready ? vm.loadNextPage : null,
        ),
      ],
    );
  }
}
