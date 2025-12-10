import 'package:intl/intl.dart';

class DateFormatter {
  static String hour(DateTime dt) => DateFormat.Hm().format(dt);
  static String dayMonth(DateTime dt) => DateFormat('d/M').format(dt);
  static String weekday(DateTime dt) => DateFormat.E().format(dt);
}
