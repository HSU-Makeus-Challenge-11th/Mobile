import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/theme/app_text_styles.dart';
import 'package:movielog/view_models/auth_view_model.dart';
import 'package:movielog/view_models/edit_profile_view_model.dart';
import 'package:movielog/widgets/common_app_bar.dart';
import 'package:movielog/widgets/movielog_button.dart';
import 'package:provider/provider.dart';

/// 이메일은 읽기 전용, 닉네임만 수정하는 화면입니다.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final member = context.read<AuthViewModel>().member;
    _controller = TextEditingController(text: member?.nickname ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final viewModel = context.read<EditProfileViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final success = await viewModel.save(_controller.text);
    if (!mounted) return;

    if (success) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('프로필을 수정했어요.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      router.pop(); // 마이페이지에는 새 닉네임이 이미 반영되어 있습니다.
    } else if (viewModel.message != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(viewModel.message!),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = context.select<AuthViewModel, String?>(
      (auth) => auth.member?.email,
    );

    return Consumer<EditProfileViewModel>(
      builder: (context, viewModel, child) {
        final saving = viewModel.status == EditProfileStatus.saving;
        return PopScope(
          canPop: !saving, // 저장 중에는 뒤로가기를 막습니다.
          child: Scaffold(
            appBar: CommonAppBar(
              title: '프로필 수정',
              centerTitle: true,
              onBack: () {
                if (!saving) context.pop();
              },
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _FieldLabel('이메일 (변경할 수 없습니다)'),
                    TextFormField(
                      initialValue: email,
                      enabled: false, // email은 읽기 전용입니다.
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grayDark,
                      ),
                      decoration: _decoration(),
                    ),
                    const SizedBox(height: 24),
                    const _FieldLabel('닉네임'),
                    TextField(
                      controller: _controller,
                      enabled: !saving,
                      maxLength: 12, // 오른쪽 아래에 '4/12' 카운터가 생깁니다.
                      textInputAction: TextInputAction.done,
                      onChanged: (_) => viewModel.onNicknameChanged(),
                      onSubmitted: (_) {
                        if (!saving) _submit();
                      },
                      decoration: _decoration(
                        errorText: viewModel.nicknameError,
                      ),
                    ),
                    const Spacer(),
                    MovieLogButton(
                      label: '저장',
                      width: double.infinity,
                      height: 52,
                      isLoading: saving,
                      onPressed: saving ? null : _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _decoration({String? errorText}) {
    return InputDecoration(
      errorText: errorText,
      errorMaxLines: 2,
      filled: true,
      fillColor: AppColors.grayLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      errorStyle: const TextStyle(fontSize: 12, color: AppColors.red),
      enabledBorder: _border(AppColors.grayLine),
      disabledBorder: _border(AppColors.grayLine),
      focusedBorder: _border(AppColors.violet, width: 1.5),
      errorBorder: _border(AppColors.red),
      focusedErrorBorder: _border(AppColors.red, width: 1.5),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
