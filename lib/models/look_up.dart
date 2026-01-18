class LookUp {
  static final yearStart = DateTime(DateTime.now().year, 1, 1);
  static final currentDate = DateTime.now();

  static int daysInMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0).day;

  static final weeksInMonth = daysInMonth(currentDate) % 7;

  /// Days elapsed in current week (0-6)
  static int elapsedCurrentWeekDays() {
    return currentDate.weekday; // Monday=1, Sunday=7
  }

  /// Total days elapsed since start of year (0-based)
  static int elapsedDaysInYear() {
    return currentDate.difference(yearStart).inDays;
  }

  /// Current week number (0-based, 0-51)
  static int currentWeekOfYear() {
    return elapsedDaysInYear() ~/ 7;
  }

  /// Total days in current year
  static int totalDaysInYear() {
    final nextYear = DateTime(currentDate.year + 1, 1, 1);
    return nextYear.difference(yearStart).inDays;
  }

  static int daysLeftInYear() {
    final days = totalDaysInYear() - elapsedDaysInYear();
    return days;
  }

  static int dayPercent() {
    final percent = (((elapsedDaysInYear()) / totalDaysInYear()) * 100).toInt();
    print(percent);
    return percent;
  }
}
