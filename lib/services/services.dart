/// Barrel file: import all services from one place.
/// Usage: import 'package:smart_clinic_app/services/services.dart';
///
/// Mock mode: set [AppConfig.useMock] to true in lib/config/app_config.dart
/// to test without a backend. All services then return data from lib/mocks/mock_data.dart.

export 'api_service.dart';
export 'auth_service.dart';
export 'appointment_service.dart';
export 'doctor_service.dart';
export 'specialty_service.dart';
export 'cart_service.dart';
export 'pharmacy_service.dart';
export 'message_service.dart';
export 'profile_service.dart';
export 'ai_checkup_service.dart';
