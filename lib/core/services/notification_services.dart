String formatTimeAgo(DateTime dateTime) {
  final Duration diff = DateTime.now().difference(dateTime);

  if (diff.inDays >= 1) {
    return '${diff.inDays}d ago';
  } else if (diff.inHours >= 1) {
    return '${diff.inHours}h ago';
  } else if (diff.inMinutes >= 1) {
    return '${diff.inMinutes}m ago';
  } else {
    return 'Just now';
  }
}
