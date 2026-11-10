import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_colors.dart';
import '../../app/app_state.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/threshold_config.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late TextEditingController _nameCtrl;
  String? _selectedPlantType;

  // Threshold sliders
  late double _minTemp;
  late double _maxTemp;
  late double _minHumidity;
  late double _maxHumidity;

  bool _initialized = false;

  void _initFromState(AppState state) {
    if (_initialized) return;
    _initialized = true;
    _nameCtrl =
        TextEditingController(text: state.greenhouseName);
    _selectedPlantType = state.plantType;
    _minTemp = state.thresholds.minTemperature;
    _maxTemp = state.thresholds.maxTemperature;
    _minHumidity = state.thresholds.minHumidity;
    _maxHumidity = state.thresholds.maxHumidity;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _saveThresholds(AppState state) {
    if (_minTemp >= _maxTemp) {
      _showValidationError(
          'Min temperature must be less than max temperature.');
      return;
    }
    if (_minHumidity >= _maxHumidity) {
      _showValidationError(
          'Min humidity must be less than max humidity.');
      return;
    }
    state.updateThresholds(ThresholdConfig(
      minTemperature: _minTemp,
      maxTemperature: _maxTemp,
      minHumidity: _minHumidity,
      maxHumidity: _maxHumidity,
    ));
    _showSuccess('Thresholds updated successfully!');
  }

  void _showValidationError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(child: Text(msg)),
        ],
      ),
      backgroundColor: AppColors.criticalRed,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(child: Text(msg)),
        ],
      ),
      backgroundColor: AppColors.pulseGreen,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<AppState>(
      builder: (context, state, _) {
        _initFromState(state);

        return Scaffold(
          backgroundColor: AppColors.softOrganic,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // ── Header ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w800,
                            fontSize: 28,
                            color: AppColors.darkText,
                          ),
                        ),
                        Text(
                          'Configure greenhouse & monitoring',
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

                // ── Greenhouse Config ──────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: const SectionHeader(
                      title: 'Greenhouse',
                      subtitle: 'Basic configuration',
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Greenhouse Name',
                              prefixIcon: Icon(Icons.villa_rounded,
                                  color: AppColors.pulseGreen),
                            ),
                            onChanged: (v) =>
                                state.updateGreenhouseName(v),
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            value: _selectedPlantType,
                            decoration: const InputDecoration(
                              labelText: 'Plant Type',
                              prefixIcon: Icon(Icons.eco_rounded,
                                  color: AppColors.pulseGreen),
                            ),
                            items: AppConstants.plantTypes
                                .map((t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(t,
                                          style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 14)),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(
                                    () => _selectedPlantType = v);
                                state.updatePlantType(v);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Threshold Config ───────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: const SectionHeader(
                      title: 'Monitoring Thresholds',
                      subtitle:
                          'Demo values only — not universal agricultural recommendations',
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
                          // Temperature
                          _ThresholdRow(
                            label: 'Temperature Range',
                            icon: Icons.thermostat_rounded,
                            color: AppColors.pulseGreen,
                            unit: '°C',
                            minVal: _minTemp,
                            maxVal: _maxTemp,
                            absMin: 10.0,
                            absMax: 50.0,
                            onMinChanged: (v) =>
                                setState(() => _minTemp = v),
                            onMaxChanged: (v) =>
                                setState(() => _maxTemp = v),
                          ),
                          const Divider(height: 24),
                          // Humidity
                          _ThresholdRow(
                            label: 'Humidity Range',
                            icon: Icons.water_drop_rounded,
                            color: const Color(0xFF1565C0),
                            unit: '%',
                            minVal: _minHumidity,
                            maxVal: _maxHumidity,
                            absMin: 10.0,
                            absMax: 100.0,
                            onMinChanged: (v) =>
                                setState(() => _minHumidity = v),
                            onMaxChanged: (v) =>
                                setState(() => _maxHumidity = v),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _saveThresholds(state),
                              icon: const Icon(Icons.save_rounded),
                              label: const Text('Save Thresholds'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '⚠️ These are demonstration thresholds for this simulation. Consult agricultural guidelines for real crop management.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              color: AppColors.mutedText,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Notifications ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: const SectionHeader(
                      title: 'Notifications',
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: AppCard(
                      padding: const EdgeInsets.all(4),
                      child: SwitchListTile(
                        value: state.notificationsEnabled,
                        onChanged: state.toggleNotifications,
                        activeColor: AppColors.pulseGreen,
                        title: const Text(
                          'In-app Alerts',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.darkText,
                          ),
                        ),
                        subtitle: const Text(
                          'Show alerts when sensor values exceed thresholds',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: AppColors.mutedText,
                          ),
                        ),
                        secondary: const Icon(
                          Icons.notifications_active_rounded,
                          color: AppColors.pulseGreen,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Reset ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: const SectionHeader(
                      title: 'Demo Data',
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _confirmReset(context, state),
                              icon: const Icon(Icons.restart_alt_rounded,
                                  color: AppColors.warningOrange),
                              label: const Text(
                                'Reset Demo Configuration',
                                style: TextStyle(
                                  color: AppColors.warningOrange,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppColors.warningOrange),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Resets greenhouse name, plant type, thresholds, and notifications to defaults.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: AppColors.mutedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── About ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: const SectionHeader(title: 'About'),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                    child: AppCard(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        children: [
                          _AboutRow(
                              label: 'Application',
                              value: 'GREENPULSE'),
                          _AboutRow(
                              label: 'Version',
                              value: AppConstants.appVersion),
                          _AboutRow(
                              label: 'Platform',
                              value: 'Flutter · Dart'),
                          _AboutRow(
                              label: 'Data Source',
                              value: 'Simulated (Demo)'),
                          _AboutRow(
                              label: 'MQTT',
                              value: 'Not connected (future)',
                              isLast: true),
                        ],
                      ),
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

  void _confirmReset(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Reset Demo Data',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'This will reset all settings to their default demo values. Continue?',
          style: TextStyle(fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.mutedText)),
          ),
          ElevatedButton(
            onPressed: () {
              state.resetDemoData();
              setState(() {
                _initialized = false;
                _nameCtrl.text = AppConstants.defaultGreenhouseName;
                _selectedPlantType = AppConstants.defaultPlantType;
                _minTemp = AppConstants.defaultMinTemp;
                _maxTemp = AppConstants.defaultMaxTemp;
                _minHumidity = AppConstants.defaultMinHumidity;
                _maxHumidity = AppConstants.defaultMaxHumidity;
                _initialized = true;
              });
              Navigator.pop(context);
              _showSuccess('Demo configuration reset to defaults.');
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warningOrange),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

// ── Threshold Row ─────────────────────────────────────────────────────────

class _ThresholdRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final String unit;
  final double minVal;
  final double maxVal;
  final double absMin;
  final double absMax;
  final ValueChanged<double> onMinChanged;
  final ValueChanged<double> onMaxChanged;

  const _ThresholdRow({
    required this.label,
    required this.icon,
    required this.color,
    required this.unit,
    required this.minVal,
    required this.maxVal,
    required this.absMin,
    required this.absMax,
    required this.onMinChanged,
    required this.onMaxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.darkText,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${minVal.toStringAsFixed(1)}$unit – ${maxVal.toStringAsFixed(1)}$unit',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            SizedBox(
              width: 36,
              child: Text('Min',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.mutedText)),
            ),
            Expanded(
              child: Slider(
                value: minVal,
                min: absMin,
                max: maxVal - 1,
                divisions: ((maxVal - 1 - absMin) * 2).toInt().clamp(1, 200),
                activeColor: color,
                inactiveColor: color.withOpacity(0.2),
                onChanged: onMinChanged,
              ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                '${minVal.toStringAsFixed(1)}$unit',
                style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: color),
              ),
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(
              width: 36,
              child: Text('Max',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: AppColors.mutedText)),
            ),
            Expanded(
              child: Slider(
                value: maxVal,
                min: minVal + 1,
                max: absMax,
                divisions: ((absMax - minVal - 1) * 2).toInt().clamp(1, 200),
                activeColor: color,
                inactiveColor: color.withOpacity(0.2),
                onChanged: onMaxChanged,
              ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                '${maxVal.toStringAsFixed(1)}$unit',
                style: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: color),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── About Row ─────────────────────────────────────────────────────────────

class _AboutRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _AboutRow({required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          dense: true,
          title: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.mutedText,
            ),
          ),
          trailing: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.darkText,
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 16,
            color: AppColors.mutedText.withOpacity(0.1),
          ),
      ],
    );
  }
}
