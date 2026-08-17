class SizeBasedLoggerConfig {
  static SizeBasedLoggerConfig? _instance;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  SizeBasedLoggerConfig._();

  static SizeBasedLoggerConfig get instance =>
      _instance ??= SizeBasedLoggerConfig._();

  Future<void> initialize() async {
    _isInitialized = true;
  }

  Future<void> close() async {
    _isInitialized = false;
  }
}
