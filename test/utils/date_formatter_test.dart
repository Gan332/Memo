import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_app/l10n/app_localizations.dart';
import 'package:memo_app/utils/date_formatter.dart';

final _l10n = AppLocalizations(const Locale('zh', 'CN'));

void main() {
  group('formatRelativeDate', () {
    test('returns justNow for less than 1 minute', () {
      final now = DateTime.now();
      expect(formatRelativeDate(now, _l10n), _l10n.justNow());
    });

    test('returns minutesAgo for less than 1 hour', () {
      final now = DateTime.now();
      final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));
      expect(formatRelativeDate(fiveMinutesAgo, _l10n),
          _l10n.minutesAgo(5));
    });

    test('returns hoursAgo for less than 1 day', () {
      final now = DateTime.now();
      final threeHoursAgo = now.subtract(const Duration(hours: 3));
      expect(formatRelativeDate(threeHoursAgo, _l10n),
          _l10n.hoursAgo(3));
    });

    test('returns daysAgo for less than 7 days', () {
      final now = DateTime.now();
      final threeDaysAgo = now.subtract(const Duration(days: 3));
      expect(formatRelativeDate(threeDaysAgo, _l10n),
          _l10n.daysAgo(3));
    });

    test('returns month/day for 7 or more days', () {
      final now = DateTime.now();
      final tenDaysAgo = now.subtract(const Duration(days: 10));
      expect(formatRelativeDate(tenDaysAgo, _l10n),
          '${tenDaysAgo.month}/${tenDaysAgo.day}');
    });
  });

  group('formatRelativeDateFromIso', () {
    test('parses ISO string and returns relative date', () {
      final now = DateTime.now();
      final iso = now.toIso8601String();
      expect(formatRelativeDateFromIso(iso, _l10n), _l10n.justNow());
    });
  });
}
