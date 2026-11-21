import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/view_models/edit_profile_view_model.dart';
import 'package:movielog/widgets/auth/figma_text.dart';
import 'package:movielog/widgets/back_arrow_icon.dart';
import 'package:movielog/widgets/movielog_button.dart';
import 'package:provider/provider.dart';

/// 프로필 닉네임 수정·저장 중·중복 오류 (W8-07, W8-08, W8-09)
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _controller;

  static const _error = Color(0xFFB3261E);
  static const _maxLength = 12;

  @override
  void initState() {
    super.initState();
    final member = context.read<AuthViewModel>().member;
    _controller = TextEditingController(text: member?.nickname ?? '')
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final viewModel = context.read<EditProfileViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    FocusScope.of(context).unfocus();
    final success = await viewModel.save(_controller.text);
    if (!mounted) return;
    if (success) {
      messenger.showSnackBar(const SnackBar(content: Text('프로필을 수정했어요.')));
      // 저장 중에 막아 둔 PopScope가 풀린 다음 프레임에 닫는다
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      router.pop(); // 마이페이지에는 이미 새 닉네임이 반영되어 있다
    } else if (viewModel.message != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(viewModel.message!)));
    }
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color),
  );

  Widget _label(String text) => Text(
    text,
    strutStyle: w8Strut(14),
    style: w8Text(14, FontWeight.w600, AppColors.mutedText),
  );

  InputDecoration _decoration(Color fill, Color border, Color focused) =>
      InputDecoration(
        filled: true,
        fillColor: fill,
        isDense: true,
        counterText: '', // 글자 수는 프레임 위치에 직접 그린다
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: _border(border),
        enabledBorder: _border(border),
        disabledBorder: _border(border),
        focusedBorder: _border(focused),
      );

  @override
  Widget build(BuildContext context) {
    final email = context.select<AuthViewModel, String?>(
      (auth) => auth.member?.email,
    );
    final viewModel = context.watch<EditProfileViewModel>();
    final saving = viewModel.status == EditProfileStatus.saving;
    final error = viewModel.nicknameError;
    final length = _controller.text.trim().characters.length;

    return PopScope(
      canPop: !saving, // 저장 중에는 화면을 벗어나지 못한다
      child: Scaffold(
        backgroundColor: AppColors.surfaceBright,
        appBar: AppBar(
          toolbarHeight: 64,
          centerTitle: true,
          backgroundColor: AppColors.surfaceBright,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const BackArrowIcon(),
            onPressed: saving ? null : () => context.pop(),
          ),
          title: Text(
            '프로필 수정',
            strutStyle: w8Strut(20),
            style: w8Text(20, FontWeight.w700, AppColors.primary500),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 53.58, 24, 76),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _label('이메일 (변경할 수 없습니다)'),
                const SizedBox(height: 6.42),
                SizedBox(
                  height: 48,
                  child: TextFormField(
                    key: ValueKey('profileEmailField_$email'),
                    initialValue: email ?? '',
                    enabled: false, // email은 읽기 전용이다
                    style: w8Text(14, FontWeight.w500, AppColors.mutedText),
                    decoration: _decoration(
                      const Color(0xFFF0EDF2),
                      AppColors.cardBorder,
                      AppColors.cardBorder,
                    ),
                  ),
                ),
                const SizedBox(height: 38.58),
                _label('닉네임'),
                const SizedBox(height: 6.42),
                SizedBox(
                  height: 48,
                  child: TextField(
                    key: const Key('profileNicknameField'),
                    controller: _controller,
                    enabled: !saving,
                    maxLength: _maxLength,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => saving ? null : _submit(),
                    style: w8Text(14, FontWeight.w500, AppColors.ink),
                    decoration: _decoration(
                      AppColors.white,
                      error == null ? AppColors.cardBorder : _error,
                      error == null ? AppColors.primary500 : _error,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                  child: Stack(
                    children: [
                      if (error != null)
                        Positioned(
                          top: 8.64,
                          left: 0,
                          right: 48,
                          child: Text(
                            error,
                            strutStyle: w8Strut(12),
                            style: w8Text(12, FontWeight.w500, _error),
                          ),
                        ),
                      Positioned(
                        top: 14.64,
                        right: 1,
                        child: Text(
                          '$length / $_maxLength',
                          strutStyle: w8Strut(12),
                          style: w8Text(
                            12,
                            FontWeight.w500,
                            AppColors.mutedText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                MovieLogButton(
                  key: const Key('saveProfileButton'),
                  label: '저장',
                  width: double.infinity,
                  isLoading: saving,
                  labelStyle: w8Text(14, FontWeight.w700, AppColors.white),
                  onPressed: saving ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
