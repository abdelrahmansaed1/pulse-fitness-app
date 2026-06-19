import 'package:equatable/equatable.dart';
import 'package:pulse_fitness_app/domain/entities/workout.dart';

abstract class WorkoutState extends Equatable {
  const WorkoutState();

  @override
  List<Object?> get props => [];
}

class WorkoutInitial extends WorkoutState {
  const WorkoutInitial();
}

class WorkoutLoading extends WorkoutState {
  const WorkoutLoading();
}

class WorkoutLoaded extends WorkoutState {
  final List<Workout> workouts;
  const WorkoutLoaded(this.workouts);

  @override
  List<Object?> get props => [workouts];
}

class WorkoutError extends WorkoutState {
  final String message;
  const WorkoutError(this.message);

  @override
  List<Object?> get props => [message];
}
