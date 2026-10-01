import 'package:heroman/feature/domain/entities/job.dart';

class JobModel extends Job {
  JobModel({required super.job});

  factory JobModel.fromEntity(Job job) {
    return JobModel(job: job.job);
  }

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(job: json["job"]);
  }

  Map<String, dynamic> toJson() {
    return {"job": job};
  }
}
