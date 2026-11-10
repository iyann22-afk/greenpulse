# GREENPULSE 🌿

**Smart Agriculture IoT Monitoring**

> *Grow Smarter. Monitor Better.*

---

## Project Description

GREENPULSE is a **premium Flutter mobile application** for real-time greenhouse environmental monitoring. It provides temperature and humidity readings, MQTT connection status simulation, interactive historical charts, and device management — all with a visually rich, nature-tech design identity.

Built with clean, extensible architecture, GREENPULSE's simulated dummy data layer can be replaced with a real MQTT broker in future milestones without changing the UI code.

---

## Screenshots

| Dashboard | Analytics | Devices | Settings |
|-----------|-----------|---------|----------|
| _Run app to capture_ | _Run app to capture_ | _Run app to capture_ | _Run app to capture_ |

**To capture screenshots:**

```bash
# Run app on emulator/device, then:
flutter screenshot --out screenshots/dashboard.png
# Or use Android Studio / Xcode screenshot tool
# Or: adb shell screencap -p /sdcard/screen.png && adb pull /sdcard/screen.png
```

---

## Main Features

- 🌡️ **Live sensor display** — Animated temperature and humidity values
- 📡 **MQTT simulation** — Connected / Disconnected / Demo Mode states
- 📊 **Interactive analytics charts** — FL Chart powered, with 1H / 6H / 24H filters
- 🏭 **Device management** — ESP8266 + DHT22 sensor info with connection toggle
- ⚙️ **Settings** — Configurable thresholds, greenhouse name, plant type
- 🔔 **In-app notifications** — Automatic alerts when values exceed thresholds
- 🌿 **Custom botanical UI** — Canvas-drawn greenhouse hero illustration
- 📱 **Responsive** — Bottom nav on phones, navigation rail on tablets
- 🔄 **Auto-refresh** — 12-second sensor update cycle + manual refresh
- 📴 **Offline** — Works 100% without internet connection

---

## Technical Stack

| Component | Technology |
|-----------|------------|
| Framework | Flutter 3.x (stable channel) |
| Language | Dart 3.x |
| State Management | Provider + ChangeNotifier |
| Charts | FL Chart 0.69.x |
| Navigation | Flutter NavigationBar / NavigationRail |
| Formatting | intl 0.19.x |
| Architecture | Feature-based with data/domain separation |

---

## Project Structure

```
greenpulse/
├── lib/
│   ├── main.dart                          # Entry point
│   │
│   ├── app/
│   │   ├── app.dart                       # MaterialApp + ChangeNotifierProvider
│   │   ├── app_colors.dart                # Brand color tokens
│   │   ├── app_theme.dart                 # ThemeData (Material 3)
│   │   └── app_state.dart                 # Global ChangeNotifier (sensor state)
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart         # App-wide constants & defaults
│   │   ├── utils/
│   │   │   └── date_formatter.dart        # Timestamp formatting
│   │   └── widgets/
│   │       ├── app_card.dart              # Reusable card widget
│   │       ├── greenpulse_logo.dart       # Custom canvas logo (leaf + signal)
│   │       ├── greenhouse_illustration.dart # Canvas botanical hero illustration
│   │       ├── section_header.dart        # Section title widget
│   │       └── status_badge.dart          # Connection & environment badges
│   │
│   ├── data/
│   │   ├── models/
│   │   │   ├── sensor_reading.dart        # SensorReading model + ConnectionState
│   │   │   └── threshold_config.dart      # ThresholdConfig model
│   │   └── sources/
│   │       ├── sensor_data_source.dart    # Abstract interface
│   │       └── dummy_sensor_data_source.dart  # Simulated implementation
│   │
│   ├── features/
│   │   ├── dashboard/
│   │   │   ├── dashboard_page.dart        # Home dashboard (main screen)
│   │   │   └── widgets/
│   │   │       ├── animated_sensor_value.dart  # Animated number display
│   │   │       ├── chart_preview.dart     # Mini chart for dashboard
│   │   │       ├── notifications_panel.dart    # Bottom sheet notification list
│   │   │       └── sensor_detail_sheet.dart   # Sensor tap detail view
│   │   │
│   │   ├── analytics/
│   │   │   └── analytics_page.dart        # Historical charts page
│   │   │
│   │   ├── devices/
│   │   │   └── devices_page.dart          # Device info + connection toggle
│   │   │
│   │   └── settings/
│   │       └── settings_page.dart         # Configuration page
│   │
│   └── navigation/
│       └── main_navigation.dart           # Bottom nav + navigation rail
│
├── test/
│   └── widget_test.dart                   # Unit & integration tests
│
├── pubspec.yaml
└── README.md
```

---

## Requirements

- Flutter SDK **3.0.0** or higher (stable channel)
- Dart SDK **3.0.0** or higher
- Android: API 21+ (Android 5.0+)
- iOS: 12.0+

---

## Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-username/greenpulse.git
cd greenpulse

# 2. Install dependencies
flutter pub get

