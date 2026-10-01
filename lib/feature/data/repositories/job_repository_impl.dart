import 'package:heroman/feature/data/datasources/job_remote_datasource.dart';
import 'package:heroman/feature/domain/entities/job.dart';
import 'package:heroman/feature/domain/repositories/job_repository.dart';

class JobRepositoryImpl implements JobRepository {
  final JobRemoteDatasource remote;
  JobRepositoryImpl(this.remote);

  @override
  Future<List<Job>> getJobs() => remote.getJobs();
}
