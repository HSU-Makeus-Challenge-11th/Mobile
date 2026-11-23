import 'package:flutter/material.dart';

import '../../../theme/app_dimensions.dart';
import '../../../view_models/paged_movies_view_model.dart';

class MoviePageFooter extends StatelessWidget {
  const MoviePageFooter({super.key, required this.model});

  final PagedMoviesViewModel model;

  @override
  Widget build(BuildContext context) {
    if (!model.hasMore && !model.loadMoreFailed) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x2,
        0,
        AppSpacing.x2,
        AppSpacing.x3,
      ),
      child: FilledButton(
        key: const Key('movie-load-more-button'),
        onPressed: model.isLoadingMore ? null : model.loadMore,
        child: model.isLoadingMore
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(model.loadMoreFailed ? '다시 시도' : '더 보기'),
      ),
    );
  }
}
