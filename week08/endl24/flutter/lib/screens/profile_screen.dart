import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/data/models/member_info.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/widgets/movielog_button.dart';
import 'package:provider/provider.dart';

import '../widgets/common_app_bar.dart';
import '../widgets/edit_profile_button.dart';
import '../widgets/favorite_genres.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 내 정보와 그 로딩 상태가 바뀔 때만 다시 그립니다(닉네임 수정 후 바로 반영).
    final (member, memberStatus) = context
        .select<AuthViewModel, (MemberInfo?, MemberLoadStatus)>(
          (auth) => (auth.member, auth.memberStatus),
        );

    // MainScreen이 시작한 내 정보 로딩이 끝나기 전·실패했을 때는 화면 전체를 상태 화면으로 바꿉니다.
    if (member == null) {
      return Scaffold(
        appBar: const CommonAppBar(title: '내 프로필'),
        body: Center(
          child: memberStatus == MemberLoadStatus.error
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '내 정보를 불러오지 못했어요.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grayDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    MovieLogButton(
                      label: '다시 시도',
                      width: 180,
                      onPressed: () =>
                          context.read<AuthViewModel>().loadMember(force: true),
                    ),
                  ],
                )
              : const CircularProgressIndicator(color: AppColors.violet),
        ),
      );
    }

    return Scaffold(
      appBar: CommonAppBar(
        title: '내 프로필',
        actions: [
          TextButton(
            // 토큰과 내 정보를 지우면 Router가 /login으로 보냅니다.
            onPressed: () => context.read<AuthViewModel>().logout(),
            child: const Text('로그아웃'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileHeader(
                nickname: member.nickname,
                email: member.email,
                joinedAt: member.createdAt,
              ),
              const SizedBox(height: 24),
              EditProfileButton(
                onPressed: () => context.push('/my/profile/edit'),
              ),
              const SizedBox(height: 24),
              const ProfileStats(),
              const SizedBox(height: 24),
              const FavoriteGenres(genres: ['드라마', 'SF', '애니메이션']),
              const SizedBox(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('내가 등록한 평점'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/my/ratings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
