import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/models/sensor_reading.dart';
import '../data/models/threshold_config.dart';
import '../data/sources/dummy_sensor_data_source.dart';
import '../core/constants/app_constants.dart';

class AppNotification {
  final String title;
  final String message;
  final DateTime timestamp;
  final EnvironmentalStatus severity;

  AppNotification({
    required this.title,
    required this.message,
    required this.timestamp,
    required this.severity,
  });
}

class AppState extends ChangeNotifier {
  final DummySensorDataSource _dataSource = DummySensorDataSource();
  StreamSubscription<SensorReading>? _subscription;
  bool _isDisposed = false;

  SensorReading? _currentReading;
  ThresholdConfig _thresholds = const ThresholdConfig(
    minTemperature: AppConstants.defaultMinTemp,
    maxTemperature: AppConstants.defaultMaxTemp,
    minHumidity: AppConstants.defaultMinHumidity,
    maxHumidity: AppConstants.defaultMaxHumidity,
  );

  String _greenhouseName = AppConstants.defaultGreenhouseName;
  String _plantType = AppConstants.defaultPlantType;
  bool _notificationsEnabled = true;
  final List<AppNotification> _notifications = [];

  AppState() {
    _currentReading = _dataSource.currentReading;
    _init();
  }

  Future<void> _init() async {
    _subscription = _dataSource.readings.listen((reading) {
      if (_isDisposed) return;
      _currentReading = reading;
      _checkThresholdsAndNotify();
      _safeNotifyListeners();
    });
    await _dataSource.start();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // ── Getters ──────────────────────────────────────────────────────────────

  SensorReading? get currentReading => _currentReading;
  ThresholdConfig get thresholds => _thresholds;
  String get greenhouseName => _greenhouseName;
  String get plantType => _plantType;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isConnected => _dataSource.isConnected;
  List<AppNotification> get notifications =>
      List.unmodifiable(_notifications.reversed.toList());
  int get unreadNotificationCount => _notifications.length;

  List<SensorReading> get history => _dataSource.history;

  List<SensorReading> historyForDuration(Duration d) =>
      _dataSource.getHistoryForDuration(d);

  EnvironmentalStatus get environmentalStatus {
    final r = _currentReading;
    if (r == null) return EnvironmentalStatus.normal;
    return _calculateStatus(r.temperature, r.humidity);
  }

  EnvironmentalStatus _calculateStatus(double temp, double humidity) {
    final t = _thresholds;

    // Critical: outside bounds
    if (temp < t.minTemperature ||
        temp > t.maxTemperature ||
        humidity < t.minHumidity ||
        humidity > t.maxHumidity) {
      return EnvironmentalStatus.critical;
    }

    // Warning: within warning margin
    const tempWarn = AppConstants.warningMarginTemp;
    const humWarn = AppConstants.warningMarginHumidity;

    if (temp < t.minTemperature + tempWarn ||
        temp > t.maxTemperature - tempWarn ||
        humidity < t.minHumidity + humWarn ||
        humidity > t.maxHumidity - humWarn) {
      return EnvironmentalStatus.warning;
    }

    return EnvironmentalStatus.normal;
  }

  String get environmentalStatusLabel {
    switch (environmentalStatus) {
      case EnvironmentalStatus.normal:
        return 'NORMAL';
      case EnvironmentalStatus.warning:
        return 'WARNING';
      case EnvironmentalStatus.critical:
        return 'CRITICAL';
    }
  }

  String get environmentalStatusDescription {
    final r = _currentReading;
    if (r == null) return 'No sensor data available.';
    final t = _thresholds;

    switch (environmentalStatus) {
      case EnvironmentalStatus.normal:
        return 'All conditions within optimal range. Plants are thriving.';
      case EnvironmentalStatus.warning:
        final issues = <String>[];
        if (r.temperature < t.minTemperature + AppConstants.warningMarginTemp) {
          issues.add('temperature approaching minimum');
        }
        if (r.temperature > t.maxTemperature - AppConstants.warningMarginTemp) {
          issues.add('temperature approaching maximum');
        }
        if (r.humidity < t.minHumidity + AppConstants.warningMarginHumidity) {
          issues.add('humidity approaching minimum');
        }
        if (r.humidity > t.maxHumidity - AppConstants.warningMarginHumidity) {
          issues.add('humidity approaching maximum');
        }
        return 'Attention: ${issues.join(', ')}. Monitor closely.';
      case EnvironmentalStatus.critical:
        final issues = <String>[];
        if (r.temperature < t.minTemperature) {
          issues.add('temperature too low (${r.temperature}°C < ${t.minTemperature}°C)');
        }
        if (r.temperature > t.maxTemperature) {
          issues.add('temperature too high (${r.temperature}°C > ${t.maxTemperature}°C)');
        }
        if (r.humidity < t.minHumidity) {
          issues.add('humidity too low (${r.humidity}% < ${t.minHumidity}%)');
        }
        if (r.humidity > t.maxHumidity) {
          issues.add('humidity too high (${r.humidity}% > ${t.maxHumidity}%)');
        }
        return 'Critical: ${issues.join('; ')}. Immediate action required!';
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> refresh() => _dataSource.refresh();

  void toggleConnection() {
    _dataSource.toggleConnection();
    _safeNotifyListeners();
  }

  void updateThresholds(ThresholdConfig config) {
    if (!config.isValid) return;
    _thresholds = config;
    _safeNotifyListeners();
  }

  void updateGreenhouseName(String name) {
    if (name.trim().isEmpty) return;
    _greenhouseName = name.trim();
    _safeNotifyListeners();
  }

  void updatePlantType(String type) {
    _plantType = type;
    _safeNotifyListeners();
  }

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    _safeNotifyListeners();
  }

  void resetDemoData() {
    _thresholds = const ThresholdConfig(
      minTemperature: AppConstants.defaultMinTemp,
      maxTemperature: AppConstants.defaultMaxTemp,
      minHumidity: AppConstants.defaultMinHumidity,
      maxHumidity: AppConstants.defaultMaxHumidity,
    );
    _greenhouseName = AppConstants.defaultGreenhouseName;
    _plantType = AppConstants.defaultPlantType;
    _notifications.clear();
    _safeNotifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    _safeNotifyListeners();
  }

  void _checkThresholdsAndNotify() {
    if (!_notificationsEnabled) return;
    final r = _currentReading;
    if (r == null) return;

    final status = _calculateStatus(r.temperature, r.humidity);
    if (status == EnvironmentalStatus.warning ||
        status == EnvironmentalStatus.critical) {
      final title = status == EnvironmentalStatus.critical
          ? '🚨 Critical Alert'
          : '⚠️ Warning';
      final msg = environmentalStatusDescription;

      // Avoid duplicate notifications within 1 minute
      if (_notifications.isEmpty ||
          DateTime.now()
              .difference(_notifications.last.timestamp)
              .inSeconds >
              60) {
        _notifications.add(AppNotification(
          title: title,
          message: msg,
          timestamp: DateTime.now(),
          severity: status,
        ));
        // Keep max 50 notifications
        if (_notifications.length > 50) _notifications.removeAt(0);
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _subscription?.cancel();
    _dataSource.dispose();
    super.dispose();
  }
}
