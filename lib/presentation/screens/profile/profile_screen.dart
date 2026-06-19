import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse_fitness_app/core/theme/app_colors.dart';
import 'package:pulse_fitness_app/core/theme/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pulse_fitness_app/presentation/blocs/fitness/fitness_bloc.dart';
import 'package:pulse_fitness_app/presentation/blocs/fitness/fitness_event.dart';
import 'package:pulse_fitness_app/presentation/blocs/fitness/fitness_state.dart';
import 'package:pulse_fitness_app/data/datasources/local_datasource.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _stepCtrl = TextEditingController();
  final _calorieCtrl = TextEditingController();
  final _waterCtrl = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _stepCtrl.dispose();
    _calorieCtrl.dispose();
    _waterCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameCtrl.text = prefs.getString(AppConstants.keyUserName) ?? '';
      _stepCtrl.text =
          (prefs.getInt(AppConstants.keyStepGoal) ??
                  AppConstants.defaultStepGoal)
              .toString();
      _calorieCtrl.text =
          (prefs.getDouble(AppConstants.keyCalGoal) ??
                  AppConstants.defaultCalorieGoal)
              .toString();
      _waterCtrl.text =
          (prefs.getDouble(AppConstants.keyWaterGoal) ??
                  AppConstants.defaultWaterGoalL)
              .toString();
      _isLoading = false;
    });
  }

  Future<void> _savePrefs() async {
    setState(() => _isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserName, _nameCtrl.text.trim());
    await prefs.setInt(
      AppConstants.keyStepGoal,
      int.tryParse(_stepCtrl.text.trim()) ?? AppConstants.defaultStepGoal,
    );
    await prefs.setDouble(
      AppConstants.keyCalGoal,
      double.tryParse(_calorieCtrl.text.trim()) ??
          AppConstants.defaultCalorieGoal,
    );
    await prefs.setDouble(
      AppConstants.keyWaterGoal,
      double.tryParse(_waterCtrl.text.trim()) ?? AppConstants.defaultWaterGoalL,
    );

    // Reload dashboard with updated goals
    if (mounted) {
      context.read<FitnessBloc>().add(const LoadTodayData());
    }

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '✅ Goals saved',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppColors.bgElevated,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(title: const Text('Profile')),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.volt),
            )
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 8),

                  // ── Avatar ─────────────────────────────────────────────────
                  _AvatarSection(nameCtrl: _nameCtrl),

                  const SizedBox(height: 32),

                  // ── Stats strip ────────────────────────────────────────────
                  BlocBuilder<FitnessBloc, FitnessState>(
                    builder: (context, state) {
                      if (state is! FitnessLoaded)
                        return const SizedBox.shrink();
                      return _StatsStrip(state: state);
                    },
                  ),

                  const SizedBox(height: 32),

                  // ── Goals section ──────────────────────────────────────────
                  Text(
                    'Daily Goals',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),

                  _GoalTile(
                    emoji: '👟',
                    label: 'Step Goal',
                    controller: _stepCtrl,
                    unit: 'steps',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  _GoalTile(
                    emoji: '🔥',
                    label: 'Calorie Goal',
                    controller: _calorieCtrl,
                    unit: 'kcal',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  _GoalTile(
                    emoji: '💧',
                    label: 'Water Goal',
                    controller: _waterCtrl,
                    unit: 'L',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Save button ────────────────────────────────────────────
                  ElevatedButton(
                    onPressed: _isSaving ? null : _savePrefs,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.bgPrimary,
                            ),
                          )
                        : const Text('Save Goals'),
                  ),

                  const SizedBox(height: 24),
                  _ResetButton(),
                  const SizedBox(height: 12),

                  // ── App info ───────────────────────────────────────────────
                  _AppInfo(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────

class _AvatarSection extends StatelessWidget {
  final TextEditingController nameCtrl;
  const _AvatarSection({required this.nameCtrl});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.volt,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Center(child: Text('⚡', style: TextStyle(fontSize: 32))),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Name', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 6),
              TextFormField(
                controller: nameCtrl,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Stats Strip ───────────────────────────────────────────────────────────────

class _StatsStrip extends StatelessWidget {
  final FitnessLoaded state;
  const _StatsStrip({required this.state});

  @override
  Widget build(BuildContext context) {
    final totalWeeklySteps = state.weeklySteps.values.fold(0, (a, b) => a + b);
    final totalWeeklyCal = state.weeklyCalories.values.fold(
      0.0,
      (a, b) => a + b,
    );
    final goalDays = state.weeklySteps.values
        .where((s) => s >= AppConstants.defaultStepGoal)
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            value: '${(totalWeeklySteps / 1000).toStringAsFixed(1)}k',
            label: 'Weekly\nSteps',
            color: AppColors.volt,
          ),
          _Divider(),
          _StatItem(
            value: totalWeeklyCal.toStringAsFixed(0),
            label: 'Weekly\nkcal',
            color: AppColors.red,
          ),
          _Divider(),
          _StatItem(
            value: '$goalDays/7',
            label: 'Goal\nDays',
            color: AppColors.emerald,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: AppColors.border);
  }
}

// ── Goal Tile ─────────────────────────────────────────────────────────────────

class _GoalTile extends StatelessWidget {
  final String emoji;
  final String label;
  final TextEditingController controller;
  final String unit;
  final TextInputType keyboardType;

  const _GoalTile({
    required this.emoji,
    required this.label,
    required this.controller,
    required this.unit,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          SizedBox(
            width: 80,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.volt,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(unit, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

// ── App Info ──────────────────────────────────────────────────────────────────

class _AppInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _InfoRow(label: 'App', value: 'Pulse Fitness'),
          _InfoRow(label: 'Version', value: '1.0.0'),
          _InfoRow(label: 'Database', value: 'SQLite (local)'),
          _InfoRow(label: 'Theme', value: 'Dark · Volt Green'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// class _ResetButton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () async {
//         // Confirm dialog
//         final confirm = await showDialog<bool>(
//           context: context,
//           builder: (_) => AlertDialog(
//             backgroundColor: AppColors.bgCard,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//               side: const BorderSide(color: AppColors.border),
//             ),
//             title: const Text(
//               'Reset All Data',
//               style: TextStyle(
//                 fontFamily: 'PlusJakartaSans',
//                 fontWeight: FontWeight.w700,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//             content: const Text(
//               'This will delete all workouts, steps, and water logs permanently.',
//               style: TextStyle(
//                 fontFamily: 'PlusJakartaSans',
//                 color: AppColors.textSecondary,
//               ),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: const Text(
//                   'Cancel',
//                   style: TextStyle(color: AppColors.textMuted),
//                 ),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 child: const Text(
//                   'Reset',
//                   style: TextStyle(
//                     color: AppColors.red,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );

//         if (confirm != true) return;

//         // Delete DB file and recreate
//         final dbPath = await getDatabasesPath();
//         final path = p.join(dbPath, AppConstants.dbName);
//         await deleteDatabase(path);

//         // Clear shared preferences
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.clear();

//         if (context.mounted) {
//           context.read<FitnessBloc>().add(const LoadTodayData());
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: const Text(
//                 '🗑️ All data reset',
//                 style: TextStyle(fontFamily: 'PlusJakartaSans'),
//               ),
//               backgroundColor: AppColors.bgElevated,
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           );
//         }
//       },
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: AppColors.bgCard,
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
//         ),
//         child: const Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.delete_outline_rounded, color: AppColors.red, size: 20),
//             SizedBox(width: 8),
//             Text(
//               'Reset All Data',
//               style: TextStyle(
//                 fontFamily: 'PlusJakartaSans',
//                 fontSize: 15,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.red,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
class _ResetButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleReset(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: AppColors.red, size: 20),
            SizedBox(width: 8),
            Text(
              'Reset All Data',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> _handleReset(BuildContext context) async {
  //   // Capture everything before any async gap
  //   final bloc = context.read<FitnessBloc>();
  //   final navigator = Navigator.of(context);
  //   final messenger = ScaffoldMessenger.of(context);

  //   final confirm = await showDialog<bool>(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       backgroundColor: AppColors.bgCard,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(20),
  //         side: const BorderSide(color: AppColors.border),
  //       ),
  //       title: const Text(
  //         'Reset All Data',
  //         style: TextStyle(
  //           fontFamily: 'PlusJakartaSans',
  //           fontWeight: FontWeight.w700,
  //           color: AppColors.textPrimary,
  //         ),
  //       ),
  //       content: const Text(
  //         'This will delete all workouts, steps, and water logs permanently.',
  //         style: TextStyle(
  //           fontFamily: 'PlusJakartaSans',
  //           color: AppColors.textSecondary,
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, false),
  //           child: const Text(
  //             'Cancel',
  //             style: TextStyle(color: AppColors.textMuted),
  //           ),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, true),
  //           child: const Text(
  //             'Reset',
  //             style: TextStyle(
  //               color: AppColors.red,
  //               fontWeight: FontWeight.w700,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );

  //   if (confirm != true) return;

  //   // Delete DB
  //   final dbPath = await getDatabasesPath();
  //   final path = p.join(dbPath, AppConstants.dbName);
  //   await deleteDatabase(path);

  //   // Clear prefs
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.clear();

  //   // Use pre-captured references — no context after async gap
  //   bloc.add(const LoadTodayData());

  //   messenger.showSnackBar(
  //     SnackBar(
  //       content: const Text(
  //         '🗑️ All data reset',
  //         style: TextStyle(fontFamily: 'PlusJakartaSans'),
  //       ),
  //       backgroundColor: AppColors.bgElevated,
  //       behavior: SnackBarBehavior.floating,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     ),
  //   );
  // }
  Future<void> _handleReset(BuildContext context) async {
    // Capture everything before async gap
    final bloc = context.read<FitnessBloc>();
    final messenger = ScaffoldMessenger.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'Reset All Data',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: const Text(
          'This will delete all workouts, steps, and water logs permanently.',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Reset',
              style: TextStyle(
                color: AppColors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Clear all data from database tables
    final datasource = LocalDatasource.instance;
    await datasource.clearAllData();

    // Clear shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    bloc.add(const LoadTodayData());

    messenger.showSnackBar(
      SnackBar(
        content: const Text(
          '🗑️ All data reset',
          style: TextStyle(fontFamily: 'PlusJakartaSans'),
        ),
        backgroundColor: AppColors.bgElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
