import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_state.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/greenpulse_logo.dart';
import '../../core/widgets/greenhouse_illustration.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/sensor_reading.dart';
import 'widgets/animated_sensor_value.dart';
import 'widgets/chart_preview.dart';
import 'widgets/sensor_detail_sheet.dart';
import 'widgets/notifications_panel.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isRefreshing = false;

  Future<void> _doRefresh(AppState state) async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await state.refresh();
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _isRefreshing = false);
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationsPanel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<AppState>(
      builder: (context, state, _) {
        final reading = state.currentReading;
        final envStatus = state.environmentalStatus;
        final isConnected = state.isConnected;

        return Scaffold(
          backgroundColor: AppColors.softOrganic,
          body: RefreshIndicator(
            onRefresh: () => _doRefresh(state),
            color: AppColors.pulseGreen,
            backgroundColor: AppColors.pureWhite,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── App Bar ──────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        children: [
                          const GreenPulseLogo(size: 38, animate: true),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'GREENPULSE',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: AppColors.forestGreen,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                AppConstants.appTagline,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  color: AppColors.mutedText,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Stack(
                            children: [
                              IconButton(
                                onPressed: () => _showNotifications(context),
                                icon: const Icon(Icons.notifications_outlined),
                                color: AppColors.forestGreen,
                                iconSize: 26,
                              ),
                              if (state.unreadNotificationCount > 0)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: const BoxDecoration(
                                      color: AppColors.criticalRed,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        state.unreadNotificationCount > 9
                                            ? '9+'
                                            : '${state.unreadNotificationCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (_isRefreshing)
                            const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.pulseGreen,
                                ),
                              ),
                            )
                          else
                            IconButton(
                              onPressed: () => _doRefresh(state),
                              icon: const Icon(Icons.refresh_rounded),
                              color: AppColors.pulseGreen,
                              iconSize: 26,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Welcome ──────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good ${_greeting()}, Farmer! 👋',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.mutedText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.greenhouseName,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Greenhouse Hero ───────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: SizedBox(
                        height: 190,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            const GreenhouseHeroIllustration(),
                            // Info overlay
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      AppColors.forestGreen.withOpacity(0.85),
                                    ],
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on_rounded,
                                                size: 14,
                                                color: AppColors.freshLime,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                AppConstants.defaultLocation,
                                                style: const TextStyle(
                                                  fontFamily: 'Inter',
                                                  color: AppColors.freshLime,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.eco_rounded,
                                                size: 14,
                                                color: Colors.white70,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                state.plantType,
                                                style: const TextStyle(
                                                  fontFamily: 'Manrope',
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    StatusBadge(
                                      connectionState: isConnected
                                          ? DeviceConnectionState.connected
                                          : DeviceConnectionState.disconnected,
                                      compact: true,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Demo tag
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.warningOrange.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.science_outlined,
                                        size: 11, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      'DEMO MODE',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Sensor Cards ──────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: SectionHeader(
                      title: 'Live Sensors',
                      subtitle: reading != null
                          ? 'Updated ${DateFormatter.formatTimestamp(reading.timestamp)}'
                          : 'Waiting for data...',
                      trailing: isConnected
                          ? null
                          : const Icon(Icons.wifi_off_rounded,
                              color: AppColors.criticalRed, size: 18),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Row(
                      children: [
                        // Temperature card
                        Expanded(
                          child: _SensorCard(
                            label: 'Temperature',
                            value: reading?.temperature,
                            unit: '°C',
                            icon: Icons.thermostat_rounded,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                            ),
                            iconColor: AppColors.pulseGreen,
                            isStale: !isConnected,
                            onTap: () => _showSensorDetail(
                              context,
                              state,
                              isTemperature: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Humidity card
                        Expanded(
                          child: _SensorCard(
                            label: 'Humidity',
                            value: reading?.humidity,
                            unit: '%',
                            icon: Icons.water_drop_rounded,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                            ),
                            iconColor: const Color(0xFF1565C0),
                            isStale: !isConnected,
                            onTap: () => _showSensorDetail(
                              context,
                              state,
                              isTemperature: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Environmental Status ──────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(
                          title: 'Environmental Overview',
                          subtitle: 'Based on demo thresholds',
                        ),
                        _EnvironmentalCard(
                          status: envStatus,
                          description: state.environmentalStatusDescription,
                          thresholds: state.thresholds,
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Chart Preview ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(
                          title: 'Temperature Trend',
                          subtitle: 'Last hour — simulated data',
                        ),
                        AppCard(
                          padding: const EdgeInsets.all(16),
                          child: ChartPreview(
                            readings: state.historyForDuration(
                                const Duration(hours: 1)),
                            isTemperature: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Last Updated footer ───────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 13, color: AppColors.mutedText),
                        const SizedBox(width: 6),
                        Text(
                          reading != null
                              ? 'Last updated: ${DateFormatter.formatFullDateTime(reading.timestamp)}'
                              : 'Waiting for sensor data...',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.mutedText,
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

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  void _showSensorDetail(BuildContext context, AppState state,
      {required bool isTemperature}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SensorDetailSheet(
        isTemperature: isTemperature,
      ),
    );
  }
}

// ── Sensor Card Widget ──────────────────────────────────────────────────────

class _SensorCard extends StatelessWidget {
  final String label;
  final double? value;
  final String unit;
  final IconData icon;
  final LinearGradient gradient;
  final Color iconColor;
  final bool isStale;
  final VoidCallback? onTap;

  const _SensorCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.gradient,
    required this.iconColor,
    required this.isStale,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                if (isStale)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.criticalRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'STALE',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: AppColors.criticalRed,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                else
                  Icon(Icons.chevron_right_rounded,
                      color: iconColor.withOpacity(0.5), size: 18),
              ],
            ),
            const SizedBox(height: 14),
            AnimatedSensorValue(
              value: value,
              unit: unit,
              color: iconColor,
              isStale: isStale,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.mutedText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Environmental Card ──────────────────────────────────────────────────────

class _EnvironmentalCard extends StatelessWidget {
  final EnvironmentalStatus status;
  final String description;
  final dynamic thresholds;

  const _EnvironmentalCard({
    required this.status,
    required this.description,
    required this.thresholds,
  });

  @override
  Widget build(BuildContext context) {
    final (color, icon, bgColor) = switch (status) {
      EnvironmentalStatus.normal => (
          AppColors.pulseGreen,
          Icons.check_circle_rounded,
          const Color(0xFFE8F5E9),
        ),
      EnvironmentalStatus.warning => (
          AppColors.warningOrange,
          Icons.warning_amber_rounded,
          const Color(0xFFFFF8E1),
        ),
      EnvironmentalStatus.critical => (
          AppColors.criticalRed,
          Icons.error_rounded,
          const Color(0xFFFFEBEE),
        ),
    };

    return AppCard(
      padding: const EdgeInsets.all(18),
      color: bgColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _statusLabel(status),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: color,
                      ),
                    ),
                    Text(
                      'Environmental Condition',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              description,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: color.withOpacity(0.9),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '⚠️ Thresholds are demonstration values only — not universal agricultural recommendations.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              color: AppColors.mutedText,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(EnvironmentalStatus s) {
    switch (s) {
      case EnvironmentalStatus.normal:
        return 'All Good — Optimal Conditions';
      case EnvironmentalStatus.warning:
        return 'Attention Needed';
      case EnvironmentalStatus.critical:
        return 'Critical — Immediate Action!';
    }
  }
}
