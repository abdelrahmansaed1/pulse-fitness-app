import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse_fitness_app/domain/entities/step_entry.dart';
import 'package:pulse_fitness_app/domain/entities/water_entry.dart';
import 'package:pulse_fitness_app/domain/repositories/fitness_repository.dart';
import 'fitness_event.dart';
import 'fitness_state.dart';

class FitnessBloc extends Bloc<FitnessEvent, FitnessState> {
  final FitnessRepository _repository;

  FitnessBloc(this._repository) : super(const FitnessInitial()) {
    on<LoadTodayData>(_onLoadTodayData);
    on<UpdateSteps>(_onUpdateSteps);
    on<AddWater>(_onAddWater);
    on<LoadWeeklyData>(_onLoadWeeklyData);
  }

  Future<void> _onLoadTodayData(
    LoadTodayData event,
    Emitter<FitnessState> emit,
  ) async {
    emit(const FitnessLoading());
    try {
      final now = DateTime.now();
      final steps = await _repository.getStepsForDate(now);
      final water = await _repository.getWaterForDate(now);
      final workouts = await _repository.getWorkoutsForDate(now);
      final weekly = await _repository.getWeeklyCalories();
      final wSteps = await _repository.getWeeklySteps();

      final totalCal = workouts.fold<double>(0, (s, w) => s + w.calories);
      final totalMins = workouts.fold<int>(0, (s, w) => s + w.durationMinutes);

      emit(
        FitnessLoaded(
          todaySteps: steps.steps,
          todayWaterMl: water.amountMl,
          todayCalories: totalCal,
          todayDurationMins: totalMins,
          todayWorkouts: workouts,
          weeklyCalories: weekly,
          weeklySteps: wSteps,
        ),
      );
    } catch (e) {
      emit(FitnessError(e.toString()));
    }
  }

  Future<void> _onUpdateSteps(
    UpdateSteps event,
    Emitter<FitnessState> emit,
  ) async {
    final current = state;
    if (current is! FitnessLoaded) return;

    await _repository.updateSteps(
      StepEntry(date: DateTime.now(), steps: event.steps),
    );
    emit(current.copyWith(todaySteps: event.steps));
  }

  Future<void> _onAddWater(AddWater event, Emitter<FitnessState> emit) async {
    final current = state;
    if (current is! FitnessLoaded) return;

    final newAmount = current.todayWaterMl + event.amountMl;
    await _repository.updateWater(
      WaterEntry(date: DateTime.now(), amountMl: newAmount),
    );
    emit(current.copyWith(todayWaterMl: newAmount));
  }

  Future<void> _onLoadWeeklyData(
    LoadWeeklyData event,
    Emitter<FitnessState> emit,
  ) async {
    final current = state;
    if (current is! FitnessLoaded) return;

    final weekly = await _repository.getWeeklyCalories();
    final wSteps = await _repository.getWeeklySteps();
    emit(current.copyWith(weeklyCalories: weekly, weeklySteps: wSteps));
  }
}
