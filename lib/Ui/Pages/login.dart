import 'package:flutter/material.dart';

import 'forgot_password.dart';
import 'signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _rememberId = false;
  bool _hidePassword = true;

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$feature 기능은 준비 중이에요.')));
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    // Connect authentication and persist the ID only when _rememberId is true.
    _showComingSoon('로그인');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colors.secondary),
    );
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: colors.secondary.withValues(alpha: 0.25),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: inputBorder.copyWith(
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/images/timePick_logo_no_background.png',
                      width: 168,
                      semanticLabel: '타임픽',
                    ),
                  ),
                  SizedBox(
                    height: (constraints.maxHeight * 0.08).clamp(24.0, 96.0),
                  ),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.surface,
                          border: Border.all(color: colors.secondary),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: AutofillGroup(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    '로그인',
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 48),
                                  TextFormField(
                                    decoration: inputDecoration.copyWith(
                                      labelText: '아이디',
                                      hintText: '아이디를 입력해주세요',
                                    ),
                                    autofillHints: const [
                                      AutofillHints.username,
                                    ],
                                    textInputAction: TextInputAction.next,
                                    autocorrect: false,
                                    validator: (value) =>
                                        value == null || value.trim().isEmpty
                                        ? '아이디를 입력해주세요.'
                                        : null,
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    decoration: inputDecoration.copyWith(
                                      labelText: '비밀번호',
                                      hintText: '비밀번호를 입력해주세요',
                                      suffixIcon: IconButton(
                                        tooltip: _hidePassword
                                            ? '비밀번호 표시'
                                            : '비밀번호 숨기기',
                                        onPressed: () => setState(
                                          () => _hidePassword = !_hidePassword,
                                        ),
                                        icon: Icon(
                                          _hidePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                        ),
                                      ),
                                    ),
                                    obscureText: _hidePassword,
                                    autofillHints: const [
                                      AutofillHints.password,
                                    ],
                                    textInputAction: TextInputAction.done,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    onFieldSubmitted: (_) => _login(),
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                        ? '비밀번호를 입력해주세요.'
                                        : null,
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    alignment: WrapAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Checkbox(
                                            value: _rememberId,
                                            semanticLabel: '아이디 저장',
                                            onChanged: (value) => setState(
                                              () =>
                                                  _rememberId = value ?? false,
                                            ),
                                          ),
                                          const Text('아이디 저장'),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).push(
                                              MaterialPageRoute<void>(
                                                builder: (_) =>
                                                    const ForgotPasswordPage(),
                                              ),
                                            ),
                                        child: const Text('비밀번호 찾기'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  FilledButton(
                                    onPressed: _login,
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size.fromHeight(52),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text('로그인'),
                                  ),
                                  const SizedBox(height: 16),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).push(
                                            MaterialPageRoute<void>(
                                              builder: (_) =>
                                                  const SignupPage(),
                                            ),
                                          ),
                                      child: const Text('회원가입'),
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
