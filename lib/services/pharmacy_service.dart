import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../constants/api_endpoints.dart';
import '../mocks/mock_data.dart';
import 'api_service.dart';

/// Service for pharmacy (PharmacyHomeScreen, PharmacyCategoryScreen, SelectPharmacyScreen).
class PharmacyService {
  final Dio _dio = ApiService().dio;

  Future<void> _mockDelay() async {
    if (AppConfig.mockDelayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: AppConfig.mockDelayMs));
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return List<Map<String, dynamic>>.from(MockData.pharmacyCategories);
    }
    try {
      final response = await _dio.get(ApiEndpoints.pharmacyCategories);
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

  Future<List<Map<String, dynamic>>> getProductsByCategory(
    String categoryId, {
    String? subCategory,
    String? sort,
  }) async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return List<Map<String, dynamic>>.from(MockData.pharmacyProducts);
    }
    try {
      final params = <String, dynamic>{};
      if (subCategory != null) params['sub'] = subCategory;
      if (sort != null) params['sort'] = sort;
      final response = await _dio.get(
        ApiEndpoints.pharmacyCategoryProducts(categoryId),
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

  Future<List<Map<String, dynamic>>> getNearbyPharmacies({
    double? lat,
    double? lng,
    int limit = 10,
  }) async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return List<Map<String, dynamic>>.from(MockData.nearbyPharmacies);
    }
    try {
      final params = <String, dynamic>{'limit': limit};
      if (lat != null) params['lat'] = lat;
      if (lng != null) params['lng'] = lng;
      final response = await _dio.get(ApiEndpoints.pharmacyNearby, queryParameters: params);
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

  Future<Map<String, dynamic>?> placeOrder({
    required String pharmacyId,
    String? deliveryAddressId,
  }) async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return {'id': 'order-1', 'pharmacy_id': pharmacyId, 'status': 'placed'};
    }
    try {
      final response = await _dio.post(ApiEndpoints.pharmacyOrders, data: {
        'pharmacy_id': pharmacyId,
        if (deliveryAddressId != null) 'delivery_address_id': deliveryAddressId,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data is Map ? Map<String, dynamic>.from(response.data as Map) : null;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    if (AppConfig.useMock) {
      await _mockDelay();
      return List<Map<String, dynamic>>.from(MockData.pharmacyProducts);
    }
    try {
      final response = await _dio.get(ApiEndpoints.pharmacyProducts, queryParameters: {'q': query});
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
