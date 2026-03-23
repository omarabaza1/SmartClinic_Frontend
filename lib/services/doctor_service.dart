import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../constants/api_endpoints.dart';
import '../mocks/mock_data.dart';
import 'api_service.dart';

/// Service for doctors (SelectSpecialty1, SelectSpecialty3, HomeScreen3).
class DoctorService {
  final Dio _dio = ApiService().dio;

  Future<void> _mockDelay() async {
    if (AppConfig.mockDelayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: AppConfig.mockDelayMs));
    }
  }

  Future<List<Map<String, dynamic>>> getFeaturedDoctors({String? specialty}) async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return List<Map<String, dynamic>>.from(MockData.featuredDoctors);
    }
    try {
      final query = specialty != null ? '?specialty=$specialty' : '';
      final response = await _dio.get('${ApiEndpoints.doctorsFeatured}$query');
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

  Future<List<Map<String, dynamic>>> searchDoctors({
    String? query,
    String? specialtyId,
    String? location,
    String? sort,
  }) async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return List<Map<String, dynamic>>.from(MockData.doctorsBySpecialty);
    }
    try {
      final params = <String, dynamic>{};
      if (query != null && query.isNotEmpty) params['q'] = query;
      if (specialtyId != null) params['specialty_id'] = specialtyId;
      if (location != null) params['location'] = location;
      if (sort != null) params['sort'] = sort;
      final response = await _dio.get(ApiEndpoints.doctors, queryParameters: params);
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

  Future<List<Map<String, dynamic>>> getDoctorsBySpecialty(String specialtyId) async {
    return searchDoctors(specialtyId: specialtyId);
  }

  Future<Map<String, dynamic>?> getDoctorById(String id) async {
    if (AppConfig.useMock) {
      await _mockDelay();
      final profile = MockData.doctorProfile(id);
      return profile != null ? Map<String, dynamic>.from(profile) : null;
    }
    try {
      final response = await _dio.get(ApiEndpoints.doctorById(id));
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getDoctorTimeSlots(String doctorId, String date) async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return List<Map<String, dynamic>>.from(MockData.timeSlots);
    }
    try {
      final response = await _dio.get(ApiEndpoints.doctorSlots(doctorId), queryParameters: {'date': date});
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
}
