import 'package:pulse_fitness_app/data/datasources/local_datasource.dart';
import 'package:pulse_fitness_app/data/models/workout_model.dart';
import 'package:pulse_fitness_app/domain/entities/step_entry.dart';
import 'package:pulse_fitness_app/domain/entities/water_entry.dart';
import 'package:pulse_fitness_app/domain/entities/workout.dart';
import 'package:pulse_fitness_app/domain/repositories/fitness_repository.dart';

class FitnessRepositoryImpl implements FitnessRepository {
  final LocalDatasource _datasource;

  FitnessRepositoryImpl(this._datasource);
  @override
  Future<void> addWorkout(Workout workout) async {
    final model = WorkoutModel.fromEntity(workout);
    await _datasource.insertWorkout(model.toMap());
  }

  @override
  Future<void> deleteWorkout(String id) async {
    await _datasource.deleteWorkout(id);
  }

  @override
  Future<List<Workout>> getAllWorkouts() async {
    final rows = await _datasource.queryAllWorkouts();
    return rows.map(WorkoutModel.fromMap).toList();
  }

  @override
  Future<List<Workout>> getWorkoutsForDate(DateTime date) async {
    final start = _startOfDay(date);
    final end = _endOfDay(date);
    final rows = await _datasource.queryWorkoutsByDateRange(start, end);
    return rows.map(WorkoutModel.fromMap).toList();
  }

  @override
  Future<Map<String, double>> getWeeklyCalories() async {
    final result = <String, double>{};
    for (int i = 6; i >= 0; i--) {
      final day = DateTime.now().subtract(Duration(days: i));
      final start = _startOfDay(day);
      final end = _endOfDay(day);
      final rows = await _datasource.queryWorkoutsByDateRange(start, end);

      final total = rows.fold<double>(
        0.0,
        (sum, row) => sum + (row['calories'] as num).toDouble(),
      );

      result[_dayLabel(day)] = total;
    }

    return result;
  }

  // ── Steps ─────────────────────────────────────────────────────────────────

  @override
  Future<StepEntry> getStepsForDate(DateTime date) async {
    final row = await _datasource.querySteps(_dateKey(date));
    return StepEntry(date: date, steps: row == null ? 0 : row['steps'] as int);
  }

  @override
  Future<void> updateSteps(StepEntry entry) async {
    await _datasource.upsertSteps(_dateKey(entry.date), entry.steps);
  }

  @override
  Future<Map<String, int>> getWeeklySteps() async {
    final days = List.generate(
      7,
      (i) => DateTime.now().subtract(Duration(days: 6 - i)),
    );
    final keys = days.map(_dateKey).toList();
    final rows = await _datasource.queryStepsRange(keys);
    final rowMap = {
      for (final r in rows) r['date'] as String: r['steps'] as int,
    };

    return {for (final d in days) _dayLabel(d): rowMap[_dateKey(d)] ?? 0};
  }

  // ── Water ─────────────────────────────────────────────────────────────────

  @override
  Future<WaterEntry> getWaterForDate(DateTime date) async {
    final row = await _datasource.queryWater(_dateKey(date));
    return WaterEntry(
      date: date,
      amountMl: row == null ? 0 : row['amount_ml'] as int,
    );
  }

  @override
  Future<void> updateWater(WaterEntry entry) async {
    await _datasource.upsertWater(_dateKey(entry.date), entry.amountMl);
  }
  // ── Private helpers ───────────────────────────────────────────────────────

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _dayLabel(DateTime d) => '${d.day}/${d.month}';

  String _startOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day).toIso8601String();

  String _endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59).toIso8601String();
}
