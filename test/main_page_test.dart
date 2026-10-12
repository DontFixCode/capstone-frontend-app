import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_pick/Ui/Pages/login/login.dart';
import 'package:time_pick/Ui/Pages/main_page.dart';
import 'package:time_pick/Ui/theme/app_theme.dart';

void main() {
  testWidgets(
    'Home scrolls beneath fixed navigation and preserves search on map',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const MainPage()),
      );
      final navPosition = tester.getTopLeft(find.byType(NavigationBar));
      expect(find.text('최근 본 업체'), findsNothing);
      await tester.tap(find.text('현재 위치 주변'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('대전 서구'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('이 시간에 예약 찾기'));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.byType(NavigationBar)), navPosition);
      expect(find.text('홈').hitTestable(), findsOneWidget);
      await tester.tap(find.text('이 시간에 예약 찾기'));
      await tester.pumpAndSettle();
      expect(find.text('예시 결과'), findsOneWidget);
      expect(find.textContaining('25,000원'), findsOneWidget);
      await tester.ensureVisible(find.text('지도 보기'));
      await tester.tap(find.text('지도 보기'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        1,
      );
      expect(find.textContaining('대전 서구').hitTestable(), findsOneWidget);
      final pages = tester.widget<TabBarView>(find.byType(TabBarView));
      for (final drag in [const Offset(260, 0), const Offset(-260, 0)]) {
        await tester.drag(find.byType(TabBarView), drag);
        await tester.pumpAndSettle();
        expect(pages.controller!.index, 1);
        expect(pages.controller!.animation!.value, 1.0);
        expect(find.text('주변 업체 지도').hitTestable(), findsOneWidget);
      }
      await tester.tap(find.text('검색 결과 목록 보기'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('조건 수정'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('조건 수정'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(TabBarView), const Offset(-260, 0));
      await tester.pumpAndSettle();
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        1,
      );
      await tester.tap(find.text('내 예약'));
      await tester.pumpAndSettle();
      expect(find.text('다가오는 예약이 없어요').hitTestable(), findsOneWidget);
      await tester.tap(find.text('홈'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('대전 서구'),
        -300,
        scrollable: find.descendant(
          of: find.byKey(const PageStorageKey('main-home')),
          matching: find.byType(Scrollable),
        ),
      );
      expect(find.text('대전 서구').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Login provides a browse entry without authenticating', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const LoginPage()),
    );
    await tester.ensureVisible(find.text('둘러보기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('둘러보기'));
    await tester.pumpAndSettle();
    expect(find.byType(MainPage), findsOneWidget);
    Navigator.of(tester.element(find.byType(MainPage))).pop();
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
