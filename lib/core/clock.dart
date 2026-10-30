/// Source of the current time. Injected instead of calling [DateTime.now] so date logic is testable.
abstract interface class Clock {
  DateTime now();
}

final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

final class FixedClock implements Clock {
  const FixedClock(this.instant);
  final DateTime instant;

  @override
  DateTime now() => instant;
}

extension CalendarDay on DateTime {
  /// 1-based day of the year. Computed in UTC so daylight-saving shifts can't drop or repeat a day.
  int get dayOfYear =>
      DateTime.utc(year, month, day).difference(DateTime.utc(year)).inDays + 1;

  int get daysInYear =>
      DateTime.utc(year + 1).difference(DateTime.utc(year)).inDays;
}
