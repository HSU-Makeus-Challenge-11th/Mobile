import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/data/models/member_info.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/widgets/auth/figma_text.dart';
import 'package:provider/provider.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/widgets/profile/favorite_genres.dart';
import 'package:movielog/widgets/profile/my_ratings_entry.dart';
import 'package:movielog/widgets/profile/profile_header.dart';
import 'package:movielog/widgets/profile/profile_stats.dart';

/// 내 프로필 화면 (W8-06). 닉네임·이메일은 GET me 결과를 구독한다
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceBright,
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 64,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '내 프로필',
                        strutStyle: w8Strut(22),
                        style: w8Text(
                          22,
                          FontWeight.w700,
                          AppColors.primary500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      key: const Key('logoutButton'),
                      behavior: HitTestBehavior.opaque,
                      // 토큰과 내 정보를 지우면 Router가 /login으로 보낸다
                      onTap: () => context.read<AuthViewModel>().logout(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          '로그아웃',
                          strutStyle: w8Strut(13),
                          style: w8Text(
                            13,
                            FontWeight.w700,
                            AppColors.primary500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Expanded(child: ProfileBody()),
          ],
        ),
      ),
    );
  }
}

/// AppBar 아래 본문. 섹션 사이 간격은 W8-06 프레임 값을 따른다.
class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key});

  /// 사진·통계·장르는 디자인 예시다. v8 GET me는 이메일·닉네임·가입일만 준다
  static const _stats = [
    ProfileStat(label: '본 영화', value: '342'),
    ProfileStat(label: '평점', value: '4.2'),
    ProfileStat(label: '즐겨찾기', value: '58'),
  ];

  static const _genres = ['드라마', 'SF', '애니메이션'];

  @override
  Widget build(BuildContext context) {
    final member = context.select<AuthViewModel, MemberInfo?>(
      (auth) => auth.member,
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 25, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileHeader(
            name: member?.nickname ?? '',
            email: member?.email ?? '',
            imagePath: 'assets/images/profile.jpg',
            onEdit: member == null
                ? null
                : () => context.push('/my/profile/edit'),
          ),
          const SizedBox(height: 33),
          const ProfileStats(stats: _stats),
          const SizedBox(height: 26),
          const MyRatingsEntry(),
          const SizedBox(height: 27.49),
          const FavoriteGenres(genres: _genres),
        ],
      ),
    );
  }
}
