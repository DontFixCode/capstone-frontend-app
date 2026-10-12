import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_pick/models/reservation_search.dart';

void main() {
  ReservationSearch search(int start, int end, BookingService service) =>
      ReservationSearch(
        region: SearchRegion.nearby,
        date: DateTime(2030, 1, 2),
        start: TimeOfDay(hour: start, minute: 0),
        end: TimeOfDay(hour: end, minute: 0),
        service: service,
      );
  test(
    'Search rejects past, reversed and too short windows; slots fit duration',
    () {
      final now = DateTime(2030, 1, 2, 10);
      expect(search(9, 12, BookingService.haircut).validate(now), isNotNull);
      expect(search(18, 14, BookingService.haircut).validate(now), isNotNull);
      expect(search(12, 13, BookingService.coloring).validate(now), isNotNull);
      final valid = search(12, 14, BookingService.coloring);
      expect(valid.validate(now), isNull);
      expect(valid.exampleSlots, [
        const TimeOfDay(hour: 12, minute: 0),
        const TimeOfDay(hour: 12, minute: 30),
      ]);
    },
  );
}
