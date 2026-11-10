enum DeviceConnectionState { connected, disconnected, demoMode }

enum EnvironmentalStatus { normal, warning, critical }

class SensorReading {
  final double temperature;
  final double humidity;
  final DateTime timestamp;
  final DeviceConnectionState connectionState;
  final String deviceId;

  const SensorReading({
    required this.temperature,
    required this.humidity,
    required this.timestamp,
    required this.connectionState,
    required this.deviceId,
  });

  SensorReading copyWith({
    double? temperature,
    double? humidity,
    DateTime? timestamp,
    DeviceConnectionState? connectionState,
    String? deviceId,
  }) {
    return SensorReading(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      timestamp: timestamp ?? this.timestamp,
      connectionState: connectionState ?? this.connectionState,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  @override
  String toString() {
    return 'SensorReading(temp: $temperature, humidity: $humidity, ts: $timestamp, conn: $connectionState)';
  }
}
