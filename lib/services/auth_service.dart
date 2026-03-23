import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../constants/api_endpoints.dart';
import 'api_service.dart';

class AuthService {
  final Dio _dio = ApiService().dio;

  Future<bool> login(String email, String password) async {
    if (AppConfig.useMock) {
      await Future<void>.delayed(Duration(milliseconds: AppConfig.mockDelayMs));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', 'mock_token_${DateTime.now().millisecondsSinceEpoch}');
      await prefs.setString('full_name', email.split('@').first);
      await prefs.setString('email', email);
      return true;
    }
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: FormData.fromMap({
          'username': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        final fullName = response.data['full_name'];
        final emailResponse = response.data['email'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        if (fullName != null) await prefs.setString('full_name', fullName);
        if (emailResponse != null)
          await prefs.setString('email', emailResponse);
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    if (AppConfig.useMock) {
      await Future<void>.delayed(Duration(milliseconds: AppConfig.mockDelayMs));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', 'mock_token_${DateTime.now().millisecondsSinceEpoch}');
      await prefs.setString('full_name', fullName);
      await prefs.setString('email', email);
      return true;
    }
    try {
      final response = await _dio.post(
        ApiEndpoints.users,
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
          'role': role.toLowerCase(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('full_name', fullName);
        await prefs.setString('email', email);
        return true;
      }
      return false;
    } catch (e) {
      print('Signup error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('full_name');
    await prefs.remove('email');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('access_token');
  }

  Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('full_name');
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }
}
