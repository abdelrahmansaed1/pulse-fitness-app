import 'package:pulse_fitness_app/domain/entities/workout.dart';

class WorkoutModel extends Workout {
  const WorkoutModel({
    required super.id,
    required super.activityType,
    required super.durationMinutes,
    required super.calories,
    required super.steps,
    required super.notes,
    required super.date,
  });

  // Domain entity → model
  factory WorkoutModel.fromEntity(Workout workout) {
    return WorkoutModel(
      id: workout.id,
      activityType: workout.activityType,
      durationMinutes: workout.durationMinutes,
      calories: workout.calories,
      steps: workout.steps,
      notes: workout.notes,
      date: workout.date,
    );
  }

  // DB row → model
  factory WorkoutModel.fromMap(Map<String, dynamic> map) {
    return WorkoutModel(
      id: map['id'] as String,
      activityType: map['activity_type'] as String,
      durationMinutes: map['duration_minutes'] as int,
      calories: (map['calories'] as num).toDouble(),
      steps: map['steps'] as int,
      notes: map['notes'] as String,
      date: DateTime.parse(map['date'] as String),
    );
  }

  // Model → DB row
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activity_type': activityType,
      'duration_minutes': durationMinutes,
      'calories': calories,
      'steps': steps,
      'notes': notes,
      'date': date.toIso8601String(),
    };
  }
}
