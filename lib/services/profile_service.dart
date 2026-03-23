import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../constants/api_endpoints.dart';
import '../mocks/mock_data.dart';
import 'api_service.dart';

/// Service for profile (HomeScreen4).
class ProfileService {
  final Dio _dio = ApiService().dio;

  Future<void> _mockDelay() async {
    if (AppConfig.mockDelayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: AppConfig.mockDelayMs));
    }
  }

  Future<List<Map<String, dynamic>>> getAppointmentHistory({int? limit, int? offset}) async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return List<Map<String, dynamic>>.from(MockData.appointmentHistory);
    }
    try {
      final params = <String, dynamic>{};
      if (limit != null) params['limit'] = limit;
      if (offset != null) params['offset'] = offset;
      final response = await _dio.get(
        ApiEndpoints.usersMeAppointmentsHistory,
        queryParameters: params.isNotEmpty ? params : null,
      );
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data is List ? response.data as List : [];
        return list.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}).toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPaymentHistory({int? limit, int? offset}) async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return List<Map<String, dynamic>>.from(MockData.paymentHistory);
    }
    try {
      final params = <String, dynamic>{};
      if (limit != null) params['limit'] = limit;
      if (offset != null) params['offset'] = offset;
      final response = await _dio.get(
        ApiEndpoints.usersMePayments,
        queryParameters: params.isNotEmpty ? params : null,
      );
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data is List ? response.data as List : [];
        return list.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}).toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return {'full_name': 'Guest User', 'email': 'guest@example.com'};
    }
    try {
      final response = await _dio.get(ApiEndpoints.usersMe);
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> updateProfile(Map<String, dynamic> data) async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return {'full_name': data['full_name'], 'email': data['email'] ?? 'guest@example.com'};
    }
    try {
      final response = await _dio.patch(ApiEndpoints.usersMe, data: data);
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
