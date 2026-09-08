import 'package:flutter/widgets.dart';

String formatEuro(BuildContext context, num amount) {
  return formatEuroForLocale(Localizations.localeOf(context), amount);
}

String formatEuroForLocale(Locale locale, num amount) {
  final isGerman = locale.languageCode == 'de';
  final value = amount.toStringAsFixed(2);
  return isGerman ? '${value.replaceAll('.', ',')} €' : '€$value';
}
