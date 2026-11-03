import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n_krepted_flutter/core/widgets/app_dropdown.dart';

void main() {
  testWidgets('phone filters fit and open their menu below the field', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var radius = 25;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Karte')),
          body: StatefulBuilder(
            builder: (context, setState) => Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: AppDropdown<String>(
                      value: 'rating',
                      decoration: const InputDecoration(
                        labelText: 'Sortierung',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'rating',
                          child: Text('Am besten bewertet, höchste zuerst'),
                        ),
                      ],
                      onChanged: (_) {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppDropdown<int>(
                      value: radius,
                      decoration: const InputDecoration(labelText: 'Umkreis'),
                      items: [
                        for (final value in [1, 5, 10, 25, 50])
                          DropdownMenuItem(
                            value: value,
                            child: Text('$value km'),
                          ),
                      ],
                      onChanged: (value) => setState(() => radius = value!),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final field = find.byType(AppDropdown<int>);
    final fieldBounds = tester.getRect(field);
    expect(tester.takeException(), isNull);
    await tester.tap(field);
    await tester.pumpAndSettle();

    final firstOption = tester.getRect(find.byType(PopupMenuItem<int>).first);
    final lastOption = tester.getRect(find.byType(PopupMenuItem<int>).last);
    expect(firstOption.top, greaterThanOrEqualTo(fieldBounds.bottom));
    expect(firstOption.left, greaterThanOrEqualTo(0));
    expect(firstOption.right, lessThanOrEqualTo(320));
    expect(lastOption.bottom, lessThanOrEqualTo(640));
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.tap(find.text('50 km'));
    await tester.pumpAndSettle();
    expect(radius, 50);
    expect(find.text('50 km'), findsOneWidget);
    expect(find.byType(PopupMenuItem<int>), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('selection preserves form validation and external resets', (
    tester,
  ) async {
    final form = GlobalKey<FormState>();
    String? selection;
    late StateSetter rebuild;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: form,
            child: StatefulBuilder(
              builder: (context, setState) {
                rebuild = setState;
                return AppDropdown<String>(
                  value: selection,
                  hint: const Text('Gericht auswählen'),
                  items: const [
                    DropdownMenuItem(value: 'dish', child: Text('House dish')),
                  ],
                  validator: (value) => value == null ? 'Bitte wählen' : null,
                  onChanged: (value) => setState(() => selection = value),
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(form.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Bitte wählen'), findsOneWidget);

    await tester.tap(find.byType(AppDropdown<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('House dish'));
    await tester.pumpAndSettle();
    expect(selection, 'dish');
    expect(form.currentState!.validate(), isTrue);
    await tester.pump();
    expect(find.text('Bitte wählen'), findsNothing);

    rebuild(() => selection = null);
    await tester.pump();
    expect(find.text('Gericht auswählen'), findsOneWidget);
    expect(form.currentState!.validate(), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long option lists scroll and keep disabled options inactive', (
    tester,
  ) async {
    int? selection;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppDropdown<int>(
            value: 0,
            items: [
              for (var i = 0; i < 40; i++)
                DropdownMenuItem(
                  value: i,
                  enabled: i != 1,
                  child: Text('Küche $i'),
                ),
            ],
            onChanged: (value) => selection = value,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(AppDropdown<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Küche 1'));
    await tester.pumpAndSettle();
    expect(selection, isNull);
    expect(find.byType(PopupMenuItem<int>), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Küche 39'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Küche 39'));
    await tester.pumpAndSettle();
    expect(selection, 39);
    expect(tester.takeException(), isNull);
  });
}
