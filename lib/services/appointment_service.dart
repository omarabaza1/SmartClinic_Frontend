import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../constants/api_endpoints.dart';
import '../mocks/mock_data.dart';
import 'api_service.dart';

/// Service for appointments (HomeScreen1, HomeScreen3).
class AppointmentService {
  final Dio _dio = ApiService().dio;

  Future<void> _mockDelay() async {
    if (AppConfig.mockDelayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: AppConfig.mockDelayMs));
    }
  }

  Future<List<Map<String, dynamic>>> getTodayAppointments() async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return List<Map<String, dynamic>>.from(MockData.todayAppointments);
    }
    try {
      final response = await _dio.get(ApiEndpoints.appointmentsToday);
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

  Future<List<Map<String, dynamic>>> getUpcomingAppointments() async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return List<Map<String, dynamic>>.from(MockData.upcomingAppointments);
    }
    try {
      final response = await _dio.get(ApiEndpoints.appointmentsUpcoming);
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

  Future<List<Map<String, dynamic>>> getAppointmentAlerts() async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return List<Map<String, dynamic>>.from(MockData.appointmentAlerts);
    }
    try {
      final response = await _dio.get(ApiEndpoints.appointmentsAlerts);
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

  Future<Map<String, dynamic>?> bookAppointment({
    required String doctorId,
    required String date,
    required String timeSlot,
    String? type,
  }) async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return {'id': 'apt-new', 'doctor_id': doctorId, 'date': date, 'time_slot': timeSlot, 'status': 'confirmed'};
    }
    try {
      final response = await _dio.post(ApiEndpoints.appointments, data: {
        'doctor_id': doctorId,
        'date': date,
        'time_slot': timeSlot,
        if (type != null) 'type': type,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data is Map ? Map<String, dynamic>.from(response.data as Map) : null;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getAppointmentById(String id) async {
    if (AppConfig.useMock) {
      await _mockDelay();
      final today = MockData.todayAppointments;
      final match = today.isNotEmpty ? today.first : <String, dynamic>{};
      return Map<String, dynamic>.from(match)..['id'] = id;
    }
    try {
      final response = await _dio.get(ApiEndpoints.appointmentById(id));
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<bool> cancelAppointment(String id) async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return true;
    }
    try {
      final response = await _dio.delete(ApiEndpoints.appointmentById(id));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      rethrow;
    }
  }
}
