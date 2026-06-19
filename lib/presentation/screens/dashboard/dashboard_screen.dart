import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pulse_fitness_app/domain/entities/workout.dart';
import 'package:pulse_fitness_app/presentation/blocs/fitness/fitness_bloc.dart';
import 'package:pulse_fitness_app/presentation/blocs/fitness/fitness_event.dart';
import 'package:pulse_fitness_app/presentation/blocs/fitness/fitness_state.dart';
import 'package:pulse_fitness_app/core/theme/app_constants.dart';

import '../../../core/theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FitnessBloc, FitnessState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          body: SafeArea(
            child: switch (state) {
              FitnessLoading() => const Center(
                child: CircularProgressIndicator(color: AppColors.volt),
              ),
              FitnessLoaded() => _DashboardBody(state: state),
              FitnessError() => _ErrorBody(
                message: state.message,
                onRetry: () =>
                    context.read<FitnessBloc>().add(const LoadTodayData()),
              ),
              _ => const SizedBox.shrink(),
            },
          ),
        );
      },
    );
  }
}

// ── Body ─────────────────────────────────────────────────────────────────────

class _DashboardBody extends StatelessWidget {
  final FitnessLoaded state;
  const _DashboardBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.volt,
      onRefresh: () async =>
          context.read<FitnessBloc>().add(const LoadTodayData()),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 16),
          _Header(),
          const SizedBox(height: 28),
          _StepRing(state: state),
          const SizedBox(height: 24),
          _StatRow(state: state),
          const SizedBox(height: 24),
          _WaterCard(state: state),
          const SizedBox(height: 24),
          _TodayWorkouts(workouts: state.todayWorkouts),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEEE, MMM d').format(DateTime.now());
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good ${_greeting()} 👋',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Today\'s Summary',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 2),
            Text(date, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.volt,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(child: Text('⚡', style: TextStyle(fontSize: 22))),
        ),
      ],
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }
}

// ── Step Ring ─────────────────────────────────────────────────────────────────

class _StepRing extends StatelessWidget {
  final FitnessLoaded state;
  const _StepRing({required this.state});

  @override
  Widget build(BuildContext context) {
    final goal = AppConstants.defaultStepGoal;
    final percent = (state.todaySteps / goal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 110,
            lineWidth: 14,
            percent: percent,
            animation: true,
            animationDuration: 1000,
            circularStrokeCap: CircularStrokeCap.round,
            backgroundColor: AppColors.bgElevated,
            progressColor: AppColors.volt,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  NumberFormat('#,###').format(state.todaySteps),
                  style: Theme.of(
                    context,
                  ).textTheme.displayMedium?.copyWith(color: AppColors.volt),
                ),
                const SizedBox(height: 4),
                Text('steps', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.voltGlow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(percent * 100).toStringAsFixed(0)}% of goal',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.volt,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Row ──────────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  final FitnessLoaded state;
  const _StatRow({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: '🔥',
            value: state.todayCalories.toStringAsFixed(0),
            unit: 'kcal',
            label: 'Burned',
            color: AppColors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: '⏱',
            value: '${state.todayDurationMins}',
            unit: 'min',
            label: 'Active',
            color: AppColors.cyan,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: '🏋️',
            value: '${state.todayWorkouts.length}',
            unit: '',
            label: 'Workouts',
            color: AppColors.volt,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String unit;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

// ── Water Card ────────────────────────────────────────────────────────────────

class _WaterCard extends StatelessWidget {
  final FitnessLoaded state;
  const _WaterCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final goalMl = (AppConstants.defaultWaterGoalL * 1000).toInt();
    final percent = (state.todayWaterMl / goalMl).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('💧', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    'Hydration',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
              Text(
                '${(state.todayWaterMl / 1000).toStringAsFixed(1)}L / ${AppConstants.defaultWaterGoalL}L',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: AppColors.bgElevated,
              valueColor: const AlwaysStoppedAnimation(AppColors.cyan),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [150, 250, 500].map((ml) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () => context.read<FitnessBloc>().add(AddWater(ml)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      '+${ml}ml',
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cyan,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Today Workouts ────────────────────────────────────────────────────────────

class _TodayWorkouts extends StatelessWidget {
  final List<Workout> workouts;
  const _TodayWorkouts({required this.workouts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Workouts",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 14),
        if (workouts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Text('🏃', style: TextStyle(fontSize: 36)),
                const SizedBox(height: 12),
                Text(
                  'No workouts yet',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap + to log your first workout',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          )
        else
          ...workouts.map((w) => _WorkoutTile(workout: w)),
      ],
    );
  }
}

class _WorkoutTile extends StatelessWidget {
  final Workout workout;
  const _WorkoutTile({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                AppConstants.activityEmoji[workout.activityType] ?? '💪',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.activityType,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  '${workout.durationMinutes} min  ·  ${workout.calories.toStringAsFixed(0)} kcal',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.voltGlow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              DateFormat('HH:mm').format(workout.date),
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.volt,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('😓', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
