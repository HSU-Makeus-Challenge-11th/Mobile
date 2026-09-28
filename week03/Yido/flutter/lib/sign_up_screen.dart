import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:movielog/profile_screen.dart';
import 'package:movielog/rating_screen.dart';
import 'package:movielog/sign_up_validators.dart';
import 'package:movielog/widgets/signup/sign_up_actions.dart';
import 'package:movielog/widgets/signup/sign_up_fields.dart';
import 'package:movielog/widgets/signup/sign_up_header.dart';

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
  bool _hasErrors = false;

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

  bool get _canSubmit =>
      _agreed &&
      SignUpValidators.nickname(_nicknameController.text) == null &&
      SignUpValidators.email(_emailController.text) == null &&
      SignUpValidators.password(_passwordController.text) == null;
  void _refresh() {
    if (mounted) setState(() {});
  }

  void _submit() {
    if (!_canSubmit || !(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const RatingScreen()));
  }

  void _back() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: _SignUpAppBar(onBack: _back),
    body: Container(
      decoration: BoxDecoration(
        border: Border.symmetric(
          vertical: BorderSide(
            color: _hasErrors
                ? const Color(0xFFCBC4D2)
                : const Color(0xFFE6E0E9),
          ),
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: math.max(0, constraints.maxHeight - 48),
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
                        SizedBox(height: _hasErrors ? 24 : 32),
                        SignUpFields(
                          nicknameController: _nicknameController,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          nicknameFocusNode: _nicknameFocusNode,
                          emailFocusNode: _emailFocusNode,
                          passwordFocusNode: _passwordFocusNode,
                          onChanged: _refresh,
                          onErrorStateChanged: (hasErrors) {
                            if (_hasErrors != hasErrors) {
                              setState(() => _hasErrors = hasErrors);
                            }
                          },
                        ),
                      ],
                    ),
                    SignUpActions(
                      agreed: _agreed,
                      canSubmit: _canSubmit,
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
    leadingWidth: 48,
    centerTitle: true,
    title: const Text(
      '회원가입',
      style: TextStyle(
        fontFamily: 'Manrope',
        fontSize: 22,
        height: 28 / 22,
        fontWeight: FontWeight.w500,
        color: Color(0xFF6750A4),
      ),
    ),
    leading: IconButton(
      onPressed: onBack,
      icon: const Icon(Icons.arrow_back, size: 16),
    ),
  );
}
