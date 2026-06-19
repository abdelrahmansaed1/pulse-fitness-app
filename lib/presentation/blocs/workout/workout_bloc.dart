// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:pulse_fitness_app/domain/repositories/fitness_repository.dart';
// import 'workout_event.dart';
// import 'workout_state.dart';

// class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
//   final FitnessRepository _repository;

//   WorkoutBloc(this._repository) : super(const WorkoutInitial()) {
//     on<LoadWorkouts>(_onLoadWorkouts);
//     on<AddWorkout>(_onAddWorkout);
//     on<DeleteWorkout>(_onDeleteWorkout);
//   }

//   Future<void> _onLoadWorkouts(
//     LoadWorkouts event,
//     Emitter<WorkoutState> emit,
//   ) async {
//     emit(const WorkoutLoading());
//     try {
//       final workouts = await _repository.getAllWorkouts();
//       emit(WorkoutLoaded(workouts));
//     } catch (e) {
//       emit(WorkoutError(e.toString()));
//     }
//   }

//   // Future<void> _onAddWorkout(
//   //   AddWorkout event,
//   //   Emitter<WorkoutState> emit,
//   // ) async {
//   //   final current = state;
//   //   if (current is! WorkoutLoaded) return;

//   //   await _repository.addWorkout(event.workout);
//   //   final updated = [event.workout, ...current.workouts];
//   //   emit(WorkoutLoaded(updated));
//   // }

//   Future<void> _onAddWorkout(
//     AddWorkout event,
//     Emitter<WorkoutState> emit,
//   ) async {
//     final current = state;
//     if (current is! WorkoutLoaded) return;

//     try {
//       // Await the DB write first
//       await _repository.addWorkout(event.workout);
//       final updated = [event.workout, ...current.workouts];
//       emit(WorkoutLoaded(updated));
//     } catch (e) {
//       emit(WorkoutError(e.toString()));
//     }
//   }

//   Future<void> _onDeleteWorkout(
//     DeleteWorkout event,
//     Emitter<WorkoutState> emit,
//   ) async {
//     final current = state;
//     if (current is! WorkoutLoaded) return;

//     await _repository.deleteWorkout(event.id);
//     final updated = current.workouts.where((w) => w.id != event.id).toList();
//     emit(WorkoutLoaded(updated));
//   }
// }
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse_fitness_app/domain/repositories/fitness_repository.dart';
import 'workout_event.dart';
import 'workout_state.dart';

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  final FitnessRepository _repository;

  WorkoutBloc(this._repository) : super(const WorkoutInitial()) {
    on<LoadWorkouts>(_onLoadWorkouts);
    on<AddWorkout>(_onAddWorkout);
    on<DeleteWorkout>(_onDeleteWorkout);
  }

  Future<void> _onLoadWorkouts(
    LoadWorkouts event,
    Emitter<WorkoutState> emit,
  ) async {
    emit(const WorkoutLoading());
    try {
      final workouts = await _repository.getAllWorkouts();
      emit(WorkoutLoaded(workouts));
    } catch (e) {
      emit(WorkoutError(e.toString()));
    }
  }

  Future<void> _onAddWorkout(
    AddWorkout event,
    Emitter<WorkoutState> emit,
  ) async {
    try {
      // Save to DB — no state guard, always execute
      await _repository.addWorkout(event.workout);

      // Reload all workouts fresh from DB
      final workouts = await _repository.getAllWorkouts();
      emit(WorkoutLoaded(workouts));
    } catch (e) {
      emit(WorkoutError(e.toString()));
    }
  }

  Future<void> _onDeleteWorkout(
    DeleteWorkout event,
    Emitter<WorkoutState> emit,
  ) async {
    try {
      await _repository.deleteWorkout(event.id);
      final workouts = await _repository.getAllWorkouts();
      emit(WorkoutLoaded(workouts));
    } catch (e) {
      emit(WorkoutError(e.toString()));
    }
  }
}
