import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:n_krepted_flutter/core/constants/app_sizes.dart';
import 'package:n_krepted_flutter/core/network/api_client.dart';
import 'package:n_krepted_flutter/core/theme/app_theme.dart';
import 'package:n_krepted_flutter/core/widgets/bottom_action_bar.dart';
import 'package:n_krepted_flutter/core/widgets/custom_button.dart';
import 'package:n_krepted_flutter/core/widgets/feature_content.dart';
import 'package:n_krepted_flutter/data/models/deal_model.dart';
import 'package:n_krepted_flutter/data/repositories/auth_repository.dart';
import 'package:n_krepted_flutter/data/repositories/check_in_repository.dart';
import 'package:n_krepted_flutter/data/repositories/deal_repository.dart';
import 'package:n_krepted_flutter/data/repositories/owner_restaurant_repository.dart';
import 'package:n_krepted_flutter/data/repositories/review_repository.dart';
import 'package:n_krepted_flutter/providers/app_language_provider.dart';
import 'package:n_krepted_flutter/providers/auth_provider.dart';
import 'package:n_krepted_flutter/providers/category_provider.dart';
import 'package:n_krepted_flutter/providers/check_in_provider.dart';
import 'package:n_krepted_flutter/providers/deal_provider.dart';
import 'package:n_krepted_flutter/providers/location_provider.dart';
import 'package:n_krepted_flutter/providers/owner_restaurant_provider.dart';
import 'package:n_krepted_flutter/providers/review_provider.dart';
import 'package:n_krepted_flutter/providers/saved_provider.dart';
import 'package:n_krepted_flutter/views/auth/forgot_password_screen.dart';
import 'package:n_krepted_flutter/views/auth/reset_password_screen.dart';
import 'package:n_krepted_flutter/views/auth/signin_screen.dart';
import 'package:n_krepted_flutter/views/auth/signup_screen.dart';
import 'package:n_krepted_flutter/views/auth/verify_otp_screen.dart';
import 'package:n_krepted_flutter/views/booking_checkin/checkin_screen.dart';
import 'package:n_krepted_flutter/views/dish_details/dish_details_screen.dart';
import 'package:n_krepted_flutter/views/home/categories_screen.dart';
import 'package:n_krepted_flutter/views/home/filter_modal.dart';
import 'package:n_krepted_flutter/views/home/home_screen.dart';
import 'package:n_krepted_flutter/views/home/search_screen.dart';
import 'package:n_krepted_flutter/views/main_navigation/main_bottom_nav.dart';
import 'package:n_krepted_flutter/views/map_explore/explore_map_screen.dart';
import 'package:n_krepted_flutter/views/profile/change_password_screen.dart';
import 'package:n_krepted_flutter/views/profile/edit_profile_screen.dart';
import 'package:n_krepted_flutter/views/profile/my_check_ins_screen.dart';
import 'package:n_krepted_flutter/views/profile/profile_screen.dart';
import 'package:n_krepted_flutter/views/profile/privacy_policy_screen.dart';
import 'package:n_krepted_flutter/views/profile/app_info_screen.dart';
import 'package:n_krepted_flutter/views/profile/user_profile_screen.dart';
import 'package:n_krepted_flutter/views/restaurant_details/restaurant_details_screen.dart';
import 'package:n_krepted_flutter/views/restaurant_owner/create_edit_restaurant_screen.dart';
import 'package:n_krepted_flutter/views/restaurant_owner/dish_form_sheet.dart';
import 'package:n_krepted_flutter/views/restaurant_owner/owner_activity_screen.dart';
import 'package:n_krepted_flutter/views/restaurant_owner/owner_dashboard_screen.dart';
import 'package:n_krepted_flutter/views/restaurant_owner/owner_dishes_screen.dart';
import 'package:n_krepted_flutter/views/restaurant_owner/owner_ratings_screen.dart';
import 'package:n_krepted_flutter/views/restaurant_owner/owner_workspace_screen.dart';
import 'package:n_krepted_flutter/views/reviews/all_reviews_screen.dart';
import 'package:n_krepted_flutter/views/reviews/write_review_screen.dart';
import 'package:n_krepted_flutter/views/saved_bookmarks/saved_dishes_screen.dart';

