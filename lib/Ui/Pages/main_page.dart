import 'package:flutter/material.dart';

import '../../models/reservation_search.dart';
import '../widgets/app_navigation_bar.dart';
import '../widgets/booking_search_form.dart';
import '../theme/app_theme.dart';
import 'map_page.dart';
import 'search_results.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late ReservationSearch _search;
  ReservationSearch? _submitted;
  bool _results = false;
  final List<({String name, String region})> _recent = [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this)..addListener(_tabChanged);
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, now.day);
    _search = ReservationSearch(
      region: SearchRegion.nearby,
      date: now.hour >= 18 ? date.add(const Duration(days: 1)) : date,
      start: const TimeOfDay(hour: 18, minute: 0),
      end: const TimeOfDay(hour: 21, minute: 0),
      service: BookingService.haircut,
    );
  }

  void _tabChanged() => setState(() {});
  @override
  void dispose() {
    _tabs.removeListener(_tabChanged);
    _tabs.dispose();
    super.dispose();
  }

  void _go(int index) => _tabs.animateTo(index);

  Future<void> _region() async {
    final region = await showModalBottomSheet<SearchRegion>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '어느 지역에서 찾을까요?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
              for (final item in SearchRegion.values)
                ListTile(
                  leading: Icon(
                    item == SearchRegion.nearby
                        ? Icons.my_location
                        : Icons.location_on_outlined,
                  ),
                  title: Text(item.label),
                  trailing: item == _search.region
                      ? const Icon(Icons.check, color: AppTheme.action)
                      : null,
                  onTap: () => Navigator.pop(context, item),
                ),
            ],
          ),
        ),
      ),
    );
    if (region == null || !mounted) return;
    setState(() {
      _search = ReservationSearch(
        region: region,
        date: _search.date,
        start: _search.start,
        end: _search.end,
        service: _search.service,
      );
      _submitted = null;
      _results = false;
    });
  }

  void _find() {
    final error = _search.validate(DateTime.now());
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() {
      _submitted = _search;
      _results = true;
    });
  }

  void _details(String name, String region) {
    setState(() {
      _recent.removeWhere((item) => item.name == name && item.region == region);
      _recent.insert(0, (name: name, region: region));
      if (_recent.length > 3) _recent.removeLast();
    });
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(region),
              const SizedBox(height: 20),
              const Text('화면 미리보기용 예시 업체입니다.\n실제 업체 정보와 예약은 서비스 준비 후 제공됩니다.'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _empty(IconData icon, String title, String message) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppTheme.action),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textMuted, height: 1.6),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {
              setState(() => _results = false);
              _go(0);
            },
            child: const Text('홈으로 가기'),
          ),
        ],
      ),
    ),
  );

  Widget _home() => SingleChildScrollView(
    key: const PageStorageKey('main-home'),
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _region,
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textMuted,
                  padding: EdgeInsets.zero,
                ),
                icon: const Icon(Icons.location_on_outlined, size: 21),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_search.region.label),
                    const SizedBox(width: 8),
                    const Icon(Icons.expand_more, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 26),
            const Text(
              '언제 시간이\n비어 있나요?',
              style: TextStyle(
                fontSize: 32,
                height: 1.4,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '내 시간에 딱 맞는 예약을 찾아보세요.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 30),
            BookingSearchForm(
              search: _search,
              onChanged: (value) => setState(() {
                _search = value;
                _submitted = null;
              }),
              onSearch: _find,
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.brandSurface,
                borderRadius: AppTheme.corners,
                border: const Border(
                  left: BorderSide(color: AppTheme.brand, width: 4),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome_outlined, color: AppTheme.brand),
                  SizedBox(height: 12),
                  Text(
                    '빈 시간부터 골라보세요',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '날짜와 시간, 필요한 서비스를 선택하면\n내 일정에 맞춰 예약을 찾아볼 수 있어요.',
                    style: TextStyle(height: 1.7, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            if (_recent.isNotEmpty) ...[
              const SizedBox(height: 30),
              const Text(
                '최근 본 업체',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              for (final item in _recent)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.actionSurface,
                      borderRadius: AppTheme.corners,
                    ),
                    child: const Icon(
                      Icons.storefront_outlined,
                      color: AppTheme.action,
                    ),
                  ),
                  title: Text(item.name),
                  subtitle: Text('${item.region} · 예시 업체'),
                  onTap: () => _details(item.name, item.region),
                ),
            ],
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 24,
      title: Image.asset(
        'assets/images/timePick_logo_no_background.png',
        color: AppTheme.brand,
        colorBlendMode: BlendMode.srcIn,
        width: 112,
        height: 42,
        fit: BoxFit.contain,
        semanticLabel: '타임픽',
      ),
      actions: [
        IconButton(
          tooltip: '알림',
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            showDragHandle: true,
            builder: (context) => const SafeArea(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('새로운 알림이 없어요.', style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
          icon: const Icon(Icons.notifications_none_outlined),
        ),
        const SizedBox(width: 12),
      ],
    ),
    body: SafeArea(
      top: false,
      bottom: false,
      child: TabBarView(
        controller: _tabs,
        // kakao_map_sdk 1.3.1 does not forward gestureRecognizers to UiKitView.
        // Let the native map receive drags without competing with page swipes.
        physics: _tabs.index == 1 ? const NeverScrollableScrollPhysics() : null,
        children: [
          _results && _submitted != null
              ? SearchResults(
                  search: _submitted!,
                  onEdit: () => setState(() => _results = false),
                  onMap: () => _go(1),
                  onDetails: _details,
                )
              : _home(),
          Column(
            children: [
              if (_submitted != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _submitted!.summary,
                        style: const TextStyle(height: 1.6),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() => _results = true);
                          _go(0);
                        },
                        icon: const Icon(Icons.list_alt),
                        label: const Text('검색 결과 목록 보기'),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: TextButton.icon(
                    onPressed: _region,
                    icon: const Icon(Icons.location_on_outlined),
                    label: Text(_search.region.label),
                  ),
                ),
              Expanded(
                child: MapPage(
                  initialPosition: (_submitted ?? _search).region.center,
                  onBack: () => _go(0),
                ),
              ),
            ],
          ),
          _empty(
            Icons.event_available_outlined,
            '다가오는 예약이 없어요',
            '예약한 일정이 생기면\n이곳에서 확인할 수 있어요.',
          ),
          _empty(Icons.person_outline, '나의 타임픽', '프로필과 계정 관리 기능을 준비하고 있어요.'),
        ],
      ),
    ),
    bottomNavigationBar: AppNavigationBar(
      selectedIndex: _tabs.index,
      onDestinationSelected: _go,
    ),
  );
}
