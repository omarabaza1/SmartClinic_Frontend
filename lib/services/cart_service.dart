import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../constants/api_endpoints.dart';
import '../mocks/mock_data.dart';
import 'api_service.dart';

/// Service for cart and checkout (HomeScreen2, SelectPharmacyScreen).
class CartService {
  final Dio _dio = ApiService().dio;

  Future<void> _mockDelay() async {
    if (AppConfig.mockDelayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: AppConfig.mockDelayMs));
    }
  }

  Future<List<Map<String, dynamic>>> getCartItems() async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return List<Map<String, dynamic>>.from(MockData.cartItems);
    }
    try {
      final response = await _dio.get(ApiEndpoints.cart);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map && data['items'] is List) {
          return (data['items'] as List)
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

  Future<Map<String, dynamic>?> addToCart(String productId, {int quantity = 1}) async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return {'id': 'cart-new', 'product_id': productId, 'quantity': quantity};
    }
    try {
      final response = await _dio.post(ApiEndpoints.cartItems, data: {
        'product_id': productId,
        'quantity': quantity,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data is Map ? Map<String, dynamic>.from(response.data as Map) : null;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateCartItemQuantity(String itemId, int quantity) async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return true;
    }
    try {
      final response = await _dio.patch(ApiEndpoints.cartItemById(itemId), data: {'quantity': quantity});
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> removeCartItem(String itemId) async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return true;
    }
    try {
      final response = await _dio.delete(ApiEndpoints.cartItemById(itemId));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> clearCart() async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return true;
    }
    try {
      final response = await _dio.delete(ApiEndpoints.cart);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getOrderSummary() async {
    if (AppConfig.useMock) {
      await _mockDelay();
      final summary = MockData.orderSummary;
      return summary != null ? Map<String, dynamic>.from(summary) : null;
    }
    try {
      final response = await _dio.get(ApiEndpoints.cartSummary);
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
