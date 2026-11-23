import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../theme/app_colors.dart';
import '../../../view_models/favorite_detail_view_model.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<FavoriteDetailViewModel>();
    return IconButton(
      key: const Key('favorite-button'),
      tooltip: !model.stateKnown
          ? '즐겨찾기 상태 다시 확인'
          : model.isFavorite
          ? '즐겨찾기 해제'
          : '즐겨찾기 등록',
      onPressed: model.isLoading || model.isSaving
          ? null
          : !model.stateKnown
          ? model.load
          : () async {
              final message = await context
                  .read<FavoriteDetailViewModel>()
                  .toggle();
              if (!context.mounted || message == null) return;
              final messenger = ScaffoldMessenger.of(context);
              messenger.hideCurrentSnackBar();
              messenger.showSnackBar(SnackBar(content: Text(message)));
            },
      icon: model.isLoading || model.isSaving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              !model.stateKnown
                  ? Icons.refresh
                  : model.isFavorite
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              color: AppColors.primary,
            ),
    );
  }
}
