import 'package:equatable/equatable.dart';
import 'package:pulse_fitness_app/domain/entities/workout.dart';

abstract class WorkoutEvent extends Equatable {
  const WorkoutEvent();

  @override
  List<Object?> get props => [];
}

class LoadWorkouts extends WorkoutEvent {
  const LoadWorkouts();
}

class AddWorkout extends WorkoutEvent {
  final Workout workout;
  const AddWorkout(this.workout);

  @override
  List<Object?> get props => [workout];
}

class DeleteWorkout extends WorkoutEvent {
  final String id;
  const DeleteWorkout(this.id);

  @override
  List<Object?> get props => [id];
}
