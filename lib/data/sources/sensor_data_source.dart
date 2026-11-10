import '../models/sensor_reading.dart';

/// Abstract sensor data source.
/// Replace [DummySensorDataSource] with [MqttSensorDataSource] in future.
abstract class SensorDataSource {
  Stream<SensorReading> get readings;

  Future<void> start();

  Future<void> refresh();

  void dispose();
}
