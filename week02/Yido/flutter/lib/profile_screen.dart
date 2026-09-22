import 'package:flutter/material.dart';
import 'package:movielog/widgets/common_app_bar.dart';
import 'package:movielog/widgets/profile/favorite_genres.dart';
import 'package:movielog/widgets/profile/profile_header.dart';
import 'package:movielog/widgets/profile/profile_stats.dart';

/// 내 프로필 화면 (W1-01).
/// 1주차에는 정적인 화면이므로 StatelessWidget으로 만든다.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CommonAppBar(title: '내 프로필'),
      body: SafeArea(child: ProfileBody()),
    );
  }
}

/// AppBar 아래 본문. 섹션 사이 간격은 32로 맞춘다.
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
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 32,
        children: [
          ProfileHeader(
            name: '무비러버',
            // 한글은 글자 단위로 줄바꿈되므로 의미 단위로 직접 끊는다.
            bio: '매주 주말엔 영화관으로 출근하는 프로 관람객.\n좋은 영화를 보고 기록하는 것을 좋아합니다.',
            imagePath: 'assets/images/profile.jpg',
          ),
          ProfileStats(stats: _stats),
          FavoriteGenres(genres: _genres),
        ],
      ),
    );
  }
}
