import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pulse_fitness_app/data/datasources/local_datasource.dart';
import 'package:pulse_fitness_app/data/repositories/fitness_repository_impl.dart';
import 'package:pulse_fitness_app/presentation/blocs/fitness/fitness_bloc.dart';
import 'package:pulse_fitness_app/presentation/blocs/fitness/fitness_event.dart';
import 'package:pulse_fitness_app/presentation/blocs/workout/workout_bloc.dart';
import 'package:pulse_fitness_app/presentation/blocs/workout/workout_event.dart';
import 'package:pulse_fitness_app/presentation/router/app_router.dart';
import 'package:pulse_fitness_app/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Dependency injection (manual — no get_it needed at this scale)
  final datasource = LocalDatasource.instance;
  final repository = FitnessRepositoryImpl(datasource);

  runApp(PulseApp(repository: repository));
}

class PulseApp extends StatelessWidget {
  final FitnessRepositoryImpl repository;

  const PulseApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    // return MultiBlocProvider(
    //   providers: [
    //     BlocProvider(
    //       create: (_) => FitnessBloc(repository)..add(const LoadTodayData()),
    //     ),
    //     BlocProvider(
    //       create: (_) => WorkoutBloc(repository)..add(const LoadWorkouts()),
    //     ),
    //   ],
    //   child: MaterialApp.router(
    //     title: 'Pulse',
    //     debugShowCheckedModeBanner: false,
    //     theme: AppTheme.dark,
    //     routerConfig: appRouter,
    //   ),
    // );
    return RepositoryProvider<FitnessRepositoryImpl>.value(
      value: repository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => FitnessBloc(repository)..add(const LoadTodayData()),
          ),
          BlocProvider(
            create: (_) => WorkoutBloc(repository)..add(const LoadWorkouts()),
          ),
        ],
        child: MaterialApp.router(
          title: 'Pulse',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
