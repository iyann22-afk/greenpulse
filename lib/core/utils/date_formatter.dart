import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return DateFormat('HH:mm').format(dt);
    } else {
      return DateFormat('MMM d, HH:mm').format(dt);
    }
  }

  static String formatTime(DateTime dt) {
    return DateFormat('HH:mm:ss').format(dt);
  }

  static String formatShortTime(DateTime dt) {
    return DateFormat('HH:mm').format(dt);
  }

  static String formatFullDateTime(DateTime dt) {
    return DateFormat('MMM d, yyyy · HH:mm:ss').format(dt);
  }

  static String formatChartLabel(DateTime dt) {
    return DateFormat('HH:mm').format(dt);
  }
}
