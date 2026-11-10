import 'package:flutter/material.dart';
import 'package:greenpulse/app/app_colors.dart';
import 'package:greenpulse/data/models/sensor_reading.dart';

class StatusBadge extends StatelessWidget {
  final DeviceConnectionState connectionState;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.connectionState,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = switch (connectionState) {
      DeviceConnectionState.connected => (
          AppColors.pulseGreen,
          'Connected',
          Icons.wifi_rounded
        ),
      DeviceConnectionState.disconnected => (
          AppColors.criticalRed,
          'Disconnected',
          Icons.wifi_off_rounded
        ),
      DeviceConnectionState.demoMode => (
          AppColors.warningOrange,
          'Demo Mode',
          Icons.science_outlined
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 6 : 8,
            height: compact ? 6 : 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          SizedBox(width: compact ? 4 : 6),
          Icon(icon, size: compact ? 10 : 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class EnvironmentStatusBadge extends StatelessWidget {
  final EnvironmentalStatus status;

  const EnvironmentStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = switch (status) {
      EnvironmentalStatus.normal => (
          AppColors.pulseGreen,
          'NORMAL',
          Icons.check_circle_rounded
        ),
      EnvironmentalStatus.warning => (
          AppColors.warningOrange,
          'WARNING',
          Icons.warning_amber_rounded
        ),
      EnvironmentalStatus.critical => (
          AppColors.criticalRed,
          'CRITICAL',
          Icons.error_rounded
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
