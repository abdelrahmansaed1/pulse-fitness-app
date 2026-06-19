class WaterEntry {
  final DateTime date;
  final int amountMl;

  const WaterEntry({required this.date, required this.amountMl});

  double get amountL => amountMl / 1000;
}
