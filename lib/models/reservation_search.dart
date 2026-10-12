import 'package:flutter/material.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';

enum SearchRegion {
  nearby('현재 위치 주변', null),
  daejeon('대전 서구', LatLng(36.3553, 127.3838)),
  seoul('서울 강남구', LatLng(37.5172, 127.0473)),
  busan('부산 연제구', LatLng(35.1762, 129.0797)),
  incheon('인천 남동구', LatLng(37.4473, 126.7315));

  const SearchRegion(this.label, this.center);
  final String label;
  final LatLng? center;
}

enum BookingService {
  haircut('헤어 · 커트', 30, 25000),
  coloring('헤어 · 염색', 90, 80000),
  perm('헤어 · 펌', 120, 100000),
  nail('네일 · 기본 케어', 60, 40000);

  const BookingService(this.label, this.minutes, this.examplePrice);
  final String label;
  final int minutes;
  final int examplePrice;
}

String clockLabel(TimeOfDay time) =>
    '${time.hour < 12 ? '오전' : '오후'} ${time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod}:${time.minute.toString().padLeft(2, '0')}';

class ReservationSearch {
  const ReservationSearch({
    required this.region,
    required this.date,
    required this.start,
    required this.end,
    required this.service,
  });

  final SearchRegion region;
  final DateTime date;
  final TimeOfDay start;
  final TimeOfDay end;
  final BookingService service;

  int get startMinutes => start.hour * 60 + start.minute;
  int get endMinutes => end.hour * 60 + end.minute;
  String get dateLabel =>
      '${date.year}. ${date.month.toString().padLeft(2, '0')}. ${date.day.toString().padLeft(2, '0')}.';
  String get summary =>
      '$dateLabel · ${clockLabel(start)}–${clockLabel(end)}\n${region.label} · ${service.label}';

  String? validate(DateTime now) {
    if (endMinutes <= startMinutes) return '종료 시간은 시작 시간보다 늦게 선택해 주세요.';
    if (endMinutes - startMinutes < service.minutes) {
      return '${service.label}는 약 ${service.minutes}분이 필요해요. 시간 범위를 넓혀 주세요.';
    }
    final startDate = DateTime(
      date.year,
      date.month,
      date.day,
      start.hour,
      start.minute,
    );
    if (!startDate.isAfter(now)) return '현재 시간 이후로 날짜와 시작 시간을 선택해 주세요.';
    return null;
  }

  // Demo slots only. Replace with server availability when booking is connected.
  List<TimeOfDay> get exampleSlots => [
    for (
      var minute = startMinutes;
      minute + service.minutes <= endMinutes && minute < startMinutes + 90;
      minute += 30
    )
      TimeOfDay(hour: minute ~/ 60, minute: minute % 60),
  ];
}
