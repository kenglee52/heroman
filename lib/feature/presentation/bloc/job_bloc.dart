import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroman/feature/domain/entities/job.dart';
import 'package:heroman/feature/domain/usecases/jobs/get_jobs.dart';

abstract class JobEvent {}

class LoadJobs extends JobEvent {}
abstract class JobState {}

class JobInitial extends JobState {}

class JobLoading extends JobState {}

class JobLoaded extends JobState {
  final List<Job> jobs;

  JobLoaded({
    required this.jobs,
  });
}

class JobError extends JobState {
  final String message;

  JobError({
    required this.message,
  });
}

class JobBloc extends Bloc<JobEvent, JobState> {
  final GetJobs getJobsUsecase;

  JobBloc({
    required this.getJobsUsecase,
  }) : super(JobInitial()) {
    on<LoadJobs>(_loadJobs);
  }

  Future<void> _loadJobs(
    LoadJobs event,
    Emitter<JobState> emit,
  ) async {
    emit(JobLoading());

    try {
      final jobs = await getJobsUsecase();

      emit(
        JobLoaded(
          jobs: jobs,
        ),
      );
    } catch (e) {
      emit(
        JobError(
          message: e.toString(),
        ),
      );
    }
  }
}