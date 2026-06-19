import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse_fitness_app/presentation/router/app_router.dart';

import '../../../core/theme/app_colors.dart';

class ShellScreen extends StatelessWidget {
  final Widget child;
  const ShellScreen({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home/history')) return 1;
    if (location.startsWith('/home/analytics')) return 2;
    if (location.startsWith('/home/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: child,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.logWorkout),
        backgroundColor: AppColors.volt,
        foregroundColor: AppColors.bgPrimary,
        elevation: 0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _PulseBottomNav(
        currentIndex: currentIndex,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/home/history');
              break;
            case 2:
              context.go('/home/analytics');
              break;
            case 3:
              context.go('/home/profile');
              break;
          }
        },
      ),
    );
  }
}

class _PulseBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const _PulseBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              // LEFT SIDE: Dashboard & History
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavItem(
                      icon: Icons.grid_view_rounded,
                      label: 'Dashboard',
                      selected: currentIndex == 0,
                      onTap: () => onTap(0),
                    ),
                    _NavItem(
                      icon: Icons.history_rounded,
                      label: 'History',
                      selected: currentIndex == 1,
                      onTap: () => onTap(1),
                    ),
                  ],
                ),
              ),
              // CENTER: FAB space (reserved, not clickable)
              const SizedBox(width: 72),
              // RIGHT SIDE: Analytics & Profile
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavItem(
                      icon: Icons.bar_chart_rounded,
                      label: 'Analytics',
                      selected: currentIndex == 2,
                      onTap: () => onTap(2),
                    ),
                    _NavItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Profile',
                      selected: currentIndex == 3,
                      onTap: () => onTap(3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.volt : AppColors.textMuted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
