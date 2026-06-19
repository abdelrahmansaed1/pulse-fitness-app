class Workout {
  final String id;
  final String activityType;
  final int durationMinutes;
  final double calories;
  final int steps;
  final String notes;
  final DateTime date;

  const Workout({
    required this.id,
    required this.activityType,
    required this.durationMinutes,
    required this.calories,
    required this.steps,
    required this.notes,
    required this.date,
  });

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
