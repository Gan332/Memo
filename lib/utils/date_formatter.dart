String formatRelativeDate(DateTime date) {
  final now = DateTime.now();
  final diff = now.difference(date);

  if (diff.inMinutes < 1) return '刚刚';
  if (diff.inHours < 1) return '${diff.inMinutes} 分钟前';
  if (diff.inDays < 1) return '${diff.inHours} 小时前';
  if (diff.inDays < 7) return '${diff.inDays} 天前';

  return '${date.month}/${date.day}';
}

String formatRelativeDateFromIso(String isoDate) {
  return formatRelativeDate(DateTime.parse(isoDate));
}
