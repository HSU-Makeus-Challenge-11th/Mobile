import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/widgets/profile/favorite_genres.dart';
import 'package:movielog/widgets/profile/my_ratings_entry.dart';
import 'package:movielog/widgets/profile/profile_header.dart';
import 'package:movielog/widgets/profile/profile_stats.dart';

/// 내 프로필 화면 (W1-01).
/// 1주차에는 정적인 화면이므로 StatelessWidget으로 만든다.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.surfaceBright,
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 64,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(
                    '내 프로필',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 22,
                      height: 30 / 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary500,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: ProfileBody()),
          ],
        ),
      ),
    );
  }
}

/// AppBar 아래 본문. 섹션 사이 간격은 W6-ENTRY 프레임 값을 따른다.
class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key});

  static const _stats = [
    ProfileStat(label: '본 영화', value: '342'),
    ProfileStat(label: '평점', value: '4.2'),
    ProfileStat(label: '즐겨찾기', value: '58'),
  ];

  static const _genres = ['드라마', 'SF', '애니메이션'];

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 25, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileHeader(
            name: '무비러버',
            bio: '매주 주말엔 영화관으로 출근하는 프로 관람객.\n좋은 영화를 보고 기록하는 것을 좋아합니다.',
            imagePath: 'assets/images/profile.jpg',
          ),
          SizedBox(height: 33),
          ProfileStats(stats: _stats),
          SizedBox(height: 26),
          MyRatingsEntry(),
          SizedBox(height: 28),
          FavoriteGenres(genres: _genres),
        ],
      ),
    );
  }
}
