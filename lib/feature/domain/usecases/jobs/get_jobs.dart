import 'package:heroman/feature/domain/entities/job.dart';
import 'package:heroman/feature/domain/repositories/job_repository.dart';

class GetJobs {
  final JobRepository repository;
  GetJobs(this.repository);

  Future<List<Job>> call() {
    return repository.getJobs();
  }
}
