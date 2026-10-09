enum Frequency {
  weekly(7),
  biWeekly(15),
  monthly(30);

  final int days;
  const Frequency(this.days);
}
