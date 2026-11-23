part of 'index.dart';

final _timeAgoNotifiers = <String, ValueNotifier<String>>{};

/// Extension on [DateTime] providing date and time formatting.
extension DateTimeExtension on DateTime {
  /// Returns this datetime as an ISO-8601 UTC string.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24, 10, 30);
  /// final utcString = date.toUtcString;
  /// // returns: '2024-02-24T10:30:00.000Z'
  /// ```
  String get toUtcString => toUtc().toIso8601String();

  /// Formats date as '24th, Feb 2024'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24);
  /// final formatted = date.toDdMmmYyyy;
  /// // returns: '24th, Feb 2024'
  /// ```
  String get toDdMmmYyyy {
    final day = this.day;
    final month = monthNameShort;
    final year = this.year;
    return '$day$_suffix, $month $year';
  }

  /// Returns day suffix (st, nd, rd, th).
  String get _suffix {
    if (day >= 11 && day <= 13) return 'th';

    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  /// Returns full month name.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24);
  /// final month = date.monthName;
  /// // returns: 'February'
  /// ```
  String get monthName => [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ][month - 1];

  /// Returns full day name.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2026, 6, 12);
  /// final dayName = date.dayName;
  /// // returns: 'Friday'
  /// ```
  String get dayName => [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ][weekday - 1];

  /// Returns short day name.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2026, 6, 12);
  /// final dayName = date.dayNameShort;
  /// // returns: 'Fri'
  /// ```
  String get dayNameShort =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];

  /// Returns short month name.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24);
  /// final month = date.monthNameShort;
  /// // returns: 'Feb'
  /// ```
  String get monthNameShort => [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];

  /// Formats date as '24 February 2024'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24);
  /// final formatted = date.toDdMmmmYyyy;
  /// // returns: '24 February 2024'
  /// ```
  String get toDdMmmmYyyy => '$day $monthName $year';

  /// Formats date as 'February 2024'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24);
  /// final formatted = date.toMonthYear;
  /// // returns: 'February 2024'
  /// ```
  String get toMonthYear => '$monthName $year';

  /// Formats date as '24/02/2026'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2026, 2, 24);
  /// final formatted = date.toDateWithSlashes;
  /// // returns: '24/02/2026'
  /// ```
  String get toDateWithSlashes =>
      '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';

  /// Formats date and time as '24/02/2026 12:03 AM'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2026, 2, 24, 0, 3);
  /// final formatted = date.toDateAndTimeWithSlashes;
  /// // returns: '24/02/2026 12:03 AM'
  /// ```
  String get toDateAndTimeWithSlashes => '$toDateWithSlashes $toTimeAmPm';

  /// Formats date as 'February 24, 2024'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24);
  /// final formatted = date.toMmmmDdYyyy;
  /// // returns: 'February 24, 2024'
  /// ```
  String get toMmmmDdYyyy => '$monthName $day, $year';

  /// Formats time as '10:30 PM'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24, 22, 30);
  /// final formatted = date.toTimeAmPm;
  /// // returns: '10:30 PM'
  /// ```
  String get toTimeAmPm {
    final amPm = hour < 12 ? 'AM' : 'PM';
    final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
    final formattedMinute = minute.toString().padLeft(2, '0');
    return '$formattedHour:$formattedMinute $amPm';
  }

  /// Formats time as '20:30'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24, 22, 30);
  /// final formatted = date.toTime;
  /// // returns: '20:30'
  /// ```
  String get toTime {
    final formattedHour = hour.toString().padLeft(2, '0');
    final formattedMinute = minute.toString().padLeft(2, '0');
    return '$formattedHour:$formattedMinute';
  }

  /// Formats date range as '24/02/2026 - 26/02/2026'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2026, 2, 24);
  /// final formatted = date.asRange(DateTime(2026, 2, 26));
  /// // returns: '24/02/2026 - 26/02/2026'
  /// ```
  String asRange(DateTime to) {
    if (isSameAs(to)) return toDateWithSlashes;
    return '$toDateWithSlashes - ${to.toDateWithSlashes}';
  }

  /// Returns every calendar day from this date through [end], inclusive.
  ///
  /// Days are built from calendar fields rather than a fixed 24-hour
  /// [Duration], so each one stays at midnight across daylight saving changes.
  ///
  /// Example:
  /// ```dart
  /// final days = DateTime(2026, 2, 24).daysThrough(DateTime(2026, 2, 26));
  /// // returns: [Feb 24, Feb 25, Feb 26]
  /// ```
  List<DateTime> daysThrough(DateTime end) {
    final count = DateTime.utc(
      end.year,
      end.month,
      end.day,
    ).difference(DateTime.utc(year, month, day)).inDays;

    return [for (var i = 0; i <= count; i++) DateTime(year, month, day + i)];
  }

