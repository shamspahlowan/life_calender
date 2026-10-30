import 'package:flutter_test/flutter_test.dart';
import 'package:resonance/core/clock.dart';

void main() {
  group('CalendarDay', () {
    test('Jan 1 is day 1', () {
      expect(DateTime(2026).dayOfYear, 1);
    });

    test('31 October 2026 is day 304, matching the engine', () {
      expect(DateTime(2026, 10, 31).dayOfYear, 304);
    });

    test('leap years have 366 days and Dec 31 is the last', () {
      expect(DateTime(2028).daysInYear, 366);
      expect(DateTime(2028, 3, 1).dayOfYear, 61);
      expect(DateTime(2028, 12, 31).dayOfYear, 366);
    });

    test('ignores the time of day', () {
      expect(
        DateTime(2026, 3, 29, 23, 59).dayOfYear,
        DateTime(2026, 3, 29).dayOfYear,
      );
    });
  });
}
