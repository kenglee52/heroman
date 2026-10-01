import 'package:heroman/feature/domain/entities/job.dart';

abstract class JobRepository {
  Future<List<Job>> getJobs();
}
