import 'dart:convert';

import 'package:heroman/core/api.dart';
import 'package:heroman/feature/data/models/mechanic_model.dart';
import 'package:http/http.dart' as http;

class MechanicRemoteDatasource {
  Future<void> createMechanic(MechanicModel mechanic) async {
    try {
      final response = await http.post(
        Uri.parse(Api.BASE_URL + "/mechanics/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(mechanic),
      );
      if (response.statusCode == 200) {
        print("Add mechanic success");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<MechanicModel?> getMechanicById(String id) async {
    try {
      final response = await http.get(
        Uri.parse(Api.BASE_URL + "/mechanics/${id}"),
      );
      if (response.statusCode == 200) {
        final data = await jsonDecode(response.body);
        return MechanicModel.fromJson(data);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
