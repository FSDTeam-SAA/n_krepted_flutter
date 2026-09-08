import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n_krepted_flutter/core/utils/currency_formatter.dart';

void main() {
  test('formats euro after German amounts and before English amounts', () {
    expect(formatEuroForLocale(const Locale('de'), 18.9), '18,90 €');
    expect(formatEuroForLocale(const Locale('en'), 18.9), '€18.90');
  });
}
