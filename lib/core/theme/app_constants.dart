class AppConstants {
  AppConstants._();

  // Default daily goals
  static const int defaultStepGoal = 10000;
  static const double defaultCalorieGoal = 500.0;
  static const double defaultWaterGoalL = 2.5;
  static const int defaultWorkoutMins = 45;

  // Activity types (matches the design emoji map)
  static const List<String> activityTypes = [
    'Running',
    'Cycling',
    'Gym',
    'Yoga',
    'Swimming',
    'Walking',
    'Other',
  ];

  // Emoji map
  static const Map<String, String> activityEmoji = {
    'Running': '🏃',
    'Cycling': '🚴',
    'Gym': '🏋️',
    'Yoga': '🧘',
    'Swimming': '🏊',
    'Walking': '🚶',
    'Other': '💪',
  };

  // DB
  static const String dbName = 'pulse_fitness.db';
  static const int dbVersion = 1;

  // SharedPreferences keys
  static const String keyStepGoal = 'step_goal';
  static const String keyCalGoal = 'calorie_goal';
  static const String keyWaterGoal = 'water_goal';
  static const String keyUserName = 'user_name';
  static const String keyOnboarded = 'onboarded';
}
