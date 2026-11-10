class AppConstants {
  AppConstants._();

  // Greenhouse defaults
  static const String defaultGreenhouseName = 'Greenhouse A';
  static const String defaultLocation = 'Hydroponic Garden';
  static const String defaultPlantType = 'Lettuce';
  static const String defaultDeviceName = 'Greenhouse Sensor 01';
  static const String defaultDeviceId = 'GP-SENSOR-001';
  static const String defaultBoard = 'ESP8266';
  static const String defaultSensor = 'DHT22';

  // Sensor defaults
  static const double initialTemperature = 27.4;
  static const double initialHumidity = 68.0;

  // Thresholds defaults
  static const double defaultMinTemp = 20.0;
  static const double defaultMaxTemp = 35.0;
  static const double defaultMinHumidity = 50.0;
  static const double defaultMaxHumidity = 85.0;

  // Warning margin (how close to threshold before WARNING state)
  static const double warningMarginTemp = 3.0;
  static const double warningMarginHumidity = 5.0;

  // Simulation
  static const int sensorUpdateIntervalSeconds = 12;
  static const double tempVariationRange = 0.8;
  static const double humidityVariationRange = 1.5;

  // MQTT topics (for future use)
  static const String mqttTopicTemperature = 'greenpulse/gh01/temperature';
  static const String mqttTopicHumidity = 'greenpulse/gh01/humidity';
  static const String mqttTopicStatus = 'greenpulse/gh01/status';

  // App info
  static const String appVersion = '1.0.0+1';
  static const String appTagline = 'Grow Smarter. Monitor Better.';
  static const String appDescription =
      'GREENPULSE is a Smart Agriculture IoT Monitoring application for greenhouse management.';

  // Plant types
  static const List<String> plantTypes = [
    'Lettuce',
    'Tomato',
    'Basil',
    'Spinach',
    'Cucumber',
    'Pepper',
    'Strawberry',
    'Herbs',
    'Microgreens',
    'Other',
  ];
}
