import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../constants/api_endpoints.dart';
import '../mocks/mock_data.dart';
import 'api_service.dart';

/// Service for messages (MessagesScreen).
class MessageService {
  final Dio _dio = ApiService().dio;

  Future<void> _mockDelay() async {
    if (AppConfig.mockDelayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: AppConfig.mockDelayMs));
    }
  }

  Future<List<Map<String, dynamic>>> getConversations() async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return List<Map<String, dynamic>>.from(MockData.conversations);
    }
    try {
      final response = await _dio.get(ApiEndpoints.messagesConversations);
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

  Future<List<Map<String, dynamic>>> getMessages(String conversationId, {int? limit, int? offset}) async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return [
        {'id': 'msg-1', 'content': 'Hello! How can I help?', 'is_me': false, 'created_at': ''},
        {'id': 'msg-2', 'content': 'I have a question about my prescription.', 'is_me': true, 'created_at': ''},
      ];
    }
    try {
      final params = <String, dynamic>{};
      if (limit != null) params['limit'] = limit;
      if (offset != null) params['offset'] = offset;
      final response = await _dio.get(
        ApiEndpoints.messagesConversationById(conversationId),
        queryParameters: params.isNotEmpty ? params : null,
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map && data['messages'] is List) {
          return (data['messages'] as List)
              .map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{})
              .toList();
        }
        if (data is List) {
          return data.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> sendMessage(String conversationId, String content) async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return {'id': 'msg-new', 'content': content, 'is_me': true};
    }
    try {
      final response = await _dio.post(
        ApiEndpoints.messagesConversationById(conversationId),
        data: {'content': content},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data is Map ? Map<String, dynamic>.from(response.data as Map) : null;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
