import 'package:flutter/material.dart';

import '../../models/reservation_search.dart';
import '../theme/app_theme.dart';

class BookingSearchForm extends StatelessWidget {
  const BookingSearchForm({
    super.key,
    required this.search,
    required this.onChanged,
    required this.onSearch,
  });

  final ReservationSearch search;
  final ValueChanged<ReservationSearch> onChanged;
  final VoidCallback onSearch;

  void _change({
    DateTime? date,
    TimeOfDay? start,
    TimeOfDay? end,
    BookingService? service,
  }) => onChanged(
    ReservationSearch(
      region: search.region,
      date: date ?? search.date,
      start: start ?? search.start,
      end: end ?? search.end,
      service: service ?? search.service,
    ),
  );

  Widget _field(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 12),
      Semantics(
        label: label,
        button: true,
        child: Material(
          color: AppTheme.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppTheme.secondary),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Text(value, style: const TextStyle(fontSize: 17)),
                  ),
                  const SizedBox(width: 6),
                  Icon(icon, size: 19, color: const Color(0xFF64748B)),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );

  Future<void> _time(BuildContext context, bool start) async {
    final value = await showTimePicker(
      context: context,
      initialTime: start ? search.start : search.end,
      helpText: start ? '시작 시간 선택' : '종료 시간 선택',
    );
    if (value != null) {
      _change(start: start ? value : null, end: start ? null : value);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
      border: Border.all(color: AppTheme.secondary),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _field(
          context,
          '이용할 날짜',
          search.dateLabel,
          Icons.calendar_today_outlined,
          () async {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final date = await showDatePicker(
              context: context,
              initialDate: search.date.isBefore(today) ? today : search.date,
              firstDate: today,
              lastDate: today.add(const Duration(days: 365)),
              helpText: '이용할 날짜 선택',
            );
            if (date != null) _change(date: date);
          },
        ),
        const SizedBox(height: 26),
        LayoutBuilder(
          builder: (context, constraints) {
            final start = _field(
              context,
              '이 시간부터',
              clockLabel(search.start),
              Icons.schedule,
              () => _time(context, true),
            );
            final end = _field(
              context,
              '이 시간까지',
              clockLabel(search.end),
              Icons.schedule,
              () => _time(context, false),
            );
            if (constraints.maxWidth < 280 ||
                MediaQuery.textScalerOf(context).scale(17) > 24) {
              return Column(children: [start, const SizedBox(height: 20), end]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: start),
                const SizedBox(width: 14),
                Expanded(child: end),
              ],
            );
          },
        ),
        const SizedBox(height: 26),
        const Text(
          '어떤 서비스가 필요하세요?',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<BookingService>(
          key: ValueKey(search.service),
          initialValue: search.service,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.secondary),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          items: [
            for (final service in BookingService.values)
              DropdownMenuItem(value: service, child: Text(service.label)),
          ],
          onChanged: (value) {
            if (value != null) _change(service: value);
          },
        ),
        const SizedBox(height: 8),
        Text(
          '예상 소요 ${search.service.minutes}분 · 업체별로 달라질 수 있어요',
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final preset in [
              ('점심시간', 12, 14),
              ('오후', 14, 18),
              ('퇴근 후', 18, 21),
            ])
              ChoiceChip(
                label: Text(preset.$1),
                selected:
                    search.start == TimeOfDay(hour: preset.$2, minute: 0) &&
                    search.end == TimeOfDay(hour: preset.$3, minute: 0),
                showCheckmark: false,
                selectedColor: AppTheme.secondary,
                backgroundColor: AppTheme.background,
                side: BorderSide.none,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                onSelected: (_) => _change(
                  start: TimeOfDay(hour: preset.$2, minute: 0),
                  end: TimeOfDay(hour: preset.$3, minute: 0),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onSearch,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              '이 시간에 예약 찾기',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    ),
  );
}
