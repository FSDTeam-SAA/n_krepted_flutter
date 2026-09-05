import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n_krepted_flutter/main.dart';
import 'package:n_krepted_flutter/core/network/api_client.dart';
import 'package:n_krepted_flutter/data/models/deal_model.dart';
import 'package:n_krepted_flutter/data/models/review_model.dart';
import 'package:n_krepted_flutter/data/models/check_in_model.dart';
import 'package:n_krepted_flutter/data/repositories/auth_repository.dart';
import 'package:n_krepted_flutter/data/repositories/owner_restaurant_repository.dart';
import 'package:n_krepted_flutter/providers/auth_provider.dart';
import 'package:n_krepted_flutter/providers/owner_restaurant_provider.dart';
import 'package:n_krepted_flutter/views/auth/forgot_password_screen.dart';
import 'package:n_krepted_flutter/views/restaurant_owner/owner_workspace_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('dish and review models preserve real multi-image data', () {
    final dish = DealDish.fromJson({
      '_id': 'dish-1',
      'name': 'Test dish',
      'price': 14,
      'image': 'https://example.com/primary.jpg',
      'images': [
        'https://example.com/primary.jpg',
        'https://example.com/second.jpg',
      ],
      'ingredients': ['Rice', 'Fish'],
      'specialtyDescription': 'House recipe',
      'preparationProcess': 'Cook fresh',
    });
    final review = ReviewModel.fromJson({
      '_id': 'review-1',
      'userID': {'_id': 'user-1', 'name': 'Real User', 'email': 'user@test.de'},
      'dealID': 'restaurant-1',
      'dishID': 'dish-1',
      'ratings': 4,
      'reviewComment': 'Sehr gut',
    });

    expect(dish.image, 'https://example.com/primary.jpg');
    expect(dish.images, hasLength(2));
    expect(dish.ingredients, ['Rice', 'Fish']);
    expect(review.dishId, dish.id);
    expect(review.ratings, 4);
  });

  test('owner check-in keeps the real visitor identity', () {
    final checkIn = CheckInModel.fromJson({
      '_id': 'visit-1',
      'userId': {
        '_id': 'visitor-1',
        'name': 'Restaurant Guest',
        'email': 'guest@example.com',
        'avatar': 'https://example.com/avatar.jpg',
      },
      'restaurantId': 'restaurant-1',
      'checkedInAt': '2026-06-04T19:30:00.000Z',
      'partySize': 4,
      'distanceMeters': 18,
      'status': 'verified',
    });

    expect(checkIn.userId, 'visitor-1');
    expect(checkIn.user?.name, 'Restaurant Guest');
    expect(checkIn.user?.email, 'guest@example.com');
    expect(checkIn.partySize, 4);
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SignatureDishApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1));

    // Dispose the splash before its delayed navigation fires.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('forgot-password back button returns to the previous screen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(
          authRepository: AuthRepository(apiClient: ApiClient()),
        ),
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  ),
                  child: const Text('Open forgot password'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open forgot password'));
    await tester.pumpAndSettle();
    expect(find.text('Passwort vergessen?'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    expect(find.text('Open forgot password'), findsOneWidget);
    expect(find.text('Passwort vergessen?'), findsNothing);
  });

  testWidgets('pending restaurant status fits a phone viewport', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) =>
            OwnerRestaurantProvider(repository: _PendingRestaurantRepository()),
        child: const MaterialApp(home: OwnerWorkspaceScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ihre Anfrage wird geprüft'), findsOneWidget);
    expect(find.text('In Prüfung'), findsOneWidget);
    expect(find.text('Status aktualisieren'), findsOneWidget);
    expect(find.text('Sozib23'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _PendingRestaurantRepository extends OwnerRestaurantRepository {
  _PendingRestaurantRepository() : super(apiClient: ApiClient());

  @override
  Future<DealModel?> getMyRestaurant() async => DealModel(
    id: 'restaurant-1',
    title: 'Sozib23',
    description: 'Traditionelle Küche mit frischen Zutaten.',
    price: 25,
    location: DealLocation(address: '121212', city: 'Dhaka'),
    images: const [],
    approvalStatus: 'pending',
  );
}
