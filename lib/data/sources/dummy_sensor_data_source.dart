import 'dart:async';
import 'dart:math';
import '../models/sensor_reading.dart';
import '../sources/sensor_data_source.dart';
import '../../core/constants/app_constants.dart';

class DummySensorDataSource implements SensorDataSource {
  final _controller = StreamController<SensorReading>.broadcast();
  Timer? _timer;
  final _random = Random();

  SensorReading _currentReading;
  final List<SensorReading> _history = [];
  bool _isConnected = true;

  DummySensorDataSource()
      : _currentReading = SensorReading(
          temperature: AppConstants.initialTemperature,
          humidity: AppConstants.initialHumidity,
          timestamp: DateTime.now(),
          connectionState: DeviceConnectionState.connected,
          deviceId: AppConstants.defaultDeviceId,
        ) {
    _seedHistory();
  }

  /// Pre-seed 24h of realistic history data
  void _seedHistory() {
    final now = DateTime.now();
    var temp = AppConstants.initialTemperature;
    var hum = AppConstants.initialHumidity;

    // Generate readings at 15-minute intervals for the past 24h
    for (int i = 96; i >= 1; i--) {
      final ts = now.subtract(Duration(minutes: i * 15));
      // Simulate realistic day/night cycles
      final hourOfDay = ts.hour;
      final tempBase = hourOfDay >= 6 && hourOfDay <= 18
          ? AppConstants.initialTemperature + 2.0
          : AppConstants.initialTemperature - 2.0;
      final humBase = hourOfDay >= 6 && hourOfDay <= 18
          ? AppConstants.initialHumidity - 5.0
          : AppConstants.initialHumidity + 5.0;

      temp = tempBase + (_random.nextDouble() - 0.5) * 4.0;
      hum = humBase + (_random.nextDouble() - 0.5) * 8.0;

      temp = temp.clamp(18.0, 42.0);
      hum = hum.clamp(30.0, 95.0);

      _history.add(SensorReading(
        temperature: double.parse(temp.toStringAsFixed(1)),
        humidity: double.parse(hum.toStringAsFixed(1)),
        timestamp: ts,
        connectionState: DeviceConnectionState.connected,
        deviceId: AppConstants.defaultDeviceId,
      ));
    }

    _currentReading = SensorReading(
      temperature: AppConstants.initialTemperature,
      humidity: AppConstants.initialHumidity,
      timestamp: now,
      connectionState: DeviceConnectionState.connected,
      deviceId: AppConstants.defaultDeviceId,
    );
    _history.add(_currentReading);
  }

  List<SensorReading> get history => List.unmodifiable(_history);

  SensorReading get currentReading => _currentReading;

  bool get isConnected => _isConnected;

  @override
  Stream<SensorReading> get readings => _controller.stream;

  @override
  Future<void> start() async {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: AppConstants.sensorUpdateIntervalSeconds),
      (_) => _generateReading(),
    );
    // Emit initial
    _controller.add(_currentReading);
  }

  @override
  Future<void> refresh() async {
    if (!_isConnected) return;
    _generateReading();
  }

  void toggleConnection() {
    _isConnected = !_isConnected;
    if (_isConnected) {
      _generateReading();
      start();
    } else {
      _timer?.cancel();
      _timer = null;
      // Emit stale reading with disconnected state
      _currentReading = _currentReading.copyWith(
        connectionState: DeviceConnectionState.disconnected,
        timestamp: DateTime.now(),
      );
      _controller.add(_currentReading);
    }
  }

  void _generateReading() {
    if (!_isConnected) return;

    final tempDelta = (_random.nextDouble() - 0.5) *
        2 *
        AppConstants.tempVariationRange;
    final humDelta = (_random.nextDouble() - 0.5) *
        2 *
        AppConstants.humidityVariationRange;

    final newTemp = (_currentReading.temperature + tempDelta)
        .clamp(18.0, 42.0);
    final newHum =
        (_currentReading.humidity + humDelta).clamp(30.0, 95.0);

    _currentReading = SensorReading(
      temperature: double.parse(newTemp.toStringAsFixed(1)),
      humidity: double.parse(newHum.toStringAsFixed(1)),
      timestamp: DateTime.now(),
      connectionState: DeviceConnectionState.connected,
      deviceId: AppConstants.defaultDeviceId,
    );

    _history.add(_currentReading);
    // Keep max 200 readings in memory
    if (_history.length > 200) _history.removeAt(0);

    _controller.add(_currentReading);
  }

  /// Filter history by duration
  List<SensorReading> getHistoryForDuration(Duration duration) {
    final cutoff = DateTime.now().subtract(duration);
    return _history.where((r) => r.timestamp.isAfter(cutoff)).toList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
