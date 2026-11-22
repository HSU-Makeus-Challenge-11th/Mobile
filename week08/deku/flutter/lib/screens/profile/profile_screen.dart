import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/member_info.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../view_models/auth_view_model.dart';
import '../../widgets/common_app_bar.dart';
import 'widgets/edit_profile_button.dart';
import 'widgets/favorite_genres.dart';
import 'widgets/my_ratings_entry.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_stats.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const routeName = '/my';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: CommonAppBar(
        title: '내 프로필',
        actions: [
          TextButton(
            key: const Key('logout-button'),
            onPressed: auth.logout,
            child: const Text('로그아웃'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: switch (auth.memberStatus) {
          MemberLoadStatus.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          MemberLoadStatus.error => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('내 정보를 불러오지 못했어요.'),
                const SizedBox(height: 16),
                FilledButton(
                  key: const Key('member-retry-button'),
                  onPressed: () => auth.loadMember(force: true),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
          _ when auth.member != null => ProfileBody(member: auth.member!),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key, required this.member});

  final MemberInfo member;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x3,
        AppSpacing.x3,
        AppSpacing.x3,
        AppSpacing.x4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileHeader(member: member),
          const EditProfileButton(),
          const ProfileStats(),
          const SizedBox(height: AppSpacing.x3),
          const FavoriteGenres(),
          const MyRatingsEntry(),
        ],
      ),
    );
  }
}
