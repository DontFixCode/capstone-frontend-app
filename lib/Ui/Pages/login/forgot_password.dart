import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  void _requestReset() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    // Connect the password recovery API here when email delivery is ready.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('이메일 발송 기능은 준비 중이에요. 아직 이메일이 발송되지 않았어요.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final border = OutlineInputBorder(
      borderRadius: AppTheme.corners,
      borderSide: BorderSide(color: AppTheme.borderMuted),
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/images/timePick_logo_no_background.png',
                  color: AppTheme.brand,
                  colorBlendMode: BlendMode.srcIn,
                  width: 168,
                  semanticLabel: '타임픽',
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: AppTheme.panel(raised: true),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '비밀번호 찾기',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '가입할 때 사용한 이메일을 입력해주세요.\n이메일로 비밀번호 재설정 방법을 안내해드려요.',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 32),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: '이메일',
                              hintText: 'example@email.com',
                              filled: true,
                              fillColor: AppTheme.surface,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                              border: border,
                              enabledBorder: border,
                              focusedBorder: border.copyWith(
                                borderSide: BorderSide(
                                  color: colors.primary,
                                  width: 2,
                                ),
                              ),
                              errorMaxLines: 2,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            textInputAction: TextInputAction.done,
                            autocorrect: false,
                            onFieldSubmitted: (_) => _requestReset(),
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty) return '이메일을 입력해주세요.';
                              if (!RegExp(
                                r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                              ).hasMatch(email)) {
                                return '올바른 이메일 주소를 입력해주세요.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          FilledButton(
                            onPressed: _requestReset,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppTheme.corners,
                              ),
                            ),
                            child: const Text('재설정 이메일 요청'),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '   ', //전송바 아래 안내멘트
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('로그인으로 돌아가기'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
