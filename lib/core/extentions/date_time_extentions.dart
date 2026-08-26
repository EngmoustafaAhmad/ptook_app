
import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  /// Checks if the date/time has passed relative to now.
  bool get isExpired => isBefore(DateTime.now());

  /// Checks if the date falls on today's calendar day.
  bool get isToday {
    final now = DateTime.now();
    return day == now.day && month == now.month && year == now.year;
  }

  /// Returns a human-readable relative time string (e.g., "5 minutes ago").
  String get timeAgo {
    final now = DateTime.now();

    // Handle future dates safely
    if (isAfter(now)) return 'Soon';

    final diff = now.difference(this);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      return diff.inMinutes == 1 ? '1 minute ago' : '${diff.inMinutes} minutes ago';
    }
    if (diff.inHours < 24) {
      return diff.inHours == 1 ? '1 hour ago' : '${diff.inHours} hours ago';
    }
    if (diff.inDays < 7) {
      return diff.inDays == 1 ? '1 day ago' : '${diff.inDays} days ago';
    }

    final weeks = (diff.inDays / 7).floor();
    if (weeks < 4) {
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    }

    final months = (diff.inDays / 30).floor();
    if (months < 12) {
      return months == 1 ? '1 month ago' : '$months months ago';
    }

    final years = (diff.inDays / 365).floor();
    return years == 1 ? '1 year ago' : '$years years ago';
  }

  /// Formats date to: "20/08/2026"
  String get formattedDate => DateFormat('dd/MM/yyyy', 'en').format(this);

  /// Formats date and time to: "20/08/2026 - 09:30 PM"
  String get formattedDateTime => DateFormat('dd/MM/yyyy - hh:mm a', 'en').format(this);
}