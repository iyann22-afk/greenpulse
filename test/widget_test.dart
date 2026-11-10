import 'package:flutter_test/flutter_test.dart';
import 'package:greenpulse/data/models/sensor_reading.dart';
import 'package:greenpulse/data/models/threshold_config.dart';
import 'package:greenpulse/data/sources/dummy_sensor_data_source.dart';
import 'package:greenpulse/app/app_state.dart';
import 'package:greenpulse/core/constants/app_constants.dart';
import 'package:greenpulse/app/app.dart';

void main() {
  // ── SensorReading model tests ─────────────────────────────────────────

  group('SensorReading', () {
    test('creates with correct values', () {
      final now = DateTime.now();
      final reading = SensorReading(
        temperature: 27.4,
        humidity: 68.0,
        timestamp: now,
        connectionState: DeviceConnectionState.connected,
        deviceId: 'GP-SENSOR-001',
      );

      expect(reading.temperature, 27.4);
      expect(reading.humidity, 68.0);
      expect(reading.timestamp, now);
      expect(reading.connectionState, DeviceConnectionState.connected);
      expect(reading.deviceId, 'GP-SENSOR-001');
    });

    test('copyWith preserves unchanged fields', () {
      final now = DateTime.now();
      final original = SensorReading(
        temperature: 27.4,
        humidity: 68.0,
        timestamp: now,
        connectionState: DeviceConnectionState.connected,
        deviceId: 'GP-SENSOR-001',
      );

      final copy = original.copyWith(temperature: 30.0);

      expect(copy.temperature, 30.0);
      expect(copy.humidity, 68.0);
      expect(copy.deviceId, 'GP-SENSOR-001');
    });

    test('copyWith connection state change', () {
      final reading = SensorReading(
        temperature: 27.4,
        humidity: 68.0,
        timestamp: DateTime.now(),
        connectionState: DeviceConnectionState.connected,
        deviceId: 'GP-SENSOR-001',
      );

      final disconnected =
          reading.copyWith(connectionState: DeviceConnectionState.disconnected);

      expect(disconnected.connectionState, DeviceConnectionState.disconnected);
      expect(disconnected.temperature, reading.temperature);
    });
  });

  // ── ThresholdConfig tests ─────────────────────────────────────────────

  group('ThresholdConfig', () {
    test('valid config returns true for isValid', () {
      const config = ThresholdConfig(
        minTemperature: 20.0,
        maxTemperature: 35.0,
        minHumidity: 50.0,
        maxHumidity: 85.0,
      );
      expect(config.isValid, true);
    });

    test('invalid temp config returns false for isValid', () {
      const config = ThresholdConfig(
        minTemperature: 35.0,
        maxTemperature: 20.0,
        minHumidity: 50.0,
        maxHumidity: 85.0,
      );
      expect(config.isValid, false);
    });

    test('invalid humidity config returns false for isValid', () {
      const config = ThresholdConfig(
        minTemperature: 20.0,
        maxTemperature: 35.0,
        minHumidity: 85.0,
        maxHumidity: 50.0,
      );
      expect(config.isValid, false);
    });

    test('copyWith works correctly', () {
      const original = ThresholdConfig(
        minTemperature: 20.0,
        maxTemperature: 35.0,
        minHumidity: 50.0,
        maxHumidity: 85.0,
      );
      final updated = original.copyWith(minTemperature: 15.0);
      expect(updated.minTemperature, 15.0);
      expect(updated.maxTemperature, 35.0);
    });
  });

  // ── Environmental Status calculation tests ────────────────────────────

  group('Environmental Status Calculation', () {
    late AppState appState;

    setUp(() {
      appState = AppState();
    });

    tearDown(() {
      appState.dispose();
    });

    test('status is normal for in-range values', () {
      appState.updateThresholds(const ThresholdConfig(
        minTemperature: 20.0,
        maxTemperature: 35.0,
        minHumidity: 50.0,
        maxHumidity: 85.0,
      ));
      // Initial value is 27.4°C, 68% — should be normal with defaults
      expect(appState.environmentalStatus, EnvironmentalStatus.normal);
    });

    test('status is critical when temp below minimum', () {
      // Set thresholds very high so current reading is below min
      appState.updateThresholds(const ThresholdConfig(
        minTemperature: 35.0,
        maxTemperature: 45.0,
        minHumidity: 50.0,
        maxHumidity: 85.0,
      ));
      expect(appState.environmentalStatus, EnvironmentalStatus.critical);
    });

    test('status label matches status', () {
      appState.updateThresholds(const ThresholdConfig(
        minTemperature: 20.0,
        maxTemperature: 35.0,
        minHumidity: 50.0,
        maxHumidity: 85.0,
      ));
      final status = appState.environmentalStatus;
      expect(status, isNotNull);
      final label = appState.environmentalStatusLabel;
      expect(label, isNotEmpty);
      expect(
        label,
        anyOf('NORMAL', 'WARNING', 'CRITICAL'),
      );
    });
  });

  // ── DummySensorDataSource tests ───────────────────────────────────────

  group('DummySensorDataSource', () {
    late DummySensorDataSource source;

    setUp(() {
      source = DummySensorDataSource();
    });

    tearDown(() {
      source.dispose();
    });

    test('initializes with default temperature', () {
      expect(source.currentReading.temperature,
          AppConstants.initialTemperature);
    });

    test('initializes with default humidity', () {
      expect(source.currentReading.humidity, AppConstants.initialHumidity);
    });

    test('seeds history with readings', () {
      expect(source.history, isNotEmpty);
      expect(source.history.length, greaterThan(10));
    });

    test('history readings are within sensible bounds', () {
      for (final r in source.history) {
        expect(r.temperature, greaterThanOrEqualTo(10.0));
        expect(r.temperature, lessThanOrEqualTo(50.0));
        expect(r.humidity, greaterThanOrEqualTo(10.0));
        expect(r.humidity, lessThanOrEqualTo(100.0));
      }
    });

    test('starts as connected', () {
      expect(source.isConnected, true);
    });

    test('toggle disconnects', () {
      source.toggleConnection();
      expect(source.isConnected, false);
    });

    test('double toggle reconnects', () {
      source.toggleConnection();
      source.toggleConnection();
      expect(source.isConnected, true);
    });

    test('emits reading on start', () async {
      final readings = <dynamic>[];
      final sub = source.readings.listen(readings.add);
      await source.start();
      await Future.delayed(const Duration(milliseconds: 100));
      sub.cancel();
      expect(readings, isNotEmpty);
    });

    test('getHistoryForDuration filters correctly', () {
      final oneHour =
          source.getHistoryForDuration(const Duration(hours: 1));
      final twentyFourHour =
          source.getHistoryForDuration(const Duration(hours: 24));
      expect(oneHour.length, lessThanOrEqualTo(twentyFourHour.length));
    });

    test('refresh adds new reading', () async {
      await source.start();
      final countBefore = source.history.length;
      await source.refresh();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(source.history.length, greaterThan(countBefore));
    });
  });

  // ── AppState tests ────────────────────────────────────────────────────

  group('AppState', () {
    late AppState state;

    setUp(() {
      state = AppState();
    });

    tearDown(() {
      state.dispose();
    });

    test('initial greenhouse name is default', () {
      expect(state.greenhouseName, AppConstants.defaultGreenhouseName);
    });

    test('initial plant type is default', () {
      expect(state.plantType, AppConstants.defaultPlantType);
    });

    test('updateGreenhouseName works', () {
      state.updateGreenhouseName('My Greenhouse');
      expect(state.greenhouseName, 'My Greenhouse');
    });

    test('empty name is ignored', () {
      state.updateGreenhouseName('  ');
      expect(state.greenhouseName, AppConstants.defaultGreenhouseName);
    });

    test('updatePlantType works', () {
      state.updatePlantType('Tomato');
      expect(state.plantType, 'Tomato');
    });

    test('notifications enabled by default', () {
      expect(state.notificationsEnabled, true);
    });

    test('toggle notifications works', () {
      state.toggleNotifications(false);
      expect(state.notificationsEnabled, false);
    });

    test('resetDemoData restores defaults', () {
      state.updateGreenhouseName('Changed');
      state.updatePlantType('Tomato');
      state.resetDemoData();
      expect(state.greenhouseName, AppConstants.defaultGreenhouseName);
      expect(state.plantType, AppConstants.defaultPlantType);
    });

    test('initial connection state is connected', () {
      expect(state.isConnected, true);
    });

    test('toggle connection changes state', () {
      state.toggleConnection();
      expect(state.isConnected, false);
      state.toggleConnection();
      expect(state.isConnected, true);
    });

    test('thresholds update correctly', () {
      const newThresholds = ThresholdConfig(
        minTemperature: 15.0,
        maxTemperature: 40.0,
        minHumidity: 40.0,
        maxHumidity: 90.0,
      );
      state.updateThresholds(newThresholds);
      expect(state.thresholds.minTemperature, 15.0);
      expect(state.thresholds.maxTemperature, 40.0);
    });

    test('invalid thresholds are rejected', () {
      const invalidThresholds = ThresholdConfig(
        minTemperature: 40.0,
        maxTemperature: 15.0,
        minHumidity: 40.0,
        maxHumidity: 90.0,
      );
      state.updateThresholds(invalidThresholds);
      // Should keep defaults
      expect(state.thresholds.minTemperature,
          AppConstants.defaultMinTemp);
    });

    test('history is not empty after init', () {
      expect(state.history, isNotEmpty);
    });

    test('historyForDuration works', () {
      final h1 =
          state.historyForDuration(const Duration(hours: 1));
      final h24 =
          state.historyForDuration(const Duration(hours: 24));
      expect(h1.length, lessThanOrEqualTo(h24.length));
    });
  });

  // ── UI Widget tests ───────────────────────────────────────────────────

  group('UI Widget Rendering', () {
    testWidgets('GreenPulseApp renders dashboard with title and sensors',
        (tester) async {
      await tester.pumpWidget(const GreenPulseApp());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('GREENPULSE'), findsWidgets);
      expect(find.text('Live Sensors'), findsOneWidget);
      expect(find.text('Temperature'), findsWidgets);
      expect(find.text('Humidity'), findsWidgets);
      expect(find.text('Environmental Overview'), findsOneWidget);
    });

    testWidgets('Navigation bar navigates between pages', (tester) async {
      await tester.pumpWidget(const GreenPulseApp());
      await tester.pump(const Duration(milliseconds: 500));

      // Tap Analytics tab
      await tester.tap(find.text('Analytics'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Historical sensor data · Simulated'), findsOneWidget);

      // Tap Devices tab
      await tester.tap(find.text('Devices'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('IoT device management'), findsOneWidget);
      expect(find.text(AppConstants.defaultDeviceName), findsWidgets);

      // Tap Settings tab
      await tester.tap(find.text('Settings'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Configure greenhouse & monitoring'), findsOneWidget);
      expect(find.text('Monitoring Thresholds'), findsOneWidget);
    });
  });
}
