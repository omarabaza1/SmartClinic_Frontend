import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../constants/api_endpoints.dart';
import '../mocks/mock_data.dart';
import 'api_service.dart';

/// Service for medical specialties (SelectSpecialty2).
class SpecialtyService {
  final Dio _dio = ApiService().dio;

  Future<void> _mockDelay() async {
    if (AppConfig.mockDelayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: AppConfig.mockDelayMs));
    }
  }

  Future<List<Map<String, dynamic>>> getMostPopularSpecialties() async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return List<Map<String, dynamic>>.from(MockData.mostPopularSpecialties);
    }
    try {
      final response = await _dio.get(ApiEndpoints.specialties, queryParameters: {'popular': true});
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

  Future<List<Map<String, dynamic>>> getAllSpecialties() async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return [
        ...MockData.mostPopularSpecialties,
        ...MockData.otherSpecialties,
      ];
    }
    try {
      final response = await _dio.get(ApiEndpoints.specialties);
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

  Future<Map<String, dynamic>?> getCurrentLocation() async {
    if (AppConfig.useMock) {
      await _mockDelay();
      final loc = MockData.currentLocation;
      return loc != null ? Map<String, dynamic>.from(loc) : null;
    }
    try {
      final response = await _dio.get(ApiEndpoints.usersMeLocation);
      if (response.statusCode == 200 && response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }
}
