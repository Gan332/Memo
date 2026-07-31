import '../l10n/app_localizations.dart';

String formatRelativeDate(DateTime date, AppLocalizations l10n) {
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inMinutes < 1) return l10n.justNow();
  if (diff.inHours < 1) return l10n.minutesAgo(diff.inMinutes);
  if (diff.inDays < 1) return l10n.hoursAgo(diff.inHours);
  if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);

  return '${date.month}/${date.day}';
}

String formatRelativeDateFromIso(String isoDate, AppLocalizations l10n) {
  return formatRelativeDate(DateTime.parse(isoDate), l10n);
}
