import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n_krepted_flutter/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SignatureDishApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1));

    // Dispose the splash before its delayed navigation fires.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