  /// Returns true if this calendar day is earlier than the day of [date],
  /// ignoring the time of both.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24, 23, 0);
  /// final check = date.isBeforeDay(DateTime(2024, 2, 24, 8, 0));
  /// // returns: false
  /// ```
  bool isBeforeDay(DateTime date) => DateTime.utc(
    year,
    month,
    day,
  ).isBefore(DateTime.utc(date.year, date.month, date.day));

  /// Formats time as '10:30:05 PM'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24, 22, 30, 5);
  /// final formatted = date.toFullTimeAmPm;
  /// // returns: '10:30:05 PM'
  /// ```
  String get toFullTimeAmPm {
    final amPm = hour < 12 ? 'AM' : 'PM';
    final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
    final formattedMinute = minute.toString().padLeft(2, '0');
    final formattedSecond = second.toString().padLeft(2, '0');
    return '$formattedHour:$formattedMinute:$formattedSecond $amPm';
  }

  /// Formats date and time as '24th, Feb 2024 - 10:30 PM'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24, 22, 30);
  /// final formatted = date.toDateTime;
  /// // returns: '24th, Feb 2024 - 10:30 PM'
  /// ```
  String get toDateTime => '$toDdMmmYyyy - $toTimeAmPm';

  /// Formats date and time as '24 February 2024 10:30 PM'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24, 22, 30);
  /// final formatted = date.toDateTimeWithoutComma;
  /// // returns: '24 February 2024 10:30 PM'
  /// ```
  String get toDateTimeWithoutComma => '$toDdMmmmYyyy $toTimeAmPm';

  /// Formats date and time as 'February 24, 2024, 10:30 PM'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24, 22, 30);
  /// final formatted = date.toDateTimeLong;
  /// // returns: 'February 24, 2024, 10:30 PM'
  /// ```
  String get toDateTimeLong => '$toMmmmDdYyyy, $toTimeAmPm';

  /// Calculates time remaining in seconds until `now` and returns
  /// '04:39:01:58' or '0' if no time remaining.
  ///
  /// Example:
  /// ```dart
  /// final now = DateTime.now();
  /// final date = DateTime(2026, 6, 12, 10, 40);
  /// final remaining = date.timeRemainingUntil(now);
  /// // returns: '00:01:00:00'
  /// ```
  String timeRemainingUntil([DateTime? now]) {
    now ??= DateTime.now();

    final d = difference(now).inSeconds > 0
        ? difference(now)
        : const Duration(seconds: 0);

    if (d.inSeconds <= 0) return '0';

    final days = d.inDays;
    final hours = d.inHours.remainder(24);
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    return '${days.toString().padLeft(2, '0')}:'
        '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}'
        ':${seconds.toString().padLeft(2, '0')}';
  }

  /// Formats date as 'Fri June 12, 2026'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2026, 6, 12);
  /// final formatted = date.toDayMonthYear;
  /// // returns: 'Fri June 12, 2026'
  /// ```
  String get toDayMonthYear => '$dayNameShort $monthName $day, $year';

  /// Formats time as '05:00 PM WAT'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24, 17, 0);
  /// final formatted = date.toTimeWithTimeZone('WAT');
  /// // returns: '05:00 PM WAT'
  /// ```
  String toTimeWithTimeZone(String timeZone) => '$toTimeAmPm $timeZone';

  /// Formats date and time as 'Fri June 12, 2026 at 05:00 PM WAT'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2026, 6, 12, 17, 0);
  /// final formatted = date.toDateAndTimeWithTimeZone('WAT');
  /// // returns: 'Fri June 12, 2026 at 05:00 PM WAT'
  /// ```
  String toDateAndTimeWithTimeZone(String timeZone) =>
      '$toDayMonthYear at ${toTimeWithTimeZone(timeZone)}';

  /// Formats date and time as 'Fri June 12, 2026 at 05:00 PM'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2026, 6, 12, 17, 0);
  /// final formatted = date.toDateAndTimeOnly;
  /// // returns: 'Fri June 12, 2026 at 05:00 PM'
  /// ```
  String get toDateAndTimeOnly => '$toDayMonthYear at $toTimeAmPm';

  /// Returns true if this date is same as the given date.
  ///
  /// Example:
  /// ```dart
  /// final date1 = DateTime(2024, 2, 24);
  /// final date2 = DateTime(2024, 2, 24);
  /// final isSame = date1.isSameAs(date2);
  /// // returns: true
  /// ```
  bool isSameAs(DateTime date) =>
      millisecondsSinceEpoch == date.millisecondsSinceEpoch;

  /// Returns true if this date is before or same as the given date.
  ///
  /// Example:
  /// ```dart
  /// final date1 = DateTime(2024, 2, 24);
  /// final date2 = DateTime(2024, 2, 25);
  /// final isBefore = date1.isBeforeOrSameAs(date2);
  /// // returns: true
  /// ```
  bool isBeforeOrSameAs(DateTime date) => difference(date).inSeconds <= 0;

