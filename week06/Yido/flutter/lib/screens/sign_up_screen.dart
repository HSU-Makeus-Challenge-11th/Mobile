import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/sign_up_validators.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/widgets/back_arrow_icon.dart';
import 'package:movielog/view_models/sign_up_view_model.dart';
import 'package:movielog/widgets/signup/sign_up_actions.dart';
import 'package:movielog/widgets/signup/sign_up_fields.dart';
import 'package:movielog/widgets/signup/sign_up_header.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameFocusNode = FocusNode(debugLabel: 'nickname');
  final _emailFocusNode = FocusNode(debugLabel: 'email');
  final _passwordFocusNode = FocusNode(debugLabel: 'password');
  bool _agreed = false;

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _nicknameController,
      _emailController,
      _passwordController,
    ]) {
      controller.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  bool _canSubmit(SignUpViewModel viewModel) =>
      _agreed &&
      viewModel.nicknameCheckStatus == CheckStatus.available &&
      viewModel.emailCheckStatus == CheckStatus.available &&
      SignUpValidators.nickname(_nicknameController.text) == null &&
      SignUpValidators.email(_emailController.text) == null &&
      SignUpValidators.password(_passwordController.text) == null;
  void _refresh() {
    if (mounted) setState(() {});
  }

  void _submit() {
    if (!_canSubmit(context.read<SignUpViewModel>()) ||
        !(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    FocusScope.of(context).unfocus();
    context.go('/home');
  }

  void _back() {
    context.go('/start');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.surfaceBright,
    appBar: _SignUpAppBar(onBack: _back),
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(17, 45, 17, 0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: math.max(0, constraints.maxHeight - 45),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SignUpHeader(),
                      const SizedBox(height: 27),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: SignUpFields(
                          nicknameController: _nicknameController,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          nicknameFocusNode: _nicknameFocusNode,
                          emailFocusNode: _emailFocusNode,
                          passwordFocusNode: _passwordFocusNode,
                          onChanged: _refresh,
                        ),
                      ),
                    ],
                  ),
                  SignUpActions(
                    agreed: _agreed,
                    canSubmit: _canSubmit(context.watch<SignUpViewModel>()),
                    onAgreementChanged: (value) =>
                        setState(() => _agreed = value ?? false),
                    onSubmit: _submit,
                    onLogin: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('로그인 기능은 아직 연결되지 않았습니다.')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _SignUpAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SignUpAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) => AppBar(
    toolbarHeight: 64,
    centerTitle: true,
    backgroundColor: AppColors.surfaceBright,
    title: const Text(
      '회원가입',
      style: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 20,
        height: 27 / 20,
        fontWeight: FontWeight.w700,
        color: AppColors.primary500,
      ),
    ),
    leading: IconButton(icon: const BackArrowIcon(), onPressed: onBack),
  );
}
