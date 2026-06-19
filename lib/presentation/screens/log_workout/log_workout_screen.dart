import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse_fitness_app/data/repositories/fitness_repository_impl.dart';
import 'package:pulse_fitness_app/domain/repositories/fitness_repository.dart';
import 'package:pulse_fitness_app/presentation/blocs/fitness/fitness_state.dart';
import 'package:uuid/uuid.dart';
import 'package:pulse_fitness_app/domain/entities/workout.dart';
import 'package:pulse_fitness_app/presentation/blocs/fitness/fitness_bloc.dart';
import 'package:pulse_fitness_app/presentation/blocs/fitness/fitness_event.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_constants.dart';

class LogWorkoutScreen extends StatefulWidget {
  const LogWorkoutScreen({super.key});

  @override
  State<LogWorkoutScreen> createState() => _LogWorkoutScreenState();
}

class _LogWorkoutScreenState extends State<LogWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _caloriesCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _stepsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _selectedType = AppConstants.activityTypes.first;
  bool _isSaving = false;
  late final FitnessRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = context.read<FitnessRepositoryImpl>();
  }

  @override
  void dispose() {
    _caloriesCtrl.dispose();
    _durationCtrl.dispose();
    _stepsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final workout = Workout(
      id: const Uuid().v4(),
      activityType: _selectedType,
      durationMinutes: int.parse(_durationCtrl.text.trim()),
      calories: double.parse(_caloriesCtrl.text.trim()),
      steps: int.tryParse(_stepsCtrl.text.trim()) ?? 0,
      notes: _notesCtrl.text.trim(),
      date: DateTime.now(),
    );

    // Save workout to DB
    await _repository.addWorkout(workout);

    if (mounted) {
      // If workout has steps, add them to today's step counter
      if (workout.steps > 0) {
        final fitnessBloc = context.read<FitnessBloc>();
        final currentState = fitnessBloc.state;
        final currentSteps = currentState is FitnessLoaded
            ? currentState.todaySteps
            : 0;
        fitnessBloc.add(UpdateSteps(currentSteps + workout.steps));
      }

      // Reload dashboard
      context.read<FitnessBloc>().add(const LoadTodayData());
    }

    if (mounted) {
      setState(() => _isSaving = false);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textPrimary,
            size: 32,
          ),
        ),
        title: const Text('Log Workout'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 20),
              child: CircularProgressIndicator(
                color: AppColors.volt,
                strokeWidth: 2,
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 8),

            // ── Activity type picker ─────────────────────────────────────────
            Text(
              'Activity Type',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: AppConstants.activityTypes.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final type = AppConstants.activityTypes[i];
                  final emoji = AppConstants.activityEmoji[type] ?? '💪';
                  final selected = type == _selectedType;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 80,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.volt : AppColors.bgCard,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: selected ? AppColors.volt : AppColors.border,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 26)),
                          const SizedBox(height: 6),
                          Text(
                            type,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? AppColors.bgPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            // ── Duration ─────────────────────────────────────────────────────
            _FieldLabel('Duration (minutes)'),
            const SizedBox(height: 8),
            _InputField(
              controller: _durationCtrl,
              hint: 'e.g. 45',
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (int.tryParse(v) == null) return 'Enter a valid number';
                if (int.parse(v) <= 0) return 'Must be greater than 0';
                return null;
              },
            ),

            const SizedBox(height: 20),

            // ── Calories ─────────────────────────────────────────────────────
            _FieldLabel('Calories Burned'),
            const SizedBox(height: 8),
            _InputField(
              controller: _caloriesCtrl,
              hint: 'e.g. 320',
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (double.tryParse(v) == null) return 'Enter a valid number';
                if (double.parse(v) < 0) return 'Cannot be negative';
                return null;
              },
            ),

            const SizedBox(height: 20),

            // ── Steps ─────────────────────────────────────────────────────────
            _FieldLabel('Steps (optional)'),
            const SizedBox(height: 8),
            _InputField(
              controller: _stepsCtrl,
              hint: 'e.g. 3000',
              keyboardType: TextInputType.number,
              validator: (_) => null,
            ),

            const SizedBox(height: 20),

            // ── Notes ─────────────────────────────────────────────────────────
            _FieldLabel('Notes (optional)'),
            const SizedBox(height: 8),
            _InputField(
              controller: _notesCtrl,
              hint: 'How did it feel?',
              maxLines: 3,
              validator: (_) => null,
            ),

            const SizedBox(height: 36),

            // ── Save button ───────────────────────────────────────────────────
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: const Text('Save Workout'),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Shared form widgets ───────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.labelLarge);
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final String? Function(String?) validator;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(hintText: hint),
      validator: validator,
    );
  }
}