final _restaurantJson = <String, dynamic>{
  '_id': 'restaurant',
  'title': 'Restaurant mit einem besonders langen Namen',
  'approvalStatus': 'approved',
  'description': '<p>Frisch zubereitete Spezialitäten aus unserer Küche.</p>',
  'location': {'city': 'Berlin', 'address': 'Eine besonders lange Straße 123'},
  'images': <String>[],
  'dishes': [
    {
      '_id': 'dish',
      'name': 'Signature-Gericht mit einem besonders langen Namen',
      'price': 12345.5,
      'rating': 4.5,
      'reviewCount': 999999,
      'description':
          '<p>Eine ausführliche Beschreibung mit mehreren Zeilen.</p>',
      'specialtyDescription': 'Die Spezialität unseres Hauses.',
      'ingredients': ['Frische Zutaten', 'Besonders lang benannte Zutat'],
      'preparationProcess': 'Frisch gekocht und mit Sorgfalt serviert.',
      'category': 'Hauptgerichte',
      'tags': ['Vegetarisch', 'Frisch zubereitet'],
      'isSignatureDish': true,
    },
  ],
};
final _restaurant = DealModel.fromJson(_restaurantJson);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'Signature Dish',
      packageName: 'test.signature.dish',
      version: '1.0.0',
      buildNumber: '7',
      buildSignature: '',
    );
  });

  final pages = <String, Widget Function()>{
    'home': () => const HomeScreen(),
    'search': () => const SearchScreen(),
    'categories': () => const CategoriesScreen(),
    'filters': () => const FilterModal(),
    'map': () => const ExploreMapScreen(active: false),
    'saved': () => const SavedDishesScreen(),
    'navigation': () => const MainBottomNav(),
    'dish details': () =>
        DishDetailsScreen(deal: _restaurant, dish: _restaurant.dishes.first),
    'restaurant details': () => RestaurantDetailsScreen(deal: _restaurant),
    'reviews': () => const AllReviewsScreen(dealId: 'restaurant'),
    'review form': () => const WriteReviewScreen(dealId: 'restaurant'),
    'check-in': () => CheckinScreen(deal: _restaurant),
    'profile': () => const ProfileScreen(),
    'app info': () => const AppInfoScreen(),
    'user profile': () => const UserProfileScreen(),
    'edit profile': () => const EditProfileScreen(),
    'change password': () => const ChangePasswordScreen(),
    'check-in history': () => const MyCheckInsScreen(),
    'owner dashboard': () => const OwnerDashboardScreen(),
    'owner workspace': () => const OwnerWorkspaceScreen(),
    'owner dishes': () => const OwnerDishesScreen(),
    'owner signatures': () => const OwnerDishesScreen(signaturesOnly: true),
    'owner ratings': () => const OwnerRatingsScreen(restaurantId: 'restaurant'),
    'owner activity': () =>
        const OwnerActivityScreen(type: OwnerActivityType.checkIns),
    'restaurant form': () =>
        CreateEditRestaurantScreen(restaurant: _restaurant),
    'dish form': () =>
        Scaffold(body: DishFormSheet(dish: _restaurant.dishes.first)),
    'sign in': () => const SignInScreen(),
    'sign up': () => const SignUpScreen(),
    'forgot password': () => const ForgotPasswordScreen(),
    'reset password': () =>
        const ResetPasswordScreen(email: 'guest@example.test'),
    'verification': () => const VerifyOtpScreen(email: 'guest@example.test'),
  };

  for (final width in [320.0, 393.0]) {
    for (final page in pages.entries) {
      testWidgets('${page.key} fits a $width px phone and scrolls safely', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 720);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final reportError = FlutterError.onError;
        FlutterError.onError = (details) {
          debugPrint(details.toString());
          reportError?.call(details);
        };
        addTearDown(() => FlutterError.onError = reportError);

        await tester.pumpWidget(_app(page.value()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Visit lower sections as well, where forms, galleries and cards differ.
        final scrolls = find.byWidgetPredicate(
          (widget) => widget is Scrollable && widget.axis == Axis.vertical,
        );
        if (scrolls.evaluate().isNotEmpty) {
          for (var i = 0; i < 3; i++) {
            await tester.drag(scrolls.first, const Offset(0, -450));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
        }
        await tester.pumpWidget(const SizedBox.shrink());
      });
    }
  }

  testWidgets('filter sheet keeps Apply visible and only commits on Apply', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      _app(const Scaffold(body: DiscoveryFilterButton())),
    );
    await tester.pumpAndSettle();
    final deals = tester
        .element(find.byType(DiscoveryFilterButton))
        .read<DealProvider>();

    await tester.tap(find.byType(DiscoveryFilterButton));
    await tester.pumpAndSettle();
    expect(find.byType(FilterModal), findsOneWidget);
    final apply = find.byKey(const ValueKey('apply-discovery-filters'));
    final applyBounds = tester.getRect(apply);
    expect(applyBounds.height, lessThan(80));
    expect(
      tester
          .getSize(
            find
                .descendant(
                  of: find.byType(FilterModal),
                  matching: find.byType(ListView),
                )
                .first,
          )
          .height,
      greaterThan(250),
    );
    await tester.ensureVisible(find.byKey(const ValueKey('filter-open-now')));
    await tester.tap(find.byKey(const ValueKey('filter-open-now')));
    await tester.pumpAndSettle();
    expect(deals.openNow, isFalse);
    expect(tester.getRect(apply), applyBounds);
    await tester.tap(find.byTooltip('Filter schließen'));
    await tester.pumpAndSettle();
    expect(deals.openNow, isFalse);
    expect(deals.activeFilterCount, 0);

    await tester.tap(find.byType(DiscoveryFilterButton));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('filter-open-now')));
    await tester.tap(find.byKey(const ValueKey('filter-open-now')));
    await tester.pumpAndSettle();
    await tester.tap(apply);
    await tester.pumpAndSettle();
    expect(find.byType(FilterModal), findsNothing);
    expect(deals.openNow, isTrue);
    expect(find.text('Filter · 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filter reset stays local until the user applies it', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const Scaffold(body: DiscoveryFilterButton())),
    );
    await tester.pumpAndSettle();
    final deals = tester
        .element(find.byType(DiscoveryFilterButton))
        .read<DealProvider>();
    deals.openNow = true;
    deals.priceRange = r'$$';
    deals.tags = ['Vegetarisch'];
    await deals.applyFilters(
      location: 'Berlin',
      radiusKm: 15,
      minimumRating: 4,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DiscoveryFilterButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zurücksetzen'));
    await tester.pumpAndSettle();
    expect(deals.minimumRating, 4);
    expect(deals.priceRange, r'$$');
    expect(deals.locationQuery, 'Berlin');
    await tester.tap(find.byKey(const ValueKey('apply-discovery-filters')));
    await tester.pumpAndSettle();
    expect(deals.activeFilterCount, 0);
    expect(deals.tags, isEmpty);
    expect(deals.locationQuery, isEmpty);
    expect(deals.radiusKm, 10);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'unavailable GPS leaves city filtering available without a snackbar',
    (tester) async {
      final location = _UnavailableLocation();
      await tester.pumpWidget(
        _app(const Scaffold(body: DiscoveryFilterButton()), location: location),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DiscoveryFilterButton));
      await tester.pumpAndSettle();
      expect(location.requests, 0);
      await tester.tap(find.byKey(const ValueKey('filter-nearby-mode')));
      await tester.pumpAndSettle();
      expect(location.requests, 0);
      expect(find.byType(Slider), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('apply-discovery-filters')));
      await tester.pumpAndSettle();
      expect(location.requests, 1);
      expect(find.text('Standort nicht verfügbar'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      expect(find.byType(FilterModal), findsOneWidget);

      await tester.ensureVisible(find.text('Stadt auswählen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Stadt auswählen'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('filter-city')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Berlin').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('apply-discovery-filters')));
      await tester.pumpAndSettle();
      final deals = tester
          .element(find.byType(DiscoveryFilterButton))
          .read<DealProvider>();
      expect(deals.locationQuery, 'Berlin');
      expect(deals.latitude, isNull);
      expect(location.requests, 1);
      expect(find.byType(FilterModal), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'About is reachable from both profiles and shows the installed version',
    (tester) async {
      for (final page in [const UserProfileScreen(), const ProfileScreen()]) {
        await tester.pumpWidget(_app(page));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('Über Signature Dish'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Über Signature Dish'));
        await tester.pumpAndSettle();
        expect(find.byType(AppInfoScreen), findsOneWidget);
        expect(find.text('Version 1.0.0 · Build 7'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Datenschutzerklärung'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Datenschutzerklärung'));
        await tester.pumpAndSettle();
        expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    },
  );

  testWidgets(
    'small phone auth fields remain reachable with the keyboard open',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);

      await tester.pumpWidget(_app(const SignInScreen()));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(CustomButton));
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(CustomButton)).height,
        greaterThanOrEqualTo(48),
      );
      expect(
        tester.getRect(find.byType(CustomButton)).bottom,
        lessThanOrEqualTo(360),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'dish badge wraps its label and bottom action clears the system inset',
    (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 24);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);

      await tester.pumpWidget(
        _app(
          DishDetailsScreen(deal: _restaurant, dish: _restaurant.dishes.first),
        ),
      );
      await tester.pumpAndSettle();
      final badgeContainer = find
          .descendant(
            of: find.byType(SignatureBadge),
            matching: find.byType(Container),
          )
          .first;
      expect(tester.getSize(badgeContainer).width, lessThan(353));
      expect(
        tester.getSize(badgeContainer).width,
        closeTo(tester.getSize(find.text('★ Signature Dish')).width + 20, 2),
      );
      final button = find.descendant(
        of: find.byType(BottomActionBar),
        matching: find.byType(OutlinedButton),
      );
      expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
      expect(tester.getRect(button).bottom, lessThanOrEqualTo(852 - 24 - 12));
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _app(Widget page, {LocationProvider? location}) {
  final api = _LayoutApi();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AppLanguageProvider()),
      ChangeNotifierProvider(
        create: (_) => AuthProvider(authRepository: _LayoutAuth(api)),
      ),
      ChangeNotifierProvider(
        create: (_) =>
            DealProvider(dealRepository: DealRepository(apiClient: api)),
      ),
      ChangeNotifierProvider(
        create: (_) =>
            CategoryProvider(dealRepository: DealRepository(apiClient: api)),
      ),
      ChangeNotifierProvider(
        create: (_) =>
            ReviewProvider(reviewRepository: ReviewRepository(apiClient: api)),
      ),
      ChangeNotifierProvider(
        create: (_) =>
            CheckInProvider(repository: CheckInRepository(apiClient: api)),
      ),
      ChangeNotifierProvider(
        create: (_) =>
            SavedProvider(dealRepository: DealRepository(apiClient: api)),
      ),
      ChangeNotifierProvider(create: (_) => location ?? LocationProvider()),
      ChangeNotifierProvider(
        create: (_) => OwnerRestaurantProvider(
          repository: OwnerRestaurantRepository(apiClient: api),
        )..fetchMyRestaurant(),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      builder: (context, child) {
        AppSizes.init(context);
        return child!;
      },
      home: page,
    ),
  );
}

class _LayoutAuth extends AuthRepository {
  _LayoutAuth(ApiClient api) : super(apiClient: api);
  @override
  Future<void> warmUpRegistration() async {}
}

class _UnavailableLocation extends LocationProvider {
  int requests = 0;
  @override
  Future<bool> locate() async {
    requests++;
    errorMessage = 'Bitte erlaube den Standortzugriff.';
    return false;
  }
}

class _LayoutApi extends ApiClient {
  @override
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final Object data;
    if (path == '/deals') {
      data = {
        'deals': [_restaurantJson],
      };
    } else if (path.startsWith('/deals/')) {
      data = {'deal': _restaurantJson};
    } else if (path == '/owner/restaurant') {
      data = {'restaurant': _restaurantJson};
    } else if (path == '/discovery/options') {
      data = {
        'cities': ['Berlin'],
        'cuisines': ['Deutsch'],
        'tags': ['Vegetarisch'],
      };
    } else if (path.startsWith('/reviews/eligibility/')) {
      data = {
        'eligible': true,
        'checkIn': {
          '_id': 'visit',
          'checkedInAt': '2026-06-04T19:30:00Z',
          'partySize': 4,
          'restaurantId': {'dishes': _restaurantJson['dishes']},
        },
      };
    } else {
      data = {'data': [], 'reviews': [], 'items': []};
    }
    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 200,
      data: data,
    );
  }

  @override
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async => Response(
    requestOptions: RequestOptions(path: path),
    statusCode: 200,
    data: {'success': true},
  );
}
