import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_pick/Ui/Pages/login/login.dart';
import 'package:time_pick/Ui/Pages/login/signup.dart';
import 'package:time_pick/Ui/theme/app_theme.dart';

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.pumpAndSettle();
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Signup opens from login and returns on a small screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const LoginPage()),
    );
    await tapVisible(tester, find.widgetWithText(TextButton, '회원가입'));
    expect(find.byType(SignupPage), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));
    expect(find.byType(ChoiceChip), findsNWidgets(2));
    expect(
      tester
          .widgetList<ChoiceChip>(find.byType(ChoiceChip))
          .every((chip) => !chip.selected),
      isTrue,
    );
    await tester.enterText(
      find.byType(TextFormField).first,
      'user@example.com',
    );
    await tapVisible(tester, find.widgetWithText(ChoiceChip, '사업자 회원'));
    expect(find.text('업체 정보와 서비스, 일정 및 예약을 관리해요.'), findsOneWidget);
    await tapVisible(tester, find.widgetWithText(ChoiceChip, '일반 회원'));
    expect(find.text('원하는 시간에 업체를 찾고 예약해요.'), findsOneWidget);
    expect(find.text('user@example.com'), findsOneWidget);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, '사업자 회원'))
          .selected,
      isFalse,
    );
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pump();
    await tapVisible(tester, find.widgetWithText(TextButton, '로그인으로 돌아가기'));
    expect(find.byType(LoginPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Signup validates fields and never approves IDs without a server',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const SignupPage()),
      );
      final fields = find.byType(TextFormField);
      final submit = find.widgetWithText(FilledButton, '회원가입');
      final check = find.widgetWithText(OutlinedButton, '중복 확인');
      await tapVisible(tester, submit);
      expect(find.text('가입 유형을 선택해주세요.'), findsOneWidget);
      expect(find.text('이메일을 입력해주세요.'), findsOneWidget);
      expect(find.text('아이디를 입력해주세요.'), findsOneWidget);
      expect(find.text('비밀번호를 입력해주세요.'), findsOneWidget);
      expect(find.text('비밀번호를 다시 입력해주세요.'), findsOneWidget);

      await tapVisible(tester, find.widgetWithText(ChoiceChip, '일반 회원'));

      await tester.enterText(fields.at(0), 'invalid');
      await tester.enterText(fields.at(1), 'timepick');
      await tester.enterText(fields.at(2), 'short');
      await tester.enterText(fields.at(3), 'different');
      await tapVisible(tester, submit);
      expect(find.text('올바른 이메일 주소를 입력해주세요.'), findsOneWidget);
      expect(find.text('비밀번호는 8자 이상 입력해주세요.'), findsOneWidget);
      expect(find.text('비밀번호가 일치하지 않아요.'), findsOneWidget);
      expect(find.text('가입 유형을 선택해주세요.'), findsNothing);

      await tester.enterText(fields.at(0), 'user@example.com');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'password123');
      await tapVisible(tester, submit);
      expect(find.text('아이디 중복 확인을 먼저 해주세요.'), findsOneWidget);
      await tapVisible(tester, check);
      expect(find.text('지금은 중복 확인을 이용할 수 없어요.'), findsOneWidget);
      expect(find.text('사용 가능한 아이디예요.'), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'ID checks handle duplicate, error, stale results and edited IDs',
    (tester) async {
      final requests = <String, Completer<bool>>{};
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: SignupPage(
            isIdAvailable: (id) {
              final request = Completer<bool>();
              requests[id] = request;
              return request.future;
            },
          ),
        ),
      );
      final fields = find.byType(TextFormField);
      final check = find.widgetWithText(OutlinedButton, '중복 확인');
      await tester.enterText(fields.at(1), 'taken');
      await tapVisible(tester, check);
      expect(
        tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
        isNull,
      );
      requests['taken']!.complete(false);
      await tester.pumpAndSettle();
      expect(find.text('이미 사용 중인 아이디예요.'), findsOneWidget);

      await tester.enterText(fields.at(1), 'failure');
      await tapVisible(tester, check);
      requests['failure']!.completeError(Exception('offline'));
      await tester.pumpAndSettle();
      expect(find.text('중복 확인에 실패했어요. 다시 시도해주세요.'), findsOneWidget);

      await tester.enterText(fields.at(1), 'old');
      await tapVisible(tester, check);
      await tester.enterText(fields.at(1), 'new');
      await tapVisible(tester, check);
      requests['old']!.complete(true);
      await tester.pumpAndSettle();
      expect(find.text('사용 가능한 아이디예요.'), findsNothing);
      expect(find.text('확인 중…'), findsOneWidget);
      requests['new']!.complete(true);
      await tester.pumpAndSettle();
      expect(find.text('사용 가능한 아이디예요.'), findsOneWidget);

      await tester.enterText(fields.at(0), 'user@example.com');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'password123');
      await tapVisible(tester, find.widgetWithText(ChoiceChip, '일반 회원'));
      await tapVisible(tester, find.widgetWithText(ChoiceChip, '사업자 회원'));
      expect(find.text('사용 가능한 아이디예요.'), findsOneWidget);
      await tapVisible(tester, find.widgetWithText(FilledButton, '회원가입'));
      expect(find.text('사업자 회원 가입 기능은 준비 중이에요.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      await tester.enterText(fields.at(1), 'changed');
      await tapVisible(tester, find.widgetWithText(FilledButton, '회원가입'));
      expect(find.text('사용 가능한 아이디예요.'), findsNothing);
      expect(find.text('아이디 중복 확인을 먼저 해주세요.'), findsOneWidget);

      await tapVisible(tester, check);
      await tester.pumpWidget(const SizedBox.shrink());
      requests['changed']!.complete(true);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
