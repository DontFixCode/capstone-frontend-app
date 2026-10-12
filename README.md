# time_pick

## 메인 화면

홈 / 지도 / 내 예약 / 마이 하단 메뉴는 스크롤과 별개로 고정됩니다.
홈에서 지역, 날짜, 시작·종료 시간, 구체적인 서비스를 선택하며 검색 조건은 결과 목록과 지도 전환 시 유지됩니다.
현재 위치 주변을 기본으로 하며 지역 선택에는 대전 서구, 서울 강남구, 부산 연제구, 인천 남동구가 준비되어 있습니다.
과거 시작 시간, 역전된 시간 범위, 서비스 예상 소요시간보다 짧은 범위는 검색 전에 안내합니다.

현재 검색 결과의 업체·가격·시작 시각은 **프론트엔드 시연용 예시**이며 실제 예약 가능 정보가 아닙니다.
예시 시작 시각도 선택한 종료 시간 안에 서비스가 끝나는 경우만 표시합니다.
실제 예약 데이터가 없어 홈의 다가오는 예약 영역은 숨기고 이용 안내를 표시합니다.
업체 정보 보기를 누르면 최근 본 업체에 추가되며 조회 기록은 현재 화면 세션에서만 유지됩니다.
지도는 선택한 지역의 중심 또는 현재 위치를 보여주며 실제 검색 업체 마커는 서버 연동 후 추가합니다.

## 카카오맵 실행 (iOS)

`config/kakao.example.json`을 `config/kakao.local.json`으로 복사하고
`KAKAO_NATIVE_APP_KEY`에 카카오 네이티브 앱 키를 입력합니다.
로컬 파일은 Git에서 제외되며 Flutter asset으로 등록하지 않습니다.

```sh
flutter run --dart-define-from-file=config/kakao.local.json
```

iPhone 또는 iOS 시뮬레이터를 선택합니다. VS Code에서는
`Time Pick (Kakao Maps)` 실행 구성이 같은 설정 파일을 사용합니다.
키를 변경한 뒤에는 앱을 완전히 종료하고 다시 실행합니다.

Android Studio에서는 Run → Edit Configurations → main.dart의 Additional run args에
`--dart-define-from-file=config/kakao.local.json`을 넣습니다.
현재 로컬 실행 설정에는 적용되어 있으며 `.idea`는 Git에서 제외되므로 다른 개발 환경에서는 별도로 설정합니다.
"지도 사용 설정이 필요해요"가 표시되면 이 실행 옵션이 빠진 상태입니다.
옵션 적용 후 Hot Reload 대신 실행을 중지하고 다시 Run 합니다.

카카오디벨로퍼스의 카카오맵 사용 설정을 활성화하고, 해당 네이티브 앱 키에
iOS 번들 ID `com.dontfixcode.timepick`을 등록해야 합니다.
로그인 → 메인 → 왼쪽 스와이프 또는 지도 탭으로 확인합니다.
지도를 처음 열면 사용 중 위치 권한을 요청하고 현재 위치를 중심으로 표시합니다.
위치 서비스가 꺼져 있거나 권한 거부·조회 실패(10초 제한) 시 서울시청과 안내 문구를 표시합니다.
위치는 시작 시 한 번 조회하며 백그라운드 위치 추적이나 업체·예약 서버 연동은 없습니다.
시뮬레이터에서는 Features → Location에서 테스트 위치를 설정해야 합니다.
해외 시뮬레이션 좌표에서는 지도가 비어 보일 수 있습니다. Custom Location에
위도 `36.3553`, 경도 `127.3838`(대전 서구)을 입력한 뒤 앱을 다시 시작하세요.
현재 위치가 앱의 국내 서비스 범위 밖이면 안내와 함께 서울시청을 표시합니다.
지도 영역의 드래그는 지도 이동에 사용하며 메인 복귀는 상단 버튼/탭으로 합니다.

Android 테스트에는 같은 패키지명과 개발용 키 해시 등록이 별도로 필요합니다.
웹은 JavaScript 키와 도메인 설정이 필요하므로 현재 연결 범위에 포함하지 않습니다.

설정이 빠지거나 인증에 실패하면 안내 화면을 표시합니다.
네이티브 앱 키는 배포 앱에 포함되므로 플랫폼 등록 제한으로 사용 범위를 관리합니다.

참고: [카카오 앱 설정](https://developers.kakao.com/docs/ko/app-setting/app),
[Flutter 패키지](https://pub.dev/packages/kakao_map_sdk)

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
