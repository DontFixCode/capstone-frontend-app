import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

enum SignupAccountType {
  customer('일반 회원', '원하는 시간에 업체를 찾고 예약해요.'),
  business('사업자 회원', '업체 정보와 서비스, 일정 및 예약을 관리해요.');

  const SignupAccountType(this.label, this.description);

  final String label;
  final String description;
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key, this.isIdAvailable});

  /// Returns true only when the server confirms the ID is available.
  final Future<bool> Function(String id)? isIdAvailable;

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _accountTypeKey = GlobalKey<FormFieldState<SignupAccountType>>();
  final _idKey = GlobalKey<FormFieldState<String>>();
  final _id = TextEditingController();
  final _password = TextEditingController();
  String? _checkedId;
  String? _idMessage;
  bool _checkingId = false;
  bool _hidePassword = true;
  bool _hideConfirmation = true;
  int _checkVersion = 0;

  @override
  void dispose() {
    _id.dispose();
    _password.dispose();
    super.dispose();
  }

  void _idChanged(String _) {
    setState(() {
      _checkVersion++;
      _checkedId = null;
      _idMessage = null;
      _checkingId = false;
    });
  }

  Future<void> _checkId() async {
    if (_checkingId || !_idKey.currentState!.validate()) return;
    final check = widget.isIdAvailable;
    if (check == null) {
      setState(() => _idMessage = '지금은 중복 확인을 이용할 수 없어요.');
      return;
    }

    final id = _id.text.trim();
    final version = ++_checkVersion;
    setState(() {
      _checkingId = true;
      _checkedId = null;
      _idMessage = null;
    });
    try {
      final available = await check(id);
      if (!mounted || version != _checkVersion) return;
      setState(() {
        _checkedId = available ? id : null;
        _idMessage = available ? '사용 가능한 아이디예요.' : '이미 사용 중인 아이디예요.';
      });
    } catch (_) {
      if (!mounted || version != _checkVersion) return;
      setState(() => _idMessage = '중복 확인에 실패했어요. 다시 시도해주세요.');
    } finally {
      if (mounted && version == _checkVersion) {
        setState(() => _checkingId = false);
      }
    }
  }

  void _signup() {
    if (!_formKey.currentState!.validate()) return;
    if (_checkedId != _id.text.trim()) {
      setState(() => _idMessage = '아이디 중복 확인을 먼저 해주세요.');
      return;
    }
    FocusScope.of(context).unfocus();
    final accountType = _accountTypeKey.currentState!.value!;
    // Include accountType in the registration request when the API is connected.
    // The server must validate permissions and enforce ID uniqueness again.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${accountType.label} 가입 기능은 준비 중이에요.')),
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
    final decoration = InputDecoration(
      filled: true,
      fillColor: AppTheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
      errorMaxLines: 2,
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
                      child: AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '회원가입',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 32),
                            FormField<SignupAccountType>(
                              key: _accountTypeKey,
                              validator: (value) =>
                                  value == null ? '가입 유형을 선택해주세요.' : null,
                              builder: (field) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '가입 유형',
                                    style: theme.textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      for (final type
                                          in SignupAccountType.values)
                                        ChoiceChip(
                                          label: Text(type.label),
                                          selected: field.value == type,
                                          selectedColor: AppTheme.actionSurface,
                                          onSelected: (_) =>
                                              field.didChange(type),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    field.value?.description ??
                                        '타임픽을 어떻게 이용하실 건가요?',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  if (field.hasError) ...[
                                    const SizedBox(height: 8),
                                    Semantics(
                                      liveRegion: true,
                                      child: Text(
                                        field.errorText!,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: colors.error),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextFormField(
                              decoration: decoration.copyWith(labelText: '이메일'),
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
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
                            const SizedBox(height: 20),
                            TextFormField(
                              key: _idKey,
                              controller: _id,
                              decoration: decoration.copyWith(labelText: '아이디'),
                              autofillHints: const [AutofillHints.newUsername],
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
                              onChanged: _idChanged,
                              validator: (value) {
                                final id = value?.trim() ?? '';
                                if (id.isEmpty) return '아이디를 입력해주세요.';
                                if (RegExp(r'\s').hasMatch(id)) {
                                  return '아이디에는 공백을 사용할 수 없어요.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton(
                                onPressed: _checkingId ? null : _checkId,
                                child: Text(_checkingId ? '확인 중…' : '중복 확인'),
                              ),
                            ),
                            if (_idMessage != null)
                              Semantics(
                                liveRegion: true,
                                child: Text(
                                  _idMessage!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: _checkedId != null
                                        ? colors.primary
                                        : colors.error,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _password,
                              decoration: decoration.copyWith(
                                labelText: '비밀번호',
                                helperText: '8자 이상 입력해주세요',
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
                              autofillHints: const [AutofillHints.newPassword],
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
                              enableSuggestions: false,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '비밀번호를 입력해주세요.';
                                }
                                if (value.length < 8) {
                                  return '비밀번호는 8자 이상 입력해주세요.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              decoration: decoration.copyWith(
                                labelText: '비밀번호 확인',
                                suffixIcon: IconButton(
                                  tooltip: _hideConfirmation
                                      ? '비밀번호 확인 표시'
                                      : '비밀번호 확인 숨기기',
                                  onPressed: () => setState(
                                    () =>
                                        _hideConfirmation = !_hideConfirmation,
                                  ),
                                  icon: Icon(
                                    _hideConfirmation
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                ),
                              ),
                              obscureText: _hideConfirmation,
                              textInputAction: TextInputAction.done,
                              autocorrect: false,
                              enableSuggestions: false,
                              onFieldSubmitted: (_) => _signup(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '비밀번호를 다시 입력해주세요.';
                                }
                                if (value != _password.text) {
                                  return '비밀번호가 일치하지 않아요.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 28),
                            FilledButton(
                              onPressed: _checkingId ? null : _signup,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppTheme.corners,
                                ),
                              ),
                              child: const Text('회원가입'),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
