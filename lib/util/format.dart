/// Formats like the Kotlin `SimpleDateFormat("dd MMM yyyy, HH:mm")`,
/// e.g. "13 Sep 2026, 07:55". Done by hand to avoid pulling in `intl`.
String formatTimestamp(int millisSinceEpoch) {
  const months = [
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
  ];
  final d = DateTime.fromMillisecondsSinceEpoch(millisSinceEpoch);
  final day = d.day.toString().padLeft(2, '0');
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '$day ${months[d.month - 1]} ${d.year}, $hh:$mm';
}
