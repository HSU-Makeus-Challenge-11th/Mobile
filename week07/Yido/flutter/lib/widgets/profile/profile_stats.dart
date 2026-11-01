import 'package:flutter/material.dart';
import 'package:movielog/widgets/profile/stat_item.dart';

/// 통계 한 칸에 들어갈 데이터.
class ProfileStat {
  const ProfileStat({required this.label, required this.value});

  final String label;
  final String value;
}

/// 통계 카드를 가로로 같은 너비로 나눠 배치한다.
class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key, required this.stats});

  final List<ProfileStat> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: stats
          .map(
            (stat) => Expanded(
              child: StatItem(label: stat.label, value: stat.value),
            ),
          )
          .toList(),
    );
  }
}
