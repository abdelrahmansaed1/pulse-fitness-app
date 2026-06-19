import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pulse_fitness_app/core/theme/app_colors.dart';
import 'package:pulse_fitness_app/core/theme/app_constants.dart';
import 'package:pulse_fitness_app/presentation/blocs/fitness/fitness_bloc.dart';
import 'package:pulse_fitness_app/presentation/blocs/fitness/fitness_event.dart';
import 'package:pulse_fitness_app/presentation/blocs/workout/workout_bloc.dart';
import 'package:pulse_fitness_app/presentation/blocs/workout/workout_event.dart';
import 'package:pulse_fitness_app/presentation/blocs/workout/workout_state.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WorkoutBloc>().add(const LoadWorkouts());
  }

  static const Map<String, String> _activityEmojis = {
    'Running': '🏃',
    'Cycling': '🚴',
    'Gym': '🏋️',
    'Yoga': '🧘',
    'Swimming': '🏊',
    'Walking': '🚶',
    'Other': '💪',
  };

  String _getActivityEmoji(String activityType) {
    return _activityEmojis[activityType] ?? '💪';
  }

  Map<String, dynamic> _groupWorkoutsByDate(List<dynamic> workouts) {
    final Map<String, List<dynamic>> grouped = {};

    for (var workout in workouts) {
      final dateKey = DateFormat('EEEE, MMM d · yyyy').format(workout.date);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(workout);
    }

    return grouped;
  }

  void _confirmDelete(BuildContext context, String workoutId) {
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'Delete Workout',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this workout?',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<WorkoutBloc>().add(DeleteWorkout(workoutId));
              context.read<FitnessBloc>().add(const LoadTodayData());
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppColors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: AppColors.bgPrimary,
      ),
      body: BlocBuilder<WorkoutBloc, WorkoutState>(
        builder: (context, state) {
          if (state is WorkoutLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.volt),
            );
          }

          if (state is WorkoutError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          if (state is WorkoutLoaded) {
            if (state.workouts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🏃', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text(
                      'No workouts yet',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontFamily: 'PlusJakartaSans',
                            color: AppColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start logging your fitness journey',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'PlusJakartaSans',
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            final grouped = _groupWorkoutsByDate(state.workouts);
            final sortedDates = grouped.keys.toList();

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: sortedDates.length,
              itemBuilder: (context, dateIndex) {
                final dateKey = sortedDates[dateIndex];
                final workoutsForDate = grouped[dateKey]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date header with volt dot
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.volt,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            dateKey,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  fontFamily: 'PlusJakartaSans',
                                  color: AppColors.textPrimary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    // Workouts for this date
                    ...List.generate(workoutsForDate.length, (workoutIndex) {
                      final workout = workoutsForDate[workoutIndex];
                      return Dismissible(
                        key: Key(workout.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (direction) {
                          _confirmDelete(context, workout.id);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Activity type & duration
                              Row(
                                children: [
                                  Text(
                                    _getActivityEmoji(workout.activityType),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          workout.activityType,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                fontFamily: 'PlusJakartaSans',
                                                color: AppColors.textPrimary,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${workout.durationMinutes} min',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                fontFamily: 'PlusJakartaSans',
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    DateFormat('h:mm a').format(workout.date),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          fontFamily: 'PlusJakartaSans',
                                          color: AppColors.textMuted,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Stats row
                              Row(
                                children: [
                                  // Calories
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.bgElevated,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '🔥 ${workout.calories.toStringAsFixed(0)} kcal',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Steps (if > 0)
                                  if (workout.steps > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.bgElevated,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '👟 ${workout.steps} steps',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontFamily: 'PlusJakartaSans',
                                              fontSize: 11,
                                              color: AppColors.textSecondary,
                                            ),
                                      ),
                                    ),
                                ],
                              ),
                              // Notes (if not empty)
                              if (workout.notes.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  workout.notes,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        fontFamily: 'PlusJakartaSans',
                                        color: AppColors.textSecondary,
                                        fontStyle: FontStyle.italic,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            );
          }

          return const Center(child: Text('No data'));
        },
      ),
    );
  }
}
