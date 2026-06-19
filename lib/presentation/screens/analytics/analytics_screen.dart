import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse_fitness_app/presentation/blocs/fitness/fitness_bloc.dart';
import 'package:pulse_fitness_app/presentation/blocs/fitness/fitness_event.dart';
import 'package:pulse_fitness_app/presentation/blocs/fitness/fitness_state.dart';
import 'package:pulse_fitness_app/core/theme/app_colors.dart';
import 'package:pulse_fitness_app/core/theme/app_constants.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FitnessBloc, FitnessState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          appBar: AppBar(title: const Text('Analytics')),
          body: SafeArea(
            child: switch (state) {
              FitnessLoading() => const Center(
                child: CircularProgressIndicator(color: AppColors.volt),
              ),
              FitnessLoaded() => _AnalyticsBody(state: state),
              FitnessError() => Center(
                child: TextButton(
                  onPressed: () =>
                      context.read<FitnessBloc>().add(const LoadTodayData()),
                  child: const Text('Retry'),
                ),
              ),
              _ => const SizedBox.shrink(),
            },
          ),
        );
      },
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _AnalyticsBody extends StatefulWidget {
  final FitnessLoaded state;
  const _AnalyticsBody({required this.state});

  @override
  State<_AnalyticsBody> createState() => _AnalyticsBodyState();
}

class _AnalyticsBodyState extends State<_AnalyticsBody> {
  // 0 = calories, 1 = steps
  int _selectedChart = 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const SizedBox(height: 8),

        // ── Toggle ────────────────────────────────────────────────────────
        _ChartToggle(
          selected: _selectedChart,
          onChanged: (v) => setState(() => _selectedChart = v),
        ),

        const SizedBox(height: 24),

        // ── Chart ─────────────────────────────────────────────────────────
        _selectedChart == 0
            ? _CaloriesChart(data: widget.state.weeklyCalories)
            : _StepsChart(data: widget.state.weeklySteps),

        const SizedBox(height: 28),

        // ── Weekly summary cards ──────────────────────────────────────────
        Text(
          'Weekly Summary',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 14),
        _WeeklySummary(state: widget.state),

        const SizedBox(height: 100),
      ],
    );
  }
}

// ── Toggle ────────────────────────────────────────────────────────────────────

class _ChartToggle extends StatelessWidget {
  final int selected;
  final void Function(int) onChanged;

  const _ChartToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _ToggleBtn(
            label: '🔥 Calories',
            selected: selected == 0,
            onTap: () => onChanged(0),
          ),
          _ToggleBtn(
            label: '👟 Steps',
            selected: selected == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.volt : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.bgPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Calories Chart ────────────────────────────────────────────────────────────

class _CaloriesChart extends StatelessWidget {
  final Map<String, double> data;
  const _CaloriesChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    final maxVal = data.values.fold(0.0, (a, b) => a > b ? a : b);
    final today = '${DateTime.now().day}/${DateTime.now().month}';

    return _ChartCard(
      title: 'Calories Burned — Last 7 Days',
      unit: 'kcal',
      child: BarChart(
        BarChartData(
          maxY: (maxVal + 100).clamp(500, double.infinity),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 100,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: AppColors.border, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  final label = entries[idx].key;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10,
                        color: label == today
                            ? AppColors.volt
                            : AppColors.textMuted,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: entries.asMap().entries.map((e) {
            final isToday = e.value.key == today;
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.value,
                  width: 22,
                  color: isToday ? AppColors.volt : AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Steps Chart ───────────────────────────────────────────────────────────────

class _StepsChart extends StatelessWidget {
  final Map<String, int> data;
  const _StepsChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    final maxVal = data.values.fold(0, (a, b) => a > b ? a : b).toDouble();
    final today = '${DateTime.now().day}/${DateTime.now().month}';

    return _ChartCard(
      title: 'Steps — Last 7 Days',
      unit: 'steps',
      child: BarChart(
        BarChartData(
          maxY: (maxVal + 1000).clamp(
            AppConstants.defaultStepGoal.toDouble(),
            double.infinity,
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2000,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: AppColors.border, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  final label = entries[idx].key;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10,
                        color: label == today
                            ? AppColors.volt
                            : AppColors.textMuted,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: entries.asMap().entries.map((e) {
            final isToday = e.value.key == today;
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.value.toDouble(),
                  width: 22,
                  color: isToday ? AppColors.volt : AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Chart Card wrapper ────────────────────────────────────────────────────────

class _ChartCard extends StatelessWidget {
  final String title;
  final String unit;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.unit,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
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
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 24),
          SizedBox(height: 200, child: child),
        ],
      ),
    );
  }
}

// ── Weekly Summary ────────────────────────────────────────────────────────────

class _WeeklySummary extends StatelessWidget {
  final FitnessLoaded state;
  const _WeeklySummary({required this.state});

  @override
  Widget build(BuildContext context) {
    final totalCal = state.weeklyCalories.values.fold(0.0, (a, b) => a + b);
    final totalSteps = state.weeklySteps.values.fold(0, (a, b) => a + b);
    final avgSteps = totalSteps ~/ 7;
    final goalHit = state.weeklySteps.values
        .where((s) => s >= AppConstants.defaultStepGoal)
        .length;

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            emoji: '🔥',
            value: totalCal.toStringAsFixed(0),
            label: 'Total kcal',
            color: AppColors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            emoji: '👟',
            value: '${(totalSteps / 1000).toStringAsFixed(1)}k',
            label: 'Total steps',
            color: AppColors.volt,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            emoji: '🎯',
            value: '$goalHit/7',
            label: 'Goal days',
            color: AppColors.emerald,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;

  const _SummaryCard({
    required this.emoji,
    required this.value,
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
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
