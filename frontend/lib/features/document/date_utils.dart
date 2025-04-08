import 'package:intl/intl.dart';

String formatVietnamDateFromString(String rawDate) {
  try {
    final utc = DateTime.parse(rawDate).toUtc();
    final vn = utc.add(const Duration(hours: 7));
    return DateFormat('dd/MM/yyyy HH:mm', 'vi_VN').format(vn);
  } catch (e) {
    return rawDate;
  }
}
