// ── DateTime Extensions ──────────────────────────────────────────────────────
import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  bool get isExpired => isBefore(DateTime.now());

  bool get isToday {
    final now = DateTime.now();
    return day == now.day && month == now.month && year == now.year;
  }

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    if (diff.inDays < 30) return 'منذ ${(diff.inDays / 7).floor()} أسبوع';
    if (diff.inDays < 365) return 'منذ ${(diff.inDays / 30).floor()} شهر';
    return 'منذ ${(diff.inDays / 365).floor()} سنة';
  }

  String get formattedDate => DateFormat('dd/MM/yyyy', 'ar').format(this);

  String get formattedDateTime {
    final hour = this.hour > 12 ? this.hour - 12 : this.hour;
    final period = this.hour >= 12 ? 'م' : 'ص';
    final minute = this.minute.toString().padLeft(2, '0');
    final DateTime date = DateTime.parse(
      '$day/$month/$year - $hour:$minute $period',
    );
    return DateFormat('dd/MM/yyyy - hh:mm a', 'ar').format(date);
  }
}
