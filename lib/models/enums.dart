enum frequency {
  weekly(7),
  biWeekly(15),
  monthly(30);

  final int days;
  const frequency(this.days);
}
