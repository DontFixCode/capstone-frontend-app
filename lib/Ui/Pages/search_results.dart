import 'package:flutter/material.dart';

import '../../models/reservation_search.dart';
import '../theme/app_theme.dart';

class SearchResults extends StatelessWidget {
  const SearchResults({
    super.key,
    required this.search,
    required this.onEdit,
    required this.onMap,
    required this.onDetails,
  });
  final ReservationSearch search;
  final VoidCallback onEdit;
  final VoidCallback onMap;
  final void Function(String name, String region) onDetails;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    key: const PageStorageKey('search-results'),
    padding: const EdgeInsets.all(24),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '내 시간에 맞는 예약',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.secondary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(search.summary, style: const TextStyle(height: 1.8)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    children: [
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.tune),
                        label: const Text('조건 수정'),
                      ),
                      TextButton.icon(
                        onPressed: onMap,
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('지도 보기'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              '예시 결과',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              '화면 미리보기용 정보입니다. 실제 예약 가능 시간과 가격은 아직 제공되지 않아요.',
              style: TextStyle(color: Color(0xFF64748B), height: 1.6),
            ),
            const SizedBox(height: 18),
            for (final entry in ['타임 스튜디오', '온유 살롱'].indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppTheme.secondary),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '${entry.$2} · 예시',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${search.region.label} · ${search.service.label}',
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        '${(search.service.examplePrice + entry.$1 * 5000) ~/ 1000},000원 · ${search.service.minutes}분',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        '시작 시각 예시',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final slot in search.exampleSlots)
                            Chip(
                              label: Text(clockLabel(slot)),
                              backgroundColor: AppTheme.background,
                              side: BorderSide.none,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () =>
                            onDetails(entry.$2, search.region.label),
                        child: const Text('업체 정보 보기'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
