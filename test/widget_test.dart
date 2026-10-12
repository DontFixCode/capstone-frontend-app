import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:time_pick/Ui/Pages/splash.dart';
import 'package:time_pick/Ui/Pages/login/login.dart';
import 'package:time_pick/Ui/Pages/main_page.dart';
import 'package:time_pick/Ui/Pages/login/forgot_password.dart';
import 'package:time_pick/Ui/theme/app_theme.dart';
import 'package:time_pick/main.dart';

void main() {
  testWidgets('Password recovery validates email and returns to login', (
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

    Future<void> tapVisible(Finder finder) async {
      await tester.pumpAndSettle();
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    await tester.enterText(find.byType(TextFormField).first, 'timepick');
    await tapVisible(find.widgetWithText(TextButton, '비밀번호 찾기'));
    expect(find.byType(ForgotPasswordPage), findsOneWidget);

    final email = find.byType(TextFormField);
    final request = find.widgetWithText(FilledButton, '재설정 이메일 요청');
    await tapVisible(request);
    expect(find.text('이메일을 입력해주세요.'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    await tester.enterText(email, 'invalid');
    await tapVisible(request);
    expect(find.text('올바른 이메일 주소를 입력해주세요.'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);

    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pump();
    await tester.enterText(email, ' user@example.com ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('올바른 이메일 주소를 입력해주세요.'), findsNothing);
    expect(find.text('이메일 발송 기능은 준비 중이에요. 아직 이메일이 발송되지 않았어요.'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(seconds: 5));
    await tapVisible(find.widgetWithText(TextButton, '로그인으로 돌아가기'));
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('timepick'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('App opens splash with a loaded logo on a small screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());

    expect(find.byType(SplashPage), findsOneWidget);
    final logo = tester.widget<Image>(find.byType(Image));
    expect(
      (logo.image as AssetImage).assetName,
      'assets/images/timePick_logo_no_background.png',
    );
    await tester.runAsync(() async {
      await precacheImage(logo.image, tester.element(find.byType(SplashPage)));
    });
    await tester.pump();

    expect(
      tester.renderObject<RenderImage>(find.byType(RawImage)).image,
      isNotNull,
    );
    expect(find.text('사용자 중심 예약 플랫폼'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(SplashPage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Login button opens main with empty credentials', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const LoginPage()),
    );
    final loginButton = find.widgetWithText(FilledButton, '로그인');
    await tester.ensureVisible(loginButton);
    await tester.pumpAndSettle();
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.byType(MainPage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
    expect(
      Navigator.of(tester.element(find.byType(MainPage))).canPop(),
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Login accepts arbitrary credentials through keyboard submission',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const LoginPage()),
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.first, 'timepick');
      await tester.enterText(fields.last, 'example-password');
      expect(
        tester.widget<TextField>(find.byType(TextField).last).obscureText,
        isTrue,
      );
      await tester.ensureVisible(find.byTooltip('비밀번호 표시'));
      await tester.tap(find.byTooltip('비밀번호 표시'));
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField).last).obscureText,
        isFalse,
      );

      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);

      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      await tester.pump();
      await tester.showKeyboard(fields.last);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('아이디를 입력해주세요.'), findsNothing);
      expect(find.text('비밀번호를 입력해주세요.'), findsNothing);
      expect(find.byType(MainPage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
