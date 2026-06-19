import 'package:equatable/equatable.dart';

abstract class FitnessEvent extends Equatable {
  const FitnessEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodayData extends FitnessEvent {
  const LoadTodayData();
}

class UpdateSteps extends FitnessEvent {
  final int steps;
  const UpdateSteps(this.steps);

  @override
  List<Object?> get props => [steps];
}

class AddWater extends FitnessEvent {
  final int amountMl;
  const AddWater(this.amountMl);

  @override
  List<Object?> get props => [amountMl];
}

class LoadWeeklyData extends FitnessEvent {
  const LoadWeeklyData();
}
