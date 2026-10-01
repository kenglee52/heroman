import 'dart:convert';

import 'package:heroman/core/api.dart';
import 'package:heroman/feature/data/models/job_model.dart';
import 'package:http/http.dart' as http;

class JobRemoteDatasource {
  Future<List<JobModel>> getJobs() async {
    try {
      final response = await http.get(Uri.parse(Api.BASE_URL + "/jobs"));
      if (response.statusCode == 200) {
        List data = await jsonDecode(response.body);
        return data.map((e) => JobModel.fromJson(e)).toList();
      }
    } catch (e) {
      print(e);
      return [];
    }
    return [];
  }
}