# 3. Verify setup
flutter doctor
```

---

## Running on Android

```bash
# List connected devices
flutter devices

# Run debug build
flutter run

# Build release APK
flutter build apk --release

# Build debug APK
flutter build apk --debug

# Install APK directly
flutter install
```

The debug APK will be at `build/app/outputs/flutter-apk/app-debug.apk`

---

## Running on iOS

> **Requires macOS with Xcode 14+**

```bash
# Install iOS pods
cd ios && pod install && cd ..

# Run on iOS Simulator
flutter run -d "iPhone 15"

# Build iOS archive (requires Apple Developer account)
flutter build ios --release

# Open in Xcode for device deployment
open ios/Runner.xcworkspace
```

---

## Dummy Data Explanation

GREENPULSE uses a fully local simulation — **no real sensor, MQTT broker, or internet connection is required**.

### How the simulation works:

1. **Historical seed data** — 97 readings at 15-minute intervals over 24 hours are pre-generated with realistic day/night temperature and humidity cycles.

2. **Periodic updates** — A `Timer` fires every **12 seconds**, generating a new reading with ±0.8°C / ±1.5% random variation from the previous value.

3. **Bounded variation** — Values are clamped within `18–42°C` and `30–95%` to prevent unrealistic jumps.

4. **Connection simulation** — Toggling the switch in Devices pauses/resumes the timer, changing the connection badge on the dashboard.

5. **Threshold alerts** — When values approach or exceed configured thresholds, the app generates in-app notifications.

### Starting values:
- Temperature: **27.4°C**
- Humidity: **68%**

---

## MQTT Integration Roadmap

The architecture is prepared for MQTT replacement. Here is how to do it:

### Step 1 — Add MQTT dependency

```yaml
# pubspec.yaml
dependencies:
  mqtt_client: ^10.0.0
```

### Step 2 — Implement MqttSensorDataSource

```dart
class MqttSensorDataSource implements SensorDataSource {
  final MqttServerClient _client;
  final _controller = StreamController<SensorReading>.broadcast();

  MqttSensorDataSource({required String host, required String clientId})
      : _client = MqttServerClient(host, clientId);

  @override
  Stream<SensorReading> get readings => _controller.stream;

  @override
  Future<void> start() async {
    await _client.connect();
    _client.subscribe('greenpulse/gh01/temperature', MqttQos.atLeastOnce);
    _client.subscribe('greenpulse/gh01/humidity', MqttQos.atLeastOnce);
    _client.updates!.listen(_onMessage);
  }

  void _onMessage(List<MqttReceivedMessage> messages) {
    // Parse and emit SensorReading from MQTT payload
  }

  @override
  Future<void> refresh() async { /* request latest from broker */ }

  @override
  void dispose() { _client.disconnect(); _controller.close(); }
}
```

### Step 3 — Swap the data source in AppState

```dart
// In app_state.dart — replace:
final DummySensorDataSource _dataSource = DummySensorDataSource();

// With:
final MqttSensorDataSource _dataSource = MqttSensorDataSource(
  host: 'your-broker.example.com',
  clientId: 'greenpulse-app',
);
```

**No UI changes required.** The dashboard, analytics charts, and device page all consume the `SensorDataSource` stream transparently.

---

## MQTT Topics

| Topic | Purpose |
|-------|---------|
| `greenpulse/gh01/temperature` | Temperature readings (°C) |
| `greenpulse/gh01/humidity` | Humidity readings (%) |
| `greenpulse/gh01/status` | Device status messages |

---

## Known Limitations

- **Simulation only** — No real MQTT broker is connected in this version.
- **No persistence** — Settings reset when the app is closed (session-only state).
- **No push notifications** — In-app alerts only; no Firebase/APNs integration.
- **Fonts** — Manrope and Inter fonts are referenced by name; they fall back to system fonts if not bundled as assets. Add font files to `assets/fonts/` to enable custom typography.
- **iOS build** — Requires macOS + Xcode. Cannot be built on Windows.
- **Sensor history** — History is in-memory only; clears on app restart.

---

## GitHub Preparation

```bash
# Initialize git (if not already done)
git init
git add .
git commit -m "feat: initial GREENPULSE implementation

- Complete Flutter IoT monitoring dashboard
- Dashboard with animated sensor cards, greenhouse hero
- Analytics page with FL Chart (1H/6H/24H filters)  
- Devices page with MQTT simulation toggle
- Settings page with configurable thresholds
- DummySensorDataSource with 24h seeded history
- Environmental status calculation (Normal/Warning/Critical)
- In-app notification system
- Custom canvas GREENPULSE logo and botanical illustration
- Responsive layout (bottom nav / navigation rail)
- Full unit test suite"

# Push to GitHub
git remote add origin https://github.com/your-username/greenpulse.git
git branch -M main
git push -u origin main
```

---

## License

MIT License — See LICENSE file for details.

---

*GREENPULSE — Smart Agriculture IoT Monitoring · Grow Smarter. Monitor Better.*
