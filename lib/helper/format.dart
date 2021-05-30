import 'package:intl/intl.dart';

String numericFormat(int number) {
	final format = NumberFormat("#,###", "vi_VN");
	return format.format(number);
}

String doubleFormat(double number) {
	final format = NumberFormat("#,###.#", "vi_VN");
	format.minimumFractionDigits = 0;
	format.maximumFractionDigits = 3;
	return format.format(number);
}

DateTime dateFromString(String value, {String format = 'dd/MM/yyyy HH:mm:ss'}) {
	try {
		return DateFormat(format).parse(value);
	} catch (e) {
		return null;
	}
}

String stringFromDate(DateTime value, {String format = 'HH:mm:ss dd/MM/yyyy'}) {
	try {
		return DateFormat(format).format(value);
	} catch (e) {
		return '';
	}
}