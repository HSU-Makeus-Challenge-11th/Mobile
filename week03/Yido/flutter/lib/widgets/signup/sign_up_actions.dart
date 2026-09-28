import 'package:flutter/material.dart';

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
    padding: const EdgeInsets.only(top: 32, bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
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
                      fontSize: 16,
                      height: 24 / 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1D1B20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 56,
          child: ElevatedButton(
            key: const Key('signUpButton'),
            onPressed: canSubmit ? onSubmit : null,
            style: ElevatedButton.styleFrom(
              elevation: 1,
              backgroundColor: const Color(0xFF6750A4),
              disabledBackgroundColor: const Color(0xFFCCC2DC),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              '가입하기',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                height: 24 / 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '이미 계정이 있나요?',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                height: 24 / 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF494551),
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: onLogin,
              child: const Text(
                '로그인',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  height: 24 / 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6750A4),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
