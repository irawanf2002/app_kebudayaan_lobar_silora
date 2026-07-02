import 'package:intl/intl.dart';

class DateFormatter {
  static String format(DateTime date) {
    return DateFormat("dd MMM yyyy", "id_ID").format(date);
  }

  static String formatWithTime(DateTime date) {
    return DateFormat("dd MMM yyyy • HH:mm", "id_ID").format(date);
  }

  static String relative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return "Baru saja";
    if (diff.inMinutes < 60) return "${diff.inMinutes} menit lalu";
    if (diff.inHours < 24) return "${diff.inHours} jam lalu";
    if (diff.inDays < 7) return "${diff.inDays} hari lalu";

    return format(date);
  }
}
