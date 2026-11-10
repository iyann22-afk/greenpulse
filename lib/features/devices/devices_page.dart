import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_state.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/sensor_reading.dart';

class DevicesPage extends StatelessWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final reading = state.currentReading;
        final isConnected = state.isConnected;
        final connState = isConnected
            ? DeviceConnectionState.connected
            : DeviceConnectionState.disconnected;

        return Scaffold(
          backgroundColor: AppColors.softOrganic,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // ── Header ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Devices',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 28,
                                  color: AppColors.darkText,
                                ),
                              ),
                              Text(
                                'IoT device management',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: AppColors.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(connectionState: connState),
                      ],
                    ),
                  ),
                ),

                // ── Device Hero Card ───────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isConnected
                              ? [
                                  AppColors.forestGreen,
                                  const Color(0xFF1E5C40),
                                ]
                              : [
                                  const Color(0xFF4A4A4A),
                                  const Color(0xFF2D2D2D),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: (isConnected
                                    ? AppColors.forestGreen
                                    : Colors.black)
                                .withOpacity(0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.2)),
                                ),
                                child: Icon(
                                  isConnected
                                      ? Icons.sensors_rounded
                                      : Icons.sensors_off_rounded,
                                  color: isConnected
                                      ? AppColors.freshLime
                                      : Colors.white54,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      AppConstants.defaultDeviceName,
                                      style: TextStyle(
                                        fontFamily: 'Manrope',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 17,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      AppConstants.defaultDeviceId,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.65),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Live readings mini display
                          if (isConnected && reading != null) ...[
                            Row(
                              children: [
                                _LiveReading(
                                  icon: Icons.thermostat_rounded,
                                  value:
                                      '${reading.temperature.toStringAsFixed(1)}°C',
                                  label: 'Temp',
                                ),
                                const SizedBox(width: 16),
                                _LiveReading(
                                  icon: Icons.water_drop_rounded,
                                  value:
                                      '${reading.humidity.toStringAsFixed(1)}%',
                                  label: 'Humidity',
                                ),
                                const SizedBox(width: 16),
                                _LiveReading(
                                  icon: Icons.access_time_rounded,
                                  value: DateFormatter.formatTime(
                                      reading.timestamp),
                                  label: 'Last Ping',
                                ),
                              ],
                            ),
                          ] else if (!isConnected) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.criticalRed.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: AppColors.criticalRed
                                        .withOpacity(0.4)),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.wifi_off_rounded,
                                      color: AppColors.criticalRed, size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    'Device offline — data stream paused',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Connection Toggle ──────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: AppCard(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (isConnected
                                      ? AppColors.pulseGreen
                                      : AppColors.criticalRed)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isConnected
                                  ? Icons.link_rounded
                                  : Icons.link_off_rounded,
                              color: isConnected
                                  ? AppColors.pulseGreen
                                  : AppColors.criticalRed,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isConnected
                                      ? 'Simulation Active'
                                      : 'Simulation Paused',
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: AppColors.darkText,
                                  ),
                                ),
                                Text(
                                  isConnected
                                      ? 'Sensor data updating every ${AppConstants.sensorUpdateIntervalSeconds}s'
                                      : 'Tap toggle to restart simulation',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: AppColors.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: isConnected,
                            onChanged: (_) => state.toggleConnection(),
                            activeColor: AppColors.pulseGreen,
                            activeTrackColor:
                                AppColors.pulseGreen.withOpacity(0.3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Device Info ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: const SectionHeader(
                      title: 'Device Information',
                      subtitle: 'Hardware & firmware details',
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: AppCard(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        children: [
                          _InfoRow('Device Name',
                              AppConstants.defaultDeviceName,
                              icon: Icons.memory_rounded),
                          _InfoRow('Device ID',
                              AppConstants.defaultDeviceId,
                              icon: Icons.fingerprint_rounded),
                          _InfoRow('Board',
                              AppConstants.defaultBoard,
                              icon: Icons.developer_board_rounded),
                          _InfoRow('Sensor',
                              AppConstants.defaultSensor,
                              icon: Icons.sensors_rounded),
                          _InfoRow('Mode', 'Simulation',
                              icon: Icons.science_outlined,
                              valueColor: AppColors.warningOrange),
                          _InfoRow('MQTT Status',
                              isConnected ? 'Simulated (Demo)' : 'Offline',
                              icon: Icons.cloud_outlined,
                              valueColor: isConnected
                                  ? AppColors.pulseGreen
                                  : AppColors.criticalRed,
                              isLast: true),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── MQTT Topics ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: const SectionHeader(
                      title: 'MQTT Topics',
                      subtitle: 'Reserved for future real implementation',
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.warningOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    color: AppColors.warningOrange, size: 16),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'No real MQTT broker is connected. These topics are prepared for future integration only.',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      color: AppColors.warningOrange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          _TopicRow(
                              label: 'Temperature',
                              topic: AppConstants.mqttTopicTemperature,
                              icon: Icons.thermostat_rounded),
                          const SizedBox(height: 10),
                          _TopicRow(
                              label: 'Humidity',
                              topic: AppConstants.mqttTopicHumidity,
                              icon: Icons.water_drop_rounded),
                          const SizedBox(height: 10),
                          _TopicRow(
                              label: 'Status',
                              topic: AppConstants.mqttTopicStatus,
                              icon: Icons.cloud_rounded),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                    child: SizedBox(height: 24)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  final bool isLast;

  const _InfoRow(
    this.label,
    this.value, {
    required this.icon,
    this.valueColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.mutedText),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: AppColors.mutedText,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: valueColor ?? AppColors.darkText,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 46,
            color: AppColors.mutedText.withOpacity(0.1),
          ),
      ],
    );
  }
}

// ── Live Reading mini display ─────────────────────────────────────────────

class _LiveReading extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _LiveReading({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.freshLime, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ── MQTT Topic Row ────────────────────────────────────────────────────────

class _TopicRow extends StatelessWidget {
  final String label;
  final String topic;
  final IconData icon;

  const _TopicRow({
    required this.label,
    required this.topic,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.softOrganic,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.pulseGreen),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    color: AppColors.mutedText,
                  ),
                ),
                Text(
                  topic,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppColors.forestGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
