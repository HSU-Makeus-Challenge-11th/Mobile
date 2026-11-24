import 'package:flutter/material.dart';

import 'stat_item.dart';

/// '본 영화 / 평점 / 즐겨찾기' 통계 카드 3개를 가로로 배치한다.
///
/// 각 카드는 [StatItem]을 재사용하고, [Expanded]로 감싸 세 카드가
/// 화면 폭을 균등하게 나눠 갖도록 한다 (Row의 교차축은 기본 center).
class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: StatItem(label: '본 영화', value: '342'),
        ),
        SizedBox(width: 12),
        Expanded(
          child: StatItem(label: '평점', value: '4.2'),
        ),
        SizedBox(width: 12),
        Expanded(
          child: StatItem(label: '즐겨찾기', value: '58'),
        ),
      ],
    );
  }
}
