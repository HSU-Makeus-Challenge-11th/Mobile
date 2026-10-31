import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';
import 'package:movielog/widgets/movielog_button.dart';

class SignUpActions extends StatelessWidget {
  const SignUpActions({
    super.key,
    required this.agreed,
    required this.canSubmit,
    required this.onAgreementChanged,
    required this.onSubmit,
    required this.onLogin,
  });

  final bool agreed;
  final bool canSubmit;
  final ValueChanged<bool?> onAgreementChanged;
  final VoidCallback onSubmit;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 32, bottom: 43),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 1),
          child: Semantics(
            checked: agreed,
            enabled: true,
            label: '필수 약관에 동의합니다',
            child: InkWell(
              key: const Key('termsCheckbox'),
              onTap: () => onAgreementChanged(!agreed),
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 24,
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: OverflowBox(
                        minWidth: agreed ? 26 : 24,
                        maxWidth: agreed ? 26 : 24,
                        minHeight: agreed ? 26 : 24,
                        maxHeight: agreed ? 26 : 24,
                        child: Container(
                          width: agreed ? 26 : 24,
                          height: agreed ? 26 : 24,
                          decoration: BoxDecoration(
                            color: agreed
                                ? const Color(0xFF6750A4)
                                : Colors.white,
                            border: Border.all(
                              color: agreed
                                  ? const Color(0xFF6750A4)
                                  : const Color(0xFFCBC4D2),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: agreed
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '필수 약관에 동의합니다',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        height: 19 / 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 25),
        MovieLogButton(
          key: const Key('signUpButton'),
          label: '가입하기',
          width: double.infinity,
          disabledColor: const Color(0xFFD3C6E2),
          labelStyle: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            height: 19 / 14,
            fontWeight: FontWeight.w700,
          ),
          onPressed: canSubmit ? onSubmit : null,
        ),
        const SizedBox(height: 54),
        Padding(
          padding: const EdgeInsets.only(left: 54),
          child: Row(
            children: [
              const Text(
                '이미 계정이 있나요?',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  height: 19 / 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: onLogin,
                child: const Text(
                  '로그인',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    height: 19 / 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
