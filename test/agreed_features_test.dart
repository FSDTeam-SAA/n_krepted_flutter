import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n_krepted_flutter/core/utils/description_text.dart';
import 'package:n_krepted_flutter/core/widgets/feature_content.dart';
import 'package:n_krepted_flutter/data/models/deal_model.dart';
import 'package:n_krepted_flutter/views/restaurant_owner/restaurant_details_fields.dart';

DealModel restaurant(Map<String, dynamic> extra) => DealModel.fromJson({
  '_id': 'restaurant',
  'title': 'Restaurant',
  'description': '',
  'price': 10,
  ...extra,
});

void main() {
  test(
    'mobile edits decode HTML without silently discarding unchanged formatting',
    () {
      const formatted =
          '<p class="ql-align-center"><strong>Fresh &amp; warm</strong></p><p>Crème&nbsp;brûlée &#9733;</p>';
      expect(plainDescription(formatted), 'Fresh & warm\nCrème brûlée ★');
      expect(
        descriptionForSubmission(formatted, 'Fresh & warm\nCrème brûlée ★'),
        formatted,
      );
      expect(
        descriptionForSubmission(formatted, 'Changed description'),
        'Changed description',
      );
      expect(plainDescription('Price < 3 euros'), 'Price < 3 euros');
    },
  );

  test(
    'lead-photo choice refers to the same file after multipart ordering',
    () {
      const existing = ['existing-a', 'existing-b'];
      const added = ['new-a', 'new-b', 'new-c'];
      const displayed = [...added, ...existing];
      const uploaded = [...existing, ...added];
      for (var index = 0; index < displayed.length; index++) {
        final submittedIndex = leadImageSubmissionIndex(
          index,
          added.length,
          existing.length,
        );
        expect(uploaded[submittedIndex], displayed[index]);
      }
    },
  );

  test('restaurant editing retains all cuisines with legacy API fallback', () {
    final model = restaurant({
      'categories': ['Italian', 'Coffee'],
      'category': {'_id': 'Italian', 'categoryName': 'Italian'},
    });
    expect(restaurantExtraFields(model)['category'], 'Italian, Coffee');
    final legacy = restaurant({
      'category': {'_id': 'Coffee', 'categoryName': 'Coffee'},
    });
    expect(legacy.categories, ['Coffee']);
  });

  testWidgets('promotion expiry removes stale offers from an open dish page', (
    tester,
  ) async {
    final model = restaurant({
      'promotions': [
        {
          'title': 'Expired offer',
          'endsAt': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
        },
        {
          'title': 'Short offer',
          'endsAt': DateTime.now()
              .add(const Duration(seconds: 2))
              .toIso8601String(),
        },
        {'title': 'Other dish offer', 'dish': 'other-dish'},
      ],
    });
    final dish = DealDish.fromJson({
      '_id': 'dish',
      'name': 'Dish',
      'description': '',
      'price': 10,
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PromotionList(model, dish: dish)),
      ),
    );
    expect(find.text('Expired offer'), findsNothing);
    expect(find.text('Other dish offer'), findsNothing);
    expect(find.text('Short offer'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Short offer'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('owner contact and opening-hours fields fit a 320-pixel phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var data = restaurantExtraFields(null);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) => RestaurantDetailsFields(
                value: data,
                onChange: (value) => setState(() => data = value),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Restaurant-E-Mail'), findsOneWidget);
    expect(find.text('Montag'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('long custom food labels fit narrow cards', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 160,
            child: FoodTags([
              'A very long custom dietary label that must fit the card',
              'Vegan',
            ]),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
