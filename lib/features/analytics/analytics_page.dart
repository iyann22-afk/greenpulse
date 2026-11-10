import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_state.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/sensor_reading.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isTemperature = true;
  int _selectedPeriodHours = 1;
  int? _touchedIndex;

  static const _periods = [
    (label: '1H', hours: 1),
    (label: '6H', hours: 6),
    (label: '24H', hours: 24),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<AppState>(
      builder: (context, state, _) {
        final readings = state.historyForDuration(
            Duration(hours: _selectedPeriodHours));

        final values = readings
            .map((r) => _isTemperature ? r.temperature : r.humidity)
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
        final latest =
            values.isEmpty ? 0.0 : values.last;
        final unit = _isTemperature ? '°C' : '%';
        final color =
            _isTemperature ? AppColors.pulseGreen : const Color(0xFF1565C0);

        return Scaffold(
          backgroundColor: AppColors.softOrganic,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // ── Header ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Analytics',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w800,
                            fontSize: 28,
                            color: AppColors.darkText,
                          ),
                        ),
                        const Text(
                          'Historical sensor data · Simulated',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Metric selector ────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.forestGreen.withOpacity(0.07),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _MetricTab(
                            label: 'Temperature',
                            icon: Icons.thermostat_rounded,
                            isSelected: _isTemperature,
                            selectedColor: AppColors.pulseGreen,
                            onTap: () =>
                                setState(() => _isTemperature = true),
                          ),
                          _MetricTab(
                            label: 'Humidity',
                            icon: Icons.water_drop_rounded,
                            isSelected: !_isTemperature,
                            selectedColor: const Color(0xFF1565C0),
                            onTap: () =>
                                setState(() => _isTemperature = false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Period selector ────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Row(
                      children: _periods.map((p) {
                        final selected = p.hours == _selectedPeriodHours;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _selectedPeriodHours = p.hours;
                              _touchedIndex = null;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected
                                    ? color
                                    : AppColors.pureWhite,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                          color: color.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : [],
                                border: Border.all(
                                  color: selected
                                      ? color
                                      : AppColors.mutedText.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                p.label,
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: selected
                                      ? Colors.white
                                      : AppColors.mutedText,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // ── Stats Row ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        _StatCard(
                            label: 'Latest',
                            value: latest.toStringAsFixed(1),
                            unit: unit,
                            color: color,
                            icon: Icons.radio_button_checked),
                        const SizedBox(width: 10),
                        _StatCard(
                            label: 'Average',
                            value: avg.toStringAsFixed(1),
                            unit: unit,
                            color: AppColors.mutedText,
                            icon: Icons.show_chart),
                        const SizedBox(width: 10),
                        _StatCard(
                            label: 'Min',
                            value: min.toStringAsFixed(1),
                            unit: unit,
                            color: AppColors.warningOrange,
                            icon: Icons.arrow_downward_rounded),
                        const SizedBox(width: 10),
                        _StatCard(
                            label: 'Max',
                            value: max.toStringAsFixed(1),
                            unit: unit,
                            color: AppColors.criticalRed,
                            icon: Icons.arrow_upward_rounded),
                      ],
                    ),
                  ),
                ),

                // ── Chart ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: SectionHeader(
                      title: _isTemperature
                          ? 'Temperature History'
                          : 'Humidity History',
                      subtitle:
                          '${readings.length} readings · Last $_selectedPeriodHours hour${_selectedPeriodHours > 1 ? "s" : ""}',
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.forestGreen.withOpacity(0.07),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: readings.isEmpty
                          ? const SizedBox(
                              height: 220,
                              child: Center(
                                child: Text(
                                  'No data for selected period',
                                  style: TextStyle(
                                    color: AppColors.mutedText,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ),
                            )
                          : _buildChart(readings, color, unit),
                    ),
                  ),
                ),

                // ── Info footer ───────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 14, color: AppColors.mutedText),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'All data is locally simulated. No real sensors or MQTT connection.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: AppColors.mutedText,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChart(
      List<SensorReading> readings, Color color, String unit) {
    // Downsample for performance if too many points
    final display = readings.length > 60
        ? _downsample(readings, 60)
        : readings;

    final spots = <FlSpot>[];
    for (int i = 0; i < display.length; i++) {
      final val = _isTemperature ? display[i].temperature : display[i].humidity;
      spots.add(FlSpot(i.toDouble(), val));
    }

    final minY = (spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 3)
        .floorToDouble();
    final maxY = (spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 3)
        .ceilToDouble();

    final labelStep = (display.length / 5).ceil();

    return Column(
      children: [
        SizedBox(
          height: 230,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (maxY - minY) / 5,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: AppColors.mutedText.withOpacity(0.1),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    getTitlesWidget: (val, meta) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Text(
                        '${val.toStringAsFixed(0)}$unit',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.mutedText,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (val, meta) {
                      final idx = val.toInt();
                      if (idx % labelStep != 0 || idx >= display.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          DateFormatter.formatChartLabel(
                              display[idx].timestamp),
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.mutedText,
                            fontFamily: 'Inter',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(
                      color: AppColors.mutedText.withOpacity(0.2), width: 1),
                  left: BorderSide(
                      color: AppColors.mutedText.withOpacity(0.2), width: 1),
                ),
              ),
              minX: 0,
              maxX: (spots.length - 1).toDouble(),
              minY: minY,
              maxY: maxY,
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                touchCallback: (event, response) {
                  if (response?.lineBarSpots != null) {
                    setState(() {
                      _touchedIndex =
                          response!.lineBarSpots!.first.spotIndex;
                    });
                  }
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (spot) => AppColors.forestGreen,
                  tooltipRoundedRadius: 10,
                  getTooltipItems: (spots) => spots.map((spot) {
                    final idx = spot.spotIndex;
                    final ts = idx < display.length
                        ? DateFormatter.formatShortTime(display[idx].timestamp)
                        : '';
                    return LineTooltipItem(
                      '${spot.y.toStringAsFixed(1)}$unit\n$ts',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: color,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, _) =>
                        spot.x.toInt() == _touchedIndex,
                    getDotPainter: (_, __, ___, ____) =>
                        FlDotCirclePainter(
                      radius: 5,
                      color: color,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        color.withOpacity(0.2),
                        color.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          ),
        ),
      ],
    );
  }

  List<SensorReading> _downsample(List<SensorReading> data, int targetCount) {
    if (data.length <= targetCount) return data;
    final step = data.length / targetCount;
    return List.generate(
        targetCount, (i) => data[(i * step).floor().clamp(0, data.length - 1)]);
  }
}

// ── Metric Tab ────────────────────────────────────────────────────────────

class _MetricTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _MetricTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.mutedText,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isSelected ? Colors.white : AppColors.mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(height: 4),
            Text(
              '$value$unit',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                color: AppColors.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
