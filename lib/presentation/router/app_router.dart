import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pulse_fitness_app/presentation/screens/log_workout/log_workout_screen.dart';
import 'package:pulse_fitness_app/presentation/screens/profile/profile_screen.dart';
import 'package:pulse_fitness_app/presentation/screens/splash/splash_screen.dart';

import '../screens/analytics/analytics_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/shell/shell_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const shell = '/home';
  static const dashboard = 'dashboard';
  static const history = 'history';
  static const analytics = 'analytics';
  static const profile = 'profile';
  static const logWorkout = '/log-workout';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  routes: [
    // ── Splash ──────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    // ── Shell (Bottom Nav) ───────────────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => ShellScreen(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.shell,
          builder: (context, state) => const DashboardScreen(),
          routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: AppRoutes.history,
              builder: (context, state) => const HistoryScreen(),
            ),
            GoRoute(
              path: AppRoutes.analytics,
              builder: (context, state) => const AnalyticsScreen(),
            ),
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // ── Log Workout (full screen modal, no bottom nav) ───────────────────────
    GoRoute(
      path: AppRoutes.logWorkout,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const LogWorkoutScreen(),
        transitionsBuilder: (context, animation, secondary, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
      ),
    ),
  ],
);
