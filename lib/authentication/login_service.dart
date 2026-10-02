import 'dart:convert';
import 'package:heroman/core/api.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginResult {
  final bool success;
  final String message;
  final String? token;
  final String? userId;
  final String? role;

  LoginResult({
    required this.success,
    required this.message,
    this.token,
    this.userId,
    this.role,
  });
}

class LoginService {
  static const String tokenKey = 'access_token';
  static const String userIdKey = 'user_id';
  static const String roleKey = 'role';


  Future<LoginResult> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${Api.BASE_URL}/mechanics/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'phone': phone, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final token = data['access_token'] as String;
        final userId = data['user']['_id'] as String;
        final role = data['role'] as String?;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(tokenKey, token);
        await prefs.setString(userIdKey, userId);
        if (role != null) await prefs.setString(roleKey, role);

        return LoginResult(
          success: true,
          message: data['message']?.toString() ?? 'Login success',
          token: token,
          userId: userId,
          role: role,
        );
      }

      return LoginResult(
        success: false,
        message: data['message']?.toString() ?? 'ເບີໂທ ຫຼື ລະຫັດຜ່ານບໍ່ຖືກຕ້ອງ',
      );
    } catch (e) {
      return LoginResult(success: false, message: 'Error: $e');
    }
  }


  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userIdKey);
    await prefs.remove(roleKey);
  }
}
