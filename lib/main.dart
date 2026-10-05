import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroman/feature/data/datasources/job_remote_datasource.dart';
import 'package:heroman/feature/data/datasources/mechanic_remote_datasource.dart';
import 'package:heroman/feature/data/repositories/job_repository_impl.dart';
import 'package:heroman/feature/data/repositories/mechanic_repository_impl.dart';
import 'package:heroman/feature/domain/usecases/jobs/get_jobs.dart';
import 'package:heroman/feature/domain/usecases/mechanics/create_mechanic.dart';
import 'package:heroman/feature/domain/usecases/mechanics/get_mechanic_by_id.dart';
import 'package:heroman/feature/presentation/bloc/job_bloc.dart';
import 'package:heroman/feature/presentation/bloc/mechanic_bloc.dart';
import 'package:heroman/feature/presentation/layout/main_layout.dart';
import 'package:heroman/feature/presentation/pages/login.dart';
import 'package:heroman/feature/presentation/pages/register.dart';

void main() {
  // Job
  final jobRemote = JobRemoteDatasource();
  final jobRepository = JobRepositoryImpl(jobRemote);
  final getJobs = GetJobs(jobRepository);

  // Mechanic
  final mechanicRemote = MechanicRemoteDatasource();
  final mechanicRepository = MechanicRepositoryImpl(mechanicRemote);
  final createMechanic = CreateMechanic(mechanicRepository);
  final getMechanicById = GetMechanicById(mechanicRepository);

  runApp(
    MyApp(
      getJobs: getJobs,
      createMechanic: createMechanic,
      getMechanicById: getMechanicById,
    ),
  );
}

class AppRoutes {
  static const String login = '/';
  static const String main_layout = '/main-layout';
  static const String register = "/register";
}

class MyApp extends StatelessWidget {
  final GetJobs getJobs;
  final CreateMechanic createMechanic;
  final GetMechanicById getMechanicById;

  const MyApp({
    super.key,
    required this.getJobs,
    required this.createMechanic,
    required this.getMechanicById,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<JobBloc>(
          create: (_) => JobBloc(getJobsUsecase: getJobs)..add(LoadJobs()),
        ),
        BlocProvider<MechanicBloc>(
          create: (_) => MechanicBloc(
            createMechanicUsecase: createMechanic,
            getMechanicByIdUsecase: getMechanicById,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'HeroMan',
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.login,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.login:
              return MaterialPageRoute(builder: (_) => const Login());
            case AppRoutes.main_layout:
              return MaterialPageRoute(builder: (_) => const MainLayout());
            case AppRoutes.register:
              return MaterialPageRoute(builder: (_) => const Register());
            default:
              return MaterialPageRoute(
                builder: (_) => Scaffold(
                  body: Center(
                    child: Text('No route defined for ${settings.name}'),
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}