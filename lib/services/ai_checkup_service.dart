import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../constants/api_endpoints.dart';
import '../mocks/mock_data.dart';
import 'api_service.dart';

/// Service for AI Self-Checkup (AISelfCheckupScreen).
class AICheckupService {
  final Dio _dio = ApiService().dio;

  Future<void> _mockDelay() async {
    if (AppConfig.mockDelayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: AppConfig.mockDelayMs));
    }
  }

  Future<List<Map<String, dynamic>>> getConditions() async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return List<Map<String, dynamic>>.from(MockData.aiConditions);
    }
    try {
      final response = await _dio.get(ApiEndpoints.aiCheckupConditions);
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

  Future<Map<String, dynamic>?> startGeneralAssessment() async {
    if (AppConfig.useMock) {
      await _mockDelay();
      final result = MockData.assessmentResult;
      return result != null ? Map<String, dynamic>.from(result) : null;
    }
    try {
      final response = await _dio.post(ApiEndpoints.aiCheckupAssessments, data: {'type': 'general'});
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data is Map ? Map<String, dynamic>.from(response.data as Map) : null;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> startConditionAssessment(String conditionId, Map<String, dynamic> inputs) async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return {
        'id': 'assess-1',
        'condition_id': conditionId,
        'status': 'completed',
        'summary': 'Assessment completed. Consult a doctor for professional advice.',
        'recommendations': ['Follow up with a specialist if needed.'],
      };
    }
    try {
      final response = await _dio.post(ApiEndpoints.aiCheckupAssessments, data: {
        'type': 'condition',
        'condition_id': conditionId,
        'inputs': inputs,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data is Map ? Map<String, dynamic>.from(response.data as Map) : null;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getAssessmentResult(String assessmentId) async {
    if (AppConfig.useMock) {
      await _mockDelay();
      final result = MockData.assessmentResult;
      return result != null ? Map<String, dynamic>.from(result)..['id'] = assessmentId : null;
    }
    try {
      final response = await _dio.get(ApiEndpoints.aiCheckupAssessmentById(assessmentId));
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
