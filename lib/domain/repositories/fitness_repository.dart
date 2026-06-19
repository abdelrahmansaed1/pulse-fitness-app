import 'package:pulse_fitness_app/domain/entities/step_entry.dart';
import 'package:pulse_fitness_app/domain/entities/water_entry.dart';

import '../entities/workout.dart';

abstract class FitnessRepository {
  // ── Workouts ──────────────────────────────────────────────────────────────

  Future<List<Workout>> getAllWorkouts();

  Future<List<Workout>> getWorkoutsForDate(DateTime date);

  Future<void> addWorkout(Workout workout);

  Future<void> deleteWorkout(String id);

  // Returns calories per day label for the last 7 days
  // e.g. { '10/6': 320.0, '11/6': 0.0, ... }
  Future<Map<String, double>> getWeeklyCalories();

  // ── Steps ─────────────────────────────────────────────────────────────────

  Future<StepEntry> getStepsForDate(DateTime date);

  Future<void> updateSteps(StepEntry entry);

  Future<Map<String, int>> getWeeklySteps();

  // ── Water ─────────────────────────────────────────────────────────────────

  Future<WaterEntry> getWaterForDate(DateTime date);

  Future<void> updateWater(WaterEntry entry);
}
