import 'package:flutter/material.dart';

import '../../theme/app_dimensions.dart';
import '../../widgets/common_app_bar.dart';
import 'widgets/edit_profile_button.dart';
import 'widgets/favorite_genres.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_stats.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CommonAppBar(title: '내 프로필'),
      body: SafeArea(top: false, child: ProfileBody()),
    );
  }
}

class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x2,
        AppSpacing.x4,
        AppSpacing.x2,
        AppSpacing.x4,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileHeader(),
          EditProfileButton(),
          ProfileStats(),
          SizedBox(height: AppSpacing.x4_5),
          FavoriteGenres(),
        ],
      ),
    );
  }
}
