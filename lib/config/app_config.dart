/// App configuration. Set [useMock] to true to test without a backend.
class AppConfig {
  AppConfig._();

  /// When true, services return mock data instead of calling the API.
  /// Toggle to false when your backend is ready.
  static const bool useMock = true;

  /// Optional: simulate network delay for mock responses (milliseconds).
  static const int mockDelayMs = 400;
}
