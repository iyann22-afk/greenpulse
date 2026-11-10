class ThresholdConfig {
  final double minTemperature;
  final double maxTemperature;
  final double minHumidity;
  final double maxHumidity;

  const ThresholdConfig({
    required this.minTemperature,
    required this.maxTemperature,
    required this.minHumidity,
    required this.maxHumidity,
  });

  ThresholdConfig copyWith({
    double? minTemperature,
    double? maxTemperature,
    double? minHumidity,
    double? maxHumidity,
  }) {
    return ThresholdConfig(
      minTemperature: minTemperature ?? this.minTemperature,
      maxTemperature: maxTemperature ?? this.maxTemperature,
      minHumidity: minHumidity ?? this.minHumidity,
      maxHumidity: maxHumidity ?? this.maxHumidity,
    );
  }

  bool get isValid =>
      minTemperature < maxTemperature && minHumidity < maxHumidity;

  @override
  String toString() {
    return 'ThresholdConfig(temp: $minTemperature-$maxTemperature°C, hum: $minHumidity-$maxHumidity%)';
  }
}
