import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:n_krepted_flutter/core/network/api_client.dart';
import 'package:n_krepted_flutter/data/models/deal_model.dart';
import 'package:n_krepted_flutter/data/models/review_model.dart';
import 'package:n_krepted_flutter/data/repositories/auth_repository.dart';
import 'package:n_krepted_flutter/data/repositories/owner_restaurant_repository.dart';
import 'package:n_krepted_flutter/data/repositories/review_repository.dart';
import 'package:n_krepted_flutter/providers/app_language_provider.dart';
import 'package:n_krepted_flutter/providers/auth_provider.dart';
import 'package:n_krepted_flutter/providers/owner_restaurant_provider.dart';
import 'package:n_krepted_flutter/providers/review_provider.dart';
import 'package:n_krepted_flutter/views/restaurant_owner/owner_dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'owner dashboard shows an existing active dish without a signature flag',
    (tester) async {
      SharedPreferences.setMockInitialValues({'nk_language': 'en'});
      final restaurant = DealModel(
        id: 'restaurant-1',
        title: 'Test Restaurant',
        description: 'Restaurant description',
        price: 20,
        location: DealLocation(address: 'Test address'),
        images: const [],
        approvalStatus: 'approved',
        dishes: const [
          DealDish(
            id: 'dish-1',
            name: 'Existing Steak',
            description: 'An existing account dish',
            price: 18,
            image: '',
            category: 'Main',
            isSignatureDish: false,
            isActive: true,
          ),
        ],
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppLanguageProvider()),
            ChangeNotifierProvider(
              create: (_) => AuthProvider(
                authRepository: AuthRepository(apiClient: ApiClient()),
              ),
            ),
            ChangeNotifierProvider(
              create: (_) => OwnerRestaurantProvider(
                repository: _DashboardOwnerRepository(restaurant),
              ),
            ),
            ChangeNotifierProvider(
              create: (_) =>
                  ReviewProvider(reviewRepository: _EmptyReviewRepository()),
            ),
          ],
          child: const MaterialApp(home: OwnerDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, -450),
      );
      await tester.pumpAndSettle();

      expect(find.text('Existing Steak'), findsOneWidget);
      expect(find.text('No signature dish has been added yet.'), findsNothing);
      expect(find.text('No dishes have been added yet.'), findsNothing);
    },
  );
}

class _DashboardOwnerRepository extends OwnerRestaurantRepository {
  final DealModel restaurant;

  _DashboardOwnerRepository(this.restaurant) : super(apiClient: ApiClient());

  @override
  Future<DealModel?> getMyRestaurant() async => restaurant;

  @override
  Future<OwnerDashboardStats> getDashboardStats() async =>
      const OwnerDashboardStats();
}

class _EmptyReviewRepository extends ReviewRepository {
  _EmptyReviewRepository() : super(apiClient: ApiClient());

  @override
  Future<List<ReviewModel>> getReviewsByDeal(String dealId) async => const [];
}
