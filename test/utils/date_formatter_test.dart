import 'package:flutter_test/flutter_test.dart';
import 'package:memo_app/utils/date_formatter.dart';

void main() {
  group('formatRelativeDate', () {
    test('returns 刚刚 for less than 1 minute', () {
      final now = DateTime.now();
      expect(formatRelativeDate(now), '刚刚');
    });

    test('returns X 分钟前 for less than 1 hour', () {
      final now = DateTime.now();
      final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));
      expect(formatRelativeDate(fiveMinutesAgo), '5 分钟前');
    });

    test('returns X 小时前 for less than 1 day', () {
      final now = DateTime.now();
      final threeHoursAgo = now.subtract(const Duration(hours: 3));
      expect(formatRelativeDate(threeHoursAgo), '3 小时前');
    });

    test('returns X 天前 for less than 7 days', () {
      final now = DateTime.now();
      final threeDaysAgo = now.subtract(const Duration(days: 3));
      expect(formatRelativeDate(threeDaysAgo), '3 天前');
    });

    test('returns month/day for 7 or more days', () {
      final now = DateTime.now();
      final tenDaysAgo = now.subtract(const Duration(days: 10));
      expect(formatRelativeDate(tenDaysAgo), '${tenDaysAgo.month}/${tenDaysAgo.day}');
    });
  });

  group('formatRelativeDateFromIso', () {
    test('parses ISO string and returns relative date', () {
      final now = DateTime.now();
      final iso = now.toIso8601String();
      expect(formatRelativeDateFromIso(iso), '刚刚');
    });
  });
}
