import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/data/models/member_info.dart';
import 'package:movielog/view_models/auth_view_model.dart';
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
    // member가 바뀔 때만 다시 그립니다(닉네임 수정 후 바로 반영).
    final member = context.select<AuthViewModel, MemberInfo?>(
      (auth) => auth.member,
    );

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
                nickname: member?.nickname ?? '내 정보를 불러오는 중이에요',
                email: member?.email ?? '',
              ),
              const SizedBox(height: 24),
              const EditProfileButton(),
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
