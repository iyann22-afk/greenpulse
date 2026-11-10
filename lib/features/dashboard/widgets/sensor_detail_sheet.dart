import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_state.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/sensor_reading.dart';
import '../widgets/chart_preview.dart';

class SensorDetailSheet extends StatelessWidget {
  final bool isTemperature;

  const SensorDetailSheet({super.key, required this.isTemperature});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final reading = state.currentReading;
        final value = isTemperature
            ? reading?.temperature
            : reading?.humidity;
        final unit = isTemperature ? '°C' : '%';
        final color = isTemperature
            ? AppColors.pulseGreen
            : const Color(0xFF1565C0);
        final icon = isTemperature
            ? Icons.thermostat_rounded
            : Icons.water_drop_rounded;
        final label = isTemperature ? 'Temperature' : 'Humidity';
        final envStatus = state.environmentalStatus;

        final history =
            state.historyForDuration(const Duration(hours: 1));

        final values = history
            .map((r) =>
                isTemperature ? r.temperature : r.humidity)
            .toList();
        final avg = values.isEmpty
            ? 0.0
            : values.reduce((a, b) => a + b) / values.length;
        final min = values.isEmpty
            ? 0.0
            : values.reduce((a, b) => a < b ? a : b);
        final max = values.isEmpty
            ? 0.0
            : values.reduce((a, b) => a > b ? a : b);

        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.mutedText.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(icon, color: color, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label,
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                    color: AppColors.darkText,
                                  ),
                                ),
                                Text(
                                  reading != null
                                      ? DateFormatter.formatFullDateTime(
                                          reading.timestamp)
                                      : '—',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: AppColors.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Current value
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withOpacity(0.08),
                              color.withOpacity(0.04),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: color.withOpacity(0.2), width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Current Reading',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: AppColors.mutedText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  value?.toStringAsFixed(1) ?? '—',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 52,
                                    color: color,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    unit,
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                      color: color.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildStatusChip(envStatus, color),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Stats row
                      Row(
                        children: [
                          _StatChip(
                              label: 'Average',
                              value: avg.toStringAsFixed(1),
                              unit: unit,
                              color: color),
                          const SizedBox(width: 10),
                          _StatChip(
                              label: 'Minimum',
                              value: min.toStringAsFixed(1),
                              unit: unit,
                              color: AppColors.warningOrange),
                          const SizedBox(width: 10),
                          _StatChip(
                              label: 'Maximum',
                              value: max.toStringAsFixed(1),
                              unit: unit,
                              color: AppColors.criticalRed),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Chart
                      Text(
                        'Last Hour Trend',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.softOrganic,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ChartPreview(
                          readings: history,
                          isTemperature: isTemperature,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Description
                      Text(
                        isTemperature
                            ? 'Temperature affects plant metabolism and enzyme activity. Optimal ranges vary by crop. Configure thresholds in Settings.'
                            : 'Relative humidity affects transpiration and disease pressure. High humidity promotes fungal growth. Adjust thresholds in Settings.',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppColors.mutedText,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusChip(EnvironmentalStatus status, Color color) {
    final label = switch (status) {
      EnvironmentalStatus.normal => 'Normal',
      EnvironmentalStatus.warning => 'Warning',
      EnvironmentalStatus.critical => 'Critical',
    };
    final chipColor = switch (status) {
      EnvironmentalStatus.normal => AppColors.pulseGreen,
      EnvironmentalStatus.warning => AppColors.warningOrange,
      EnvironmentalStatus.critical => AppColors.criticalRed,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: chipColor,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: AppColors.mutedText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$value$unit',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
