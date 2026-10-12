import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

import '../theme/app_theme.dart';

class MapPage extends StatefulWidget {
  const MapPage({
    super.key,
    this.nativeAppKey = const String.fromEnvironment('KAKAO_NATIVE_APP_KEY'),
    this.initialPosition,
    this.onBack,
  });

  final String nativeAppKey;
  final LatLng? initialPosition;
  final VoidCallback? onBack;

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with AutomaticKeepAliveClientMixin {
  Future<LatLng>? _initialization;
  Timer? _loadTimeout;
  String? _error;
  String? _locationMessage;
  bool _ready = false;
  int _attempt = 0;

  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (_supported && widget.nativeAppKey.isNotEmpty) _initialize();
  }

  void _initialize() {
    _loadTimeout?.cancel();
    _error = null;
    _locationMessage = null;
    _ready = false;
    _attempt++;
    _initialization = _prepareMap(_attempt);
  }

  @override
  void didUpdateWidget(covariant MapPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPosition != widget.initialPosition &&
        _supported &&
        widget.nativeAppKey.isNotEmpty) {
      _initialize();
    }
  }

  Future<LatLng> _prepareMap(int attempt) async {
    await KakaoMapSdk.instance.initialize(widget.nativeAppKey);
    var position = widget.initialPosition ?? await _currentPosition();
    if (!mounted || attempt != _attempt) return position;
    // Coarse domestic service bounds, not a national-border check.
    // Simulator locations can point overseas, where this map is blank.
    if (!(position.latitude >= 32 &&
        position.latitude <= 39 &&
        position.longitude >= 124 &&
        position.longitude <= 132)) {
      _locationMessage = '현재 위치는 서비스 지역 밖이라 서울시청을 표시해요. 상단에서 검색 지역을 바꿀 수 있어요.';
      position = const LatLng(37.5665, 126.9780);
    }
    // Start the map timeout after the user answers the permission dialog.
    _loadTimeout = Timer(const Duration(seconds: 30), () {
      if (!mounted || _ready) return;
      setState(() => _error = '지도를 불러오는 데 시간이 걸리고 있어요. 다시 시도해주세요.');
    });
    return position;
  }

  Future<LatLng> _currentPosition() async {
    const fallback = LatLng(37.5665, 126.9780);
    if (!mounted) return fallback;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _locationMessage = '기기의 위치 서비스가 꺼져 있어 서울시청을 표시해요.';
        return fallback;
      }
      var permission = await Geolocator.checkPermission();
      if (!mounted) return fallback;
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        _locationMessage = '위치 권한이 없어 서울시청을 표시해요. 기기 설정에서 위치 권한을 허용할 수 있어요.';
        return fallback;
      }
      if (!mounted) return fallback;
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (_) {
      _locationMessage = '현재 위치를 가져오지 못해 서울시청을 표시해요.';
      return fallback;
    }
  }

  @override
  void dispose() {
    _loadTimeout?.cancel();
    super.dispose();
  }

  Widget _message(String message, {bool retry = false}) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.map_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            if (retry) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => setState(_initialize),
                child: const Text('다시 시도'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    if (!_supported) return _message('지도는 iOS·Android 앱에서 이용할 수 있어요.');
    if (widget.nativeAppKey.isEmpty) return _message('지도 사용 설정이 필요해요.');
    if (_error != null) return _message(_error!, retry: true);

    return FutureBuilder<LatLng>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _message('지도를 시작하지 못했어요. 다시 시도해주세요.', retry: true);
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            KakaoMap(
              key: ValueKey(_attempt),
              option: KakaoMapOption(
                position: snapshot.requireData,
                zoomLevel: 16,
              ),
              // Map drags pan the map. The header button and tabs navigate home.
              forceGesture: true,
              onMapReady: (_) {
                if (!mounted) return;
                _loadTimeout?.cancel();
                setState(() => _ready = true);
              },
              onMapError: (error) {
                if (!mounted) return;
                _loadTimeout?.cancel();
                setState(
                  () => _error = error is KakaoAuthError
                      ? '지도 사용 인증을 확인하지 못했어요.'
                      : '지도를 불러오지 못했어요. 다시 시도해주세요.',
                );
              },
            ),
            if (!_ready)
              const IgnorePointer(
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_locationMessage != null)
              Positioned(
                top: 12,
                left: 16,
                right: 16,
                child: IgnorePointer(
                  child: Material(
                    color: Theme.of(context).colorScheme.surface,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppTheme.corners,
                      side: BorderSide(color: AppTheme.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(_locationMessage!),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Wrap(
            spacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('주변 업체 지도', style: Theme.of(context).textTheme.titleMedium),
              TextButton.icon(
                onPressed:
                    widget.onBack ??
                    () => DefaultTabController.of(context).animateTo(0),
                icon: const Icon(Icons.arrow_back),
                label: const Text('메인으로 돌아가기'),
              ),
            ],
          ),
        ),
        Expanded(child: _buildMap()),
      ],
    );
  }
}
