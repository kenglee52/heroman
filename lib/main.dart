import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroman/feature/data/datasources/job_remote_datasource.dart';
import 'package:heroman/feature/data/repositories/job_repository_impl.dart';
import 'package:heroman/feature/domain/usecases/jobs/get_jobs.dart';
import 'package:heroman/feature/presentation/bloc/job_bloc.dart';
import 'package:heroman/feature/presentation/pages/login.dart';

void main() {
  final remote = JobRemoteDatasource();
  final repository = JobRepositoryImpl(remote);
  final getJobs = GetJobs(repository);

  runApp(MyApp(getJobs: getJobs));
}

class MyApp extends StatelessWidget {
  final GetJobs getJobs;

  const MyApp({super.key, required this.getJobs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeroMan',
      home: BlocProvider(
        create: (_) => JobBloc(getJobsUsecase: getJobs)..add(LoadJobs()),
        child: const Login(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
