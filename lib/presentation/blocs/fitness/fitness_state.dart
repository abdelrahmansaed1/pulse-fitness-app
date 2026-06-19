import 'package:equatable/equatable.dart';
import 'package:pulse_fitness_app/domain/entities/workout.dart';

abstract class FitnessState extends Equatable {
  const FitnessState();

  @override
  List<Object?> get props => [];
}

class FitnessInitial extends FitnessState {
  const FitnessInitial();
}

class FitnessLoading extends FitnessState {
  const FitnessLoading();
}

class FitnessLoaded extends FitnessState {
  final int todaySteps;
  final int todayWaterMl;
  final double todayCalories;
  final int todayDurationMins;
  final List<Workout> todayWorkouts;
  final Map<String, double> weeklyCalories;
  final Map<String, int> weeklySteps;

  const FitnessLoaded({
    required this.todaySteps,
    required this.todayWaterMl,
    required this.todayCalories,
    required this.todayDurationMins,
    required this.todayWorkouts,
    required this.weeklyCalories,
    required this.weeklySteps,
  });

  FitnessLoaded copyWith({
    int? todaySteps,
    int? todayWaterMl,
    double? todayCalories,
    int? todayDurationMins,
    List<Workout>? todayWorkouts,
    Map<String, double>? weeklyCalories,
    Map<String, int>? weeklySteps,
  }) {
    return FitnessLoaded(
      todaySteps: todaySteps ?? this.todaySteps,
      todayWaterMl: todayWaterMl ?? this.todayWaterMl,
      todayCalories: todayCalories ?? this.todayCalories,
      todayDurationMins: todayDurationMins ?? this.todayDurationMins,
      todayWorkouts: todayWorkouts ?? this.todayWorkouts,
      weeklyCalories: weeklyCalories ?? this.weeklyCalories,
      weeklySteps: weeklySteps ?? this.weeklySteps,
    );
  }

  @override
  List<Object?> get props => [
    todaySteps,
    todayWaterMl,
    todayCalories,
    todayDurationMins,
    todayWorkouts,
    weeklyCalories,
    weeklySteps,
  ];
}

class FitnessError extends FitnessState {
  final String message;
  const FitnessError(this.message);

  @override
  List<Object?> get props => [message];
}