  /// Returns true if this date is after or same as the given date.
  ///
  /// Example:
  /// ```dart
  /// final date1 = DateTime(2024, 2, 25);
  /// final date2 = DateTime(2024, 2, 24);
  /// final isAfter = date1.isAfterOrSameAs(date2);
  /// // returns: true
  /// ```
  bool isAfterOrSameAs(DateTime date) => difference(date).inSeconds >= 0;

  /// Returns true if this date is today.
  ///
  /// Example:
  /// ```dart
  /// final today = DateTime.now();
  /// final check = today.isToday;
  /// // returns: true
  /// ```
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns a ValueNotifier that updates the relative
  /// time string periodically.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime.now();
  /// final notifier = date.timeAgoNotifier;
  /// // returns: ValueNotifier('just now')
  /// ```
  ValueNotifier<String> get timeAgoNotifier {
    final key = millisecondsSinceEpoch.toString();

    // get cached notifier if available
    final cachedNotifier = _timeAgoNotifiers[key];
    if (cachedNotifier != null) return cachedNotifier;

    // compute ago time
    String _compute() {
      final d = DateTime.now().difference(this);
      if (d.inSeconds <= 0) return 'just now';

      final weeks = d.inDays ~/ 7;
      final days = d.inDays;
      final hours = d.inHours;
      final minutes = d.inMinutes;
      final seconds = d.inSeconds;

      if (weeks > 0) return '${weeks}w ago';
      if (days > 0) return '${days}d ago';
      if (hours > 0) return '${hours}h ago';
      if (minutes > 0) return '${minutes}m ago';

      return '${seconds}s ago';
    }

    // create notifier
    final notifier = ValueNotifier(_compute());

    final isRecent = DateTime.now().difference(this).inSeconds < 3600;

    // cache notifier and run timer if this date is less than 1 hour old
    if (kIsWeb && isRecent) {
      _timeAgoNotifiers[key] = notifier;

      Timer.periodic(const Duration(seconds: 1), (timer) {
        // if this date is now more than 1 hour old, cancel timer
        // and remove notifier from memory cache
        if (DateTime.now().difference(this).inHours >= 1) {
          timer.cancel();
          _timeAgoNotifiers.remove(key);
          return;
        }

        // update notifier value
        notifier.value = _compute();
      });
    }

    return notifier;
  }

  /// Formats date as '2 hours to go' or '2 days to go'
  /// or '2 minutes overdue' etc.
  ///
  /// - If `dueDate` is in the future, it returns the time
  ///   remaining until the `dueDate`.
  /// - If `dueDate` is in the past, it returns the time
  ///   since the `dueDate`.
  /// - If `dueDate` is not provided, it uses this date.
  ///
  /// Example:
  /// ```dart
  /// final futureDate = DateTime.now().add(const Duration(hours: 2));
  /// final text = futureDate.timeRemaining();
  /// // returns: '2 hours from now'
  /// ```
  String timeRemaining({
    String beforeDueDate = 'from now',
    String afterDueDate = 'overdue',
    DateTime? targetDate,
  }) {
    // get the difference between dates
    final d = (targetDate ?? this).difference(DateTime.now());

    final weeks = d.inDays ~/ 7;
    final days = d.inDays;
    final hrs = d.inHours;
    final mins = d.inMinutes;
    final secs = d.inSeconds;

    final absWeeks = weeks.abs();
    final absDays = days.abs();
    final absHrs = hrs.abs();
    final absMins = mins.abs();
    final absSecs = secs.abs();

    String value;

    // ////////////////////////////////////
    // Time is not due yet
    // ////////////////////////////////////
    if (weeks > 0) {
      value = '$weeks week${weeks > 1 ? 's' : ''} $beforeDueDate';
    } else if (days > 0) {
      value = '$days day${days > 1 ? 's' : ''} $beforeDueDate';
    } else if (hrs > 0) {
      value = '$hrs hour${hrs > 1 ? 's' : ''} $beforeDueDate';
    } else if (mins > 0) {
      value = '$mins minute${mins > 1 ? 's' : ''} $beforeDueDate';
    } else if (secs > 0) {
      value = '$secs second${secs > 1 ? 's' : ''} $beforeDueDate';
    }
    // ////////////////////////////////////
    // Time is overdue
    // ////////////////////////////////////
    else if (weeks < 0) {
      value = '$absWeeks week${absWeeks > 1 ? 's' : ''} $afterDueDate';
    } else if (days < 0) {
      value = '$absDays day${absDays > 1 ? 's' : ''} $afterDueDate';
    } else if (hrs < 0) {
      value = '$absHrs hour${absHrs > 1 ? 's' : ''} $afterDueDate';
    } else if (mins < 0) {
      value = '$absMins minute${absMins > 1 ? 's' : ''} $afterDueDate';
    } else {
      value = '$absSecs second${absSecs > 1 ? 's' : ''} $afterDueDate';
    }

    return value.trim();
  }
}
