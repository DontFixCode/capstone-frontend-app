import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:time_pick/Ui/Pages/map_page.dart';
import 'package:time_pick/Ui/theme/app_theme.dart';

Widget mapApp(String key) => MaterialApp(
  theme: AppTheme.light,
  home: DefaultTabController(
    length: 2,
    child: Scaffold(body: MapPage(nativeAppKey: key)),
  ),
);

void main() {
  for (final scenario in [
    'allowed',
    'denied',
    'forever',
    'disabled',
    'failure',
    'timeout',
    'overseas',
    'invalid',
  ]) {
    testWidgets(
      'Initial location: $scenario',
      (tester) async {
        const locationChannel = MethodChannel(
          'flutter.baseflow.com/geolocator',
        );
        const sdkChannel = MethodChannel('flutter_kakao_maps_sdk');
        final messenger = tester.binding.defaultBinaryMessenger;
        var requests = 0;
        var positionRequests = 0;
        messenger.setMockMethodCallHandler(sdkChannel, (_) async => null);
        messenger.setMockMethodCallHandler(
          SystemChannels.platform_views,
          (_) async => null,
        );
        messenger.setMockMethodCallHandler(locationChannel, (call) async {
          switch (call.method) {
            case 'isLocationServiceEnabled':
              return scenario != 'disabled';
            case 'checkPermission':
              return scenario == 'forever' ? 1 : 0;
            case 'requestPermission':
              requests++;
              return scenario == 'denied' ? 0 : 2;
            case 'getCurrentPosition':
              positionRequests++;
              if (scenario == 'failure') {
                throw PlatformException(code: 'unavailable');
              }
              if (scenario == 'timeout') {
                return Completer<Map<String, dynamic>>().future;
              }
              if (scenario == 'overseas') {
                return {'latitude': 37.3349, 'longitude': -122.0090};
              }
              if (scenario == 'invalid') {
                return {'latitude': double.nan, 'longitude': 127.0};
              }
              return {'latitude': 35.1796, 'longitude': 129.0756};
          }
          return null;
        });
        addTearDown(() {
          messenger.setMockMethodCallHandler(locationChannel, null);
          messenger.setMockMethodCallHandler(sdkChannel, null);
          messenger.setMockMethodCallHandler(
            SystemChannels.platform_views,
            null,
          );
        });
        await tester.pumpWidget(mapApp('test-key'));
        await tester.pump();
        await tester.pump();
        if (scenario == 'timeout') {
          await tester.pump(const Duration(seconds: 11));
          await tester.pump();
        }
        final map = tester.widget<KakaoMap>(find.byType(KakaoMap));
        expect(
          map.option!.position.latitude,
          scenario == 'allowed' ? 35.1796 : 37.5665,
        );
        expect(
          map.option!.position.longitude,
          scenario == 'allowed' ? 129.0756 : 126.9780,
        );
        expect(requests, ['disabled', 'forever'].contains(scenario) ? 0 : 1);
        expect(
          positionRequests,
          [
                'allowed',
                'failure',
                'timeout',
                'overseas',
                'invalid',
              ].contains(scenario)
              ? 1
              : 0,
        );
        expect(
          find.textContaining('서울시청'),
          scenario == 'allowed' ? findsNothing : findsOneWidget,
        );
        await tester.pumpWidget(const SizedBox.shrink());
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  }

  testWidgets(
    'Missing key avoids native SDK initialization',
    (tester) async {
      await tester.pumpWidget(mapApp(''));
      expect(find.text('지도 사용 설정이 필요해요.'), findsOneWidget);
      expect(find.byType(KakaoMap), findsNothing);
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'SDK failure can retry and map authentication errors are handled',
    (tester) async {
      const locationChannel = MethodChannel('flutter.baseflow.com/geolocator');
      const sdkChannel = MethodChannel('flutter_kakao_maps_sdk');
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(locationChannel, (_) async => false);
      var attempts = 0;
      messenger.setMockMethodCallHandler(sdkChannel, (call) async {
        expect(call.method, 'initialize');
        expect(call.arguments, {'appKey': 'test-key'});
        attempts++;
        if (attempts == 1) throw PlatformException(code: 'unavailable');
        return null;
      });
      messenger.setMockMethodCallHandler(
        SystemChannels.platform_views,
        (_) async => null,
      );
      addTearDown(() {
        messenger.setMockMethodCallHandler(locationChannel, null);
        messenger.setMockMethodCallHandler(sdkChannel, null);
        messenger.setMockMethodCallHandler(SystemChannels.platform_views, null);
      });

      await tester.pumpWidget(mapApp('test-key'));
      await tester.pumpAndSettle();
      expect(find.text('지도를 시작하지 못했어요. 다시 시도해주세요.'), findsOneWidget);
      await tester.tap(find.text('다시 시도'));
      await tester.pump();
      await tester.pump();
      expect(attempts, 2);
      final map = tester.widget<KakaoMap>(find.byType(KakaoMap));
      expect(map.forceGesture, isTrue);
      expect(map.option!.position.latitude, 37.5665);
      map.onMapError!(KakaoAuthError(401, 'test authentication failure'));
      await tester.pumpAndSettle();
      expect(find.text('지도 사용 인증을 확인하지 못했어요.'), findsOneWidget);
      expect(find.byType(KakaoMap), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );
}
