import 'package:flutter/material.dart';

import '../../../theme/app_dimensions.dart';
import 'stat_item.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key});

  static const _stats = [
    (label: '본 영화', value: '342'),
    (label: '평점', value: '4.2'),
    (label: '즐겨찾기', value: '58'),
  ];

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < _stats.length; index++) ...[
            if (index > 0) const SizedBox(width: AppSpacing.x1),
            Expanded(
              child: StatItem(
                label: _stats[index].label,
                value: _stats[index].value,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
