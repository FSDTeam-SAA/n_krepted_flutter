import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:n_krepted_flutter/core/network/api_client.dart';
import 'package:n_krepted_flutter/core/widgets/restaurant_card.dart';
import 'package:n_krepted_flutter/core/widgets/photo_gallery.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:n_krepted_flutter/views/saved_bookmarks/saved_dishes_screen.dart';
import 'package:n_krepted_flutter/data/models/deal_model.dart';
import 'package:n_krepted_flutter/data/repositories/deal_repository.dart';
import 'package:n_krepted_flutter/data/repositories/review_repository.dart';
import 'package:n_krepted_flutter/data/repositories/auth_repository.dart';
import 'package:n_krepted_flutter/providers/deal_provider.dart';
import 'package:n_krepted_flutter/providers/review_provider.dart';
import 'package:n_krepted_flutter/providers/saved_provider.dart';
import 'package:n_krepted_flutter/providers/auth_provider.dart';
import 'package:n_krepted_flutter/providers/location_provider.dart';
import 'package:n_krepted_flutter/providers/app_language_provider.dart';
import 'package:n_krepted_flutter/providers/owner_restaurant_provider.dart';
import 'package:n_krepted_flutter/data/repositories/owner_restaurant_repository.dart';
import 'package:n_krepted_flutter/views/authenticated_landing_screen.dart';
import 'package:n_krepted_flutter/views/main_navigation/main_bottom_nav.dart';
import 'package:n_krepted_flutter/views/home/home_screen.dart';
import 'package:n_krepted_flutter/views/map_explore/explore_map_screen.dart';
import 'package:n_krepted_flutter/views/reviews/write_review_screen.dart';
import 'package:n_krepted_flutter/views/reviews/all_reviews_screen.dart';
import 'package:n_krepted_flutter/views/dish_details/dish_details_screen.dart';

// Fixtures live only in tests. Production screens use the API repositories.
Map<String, dynamic> restaurantJson(String id) => {
  '_id': id,
  'title': 'Restaurant with a long name - preserved',
  'description': 'Description',
  'price': 0,
  'location': {'city': 'Berlin'},
  'images': [],
  'rating': 4,
  'reviewCount': 2,
  'dishes': [
    {
      '_id': 'dish-a',
      'name': 'A dish with a very long descriptive name',
      'price': 12.5,
      'rating': 5,
      'reviewCount': 1,
      'isSignatureDish': true,
      'description': 'Freshly prepared',
      'images': [],
    },
    {
      '_id': 'dish-b',
      'name': 'Second dish',
      'price': 18,
      'rating': 3,
      'reviewCount': 1,
    },
    {
      '_id': 'inactive',
      'name': 'Inactive dish',
      'price': 10,
      'isActive': false,
    },
  ],
};
Map<String, dynamic> reviewJson(String id, String dish) => {
  '_id': id,
  'dealID': 'restaurant',
  'dishID': dish,
  'ratings': 4,
  'reviewComment': id,
  'userID': {'name': 'Guest'},
  'createdAt': '2026-06-04T19:30:00Z',
};

class _Api extends ApiClient {
  late Future<Response> Function(String, Map<String, dynamic>?) onGet;
  final List<String> writes = [];
  bool rejectWrites = false;
  @override
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) =>
      onGet(path, queryParameters);
  @override
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    writes.add('$path:${data['dishId']}');
    if (rejectWrites) throw Exception('Offline');
    return response({'success': true});
  }
}

Response response(Object data) =>
    Response(requestOptions: RequestOptions(), statusCode: 200, data: data);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('a stale Saved GET cannot erase a completed database save; new session reads server items', () async {
    final stale = Completer<Response>();
    final api = _Api()..onGet = (_, _) => stale.future;
    final repository = DealRepository(apiClient: api);
    final saved = SavedProvider(dealRepository: repository)..bindUser('user');
    await Future<void>.delayed(Duration.zero);
    final restaurant = DealModel.fromJson(restaurantJson('restaurant'));
    expect(await saved.toggleSave(restaurant), isTrue);
    stale.complete(response({'items': []}));
    await Future<void>.delayed(Duration.zero);
    expect(saved.isSaved('restaurant'), isTrue);
    api.onGet = (_, _) async => response({'items': [{'restaurant': restaurantJson('restaurant'), 'dishId': ''}]});
    saved.dispose();
    final reopened = SavedProvider(dealRepository: repository)..bindUser('user');
    await Future<void>.delayed(Duration.zero);
    expect(reopened.isSaved('restaurant'), isTrue);
    reopened.dispose();
  });
  testWidgets('gallery back icon stays white, zoom controls work, reset allows paging', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(appBarTheme: const AppBarTheme(iconTheme: IconThemeData(color: Colors.black))),
      home: Builder(builder: (context) => Scaffold(body: TextButton(onPressed: () => openPhotoGallery(context, ['', '']), child: const Text('Gallery')))),
    ));
    await tester.tap(find.text('Gallery'));
    await tester.pumpAndSettle();
    expect(IconTheme.of(tester.element(find.byType(BackButton))).color, Colors.white);
    await tester.tap(find.byTooltip('Vergrößern'));
    await tester.pump();
    final viewer = tester.widget<InteractiveViewer>(find.byType(InteractiveViewer).first);
    expect(viewer.transformationController!.value.getMaxScaleOnAxis(), 2);
    expect(tester.widget<PageView>(find.byType(PageView)).physics, isA<NeverScrollableScrollPhysics>());
    await tester.tap(find.byTooltip('Zoom zurücksetzen'));
    await tester.pump();
    expect(viewer.transformationController!.value.getMaxScaleOnAxis(), 1);
    await tester.drag(find.byType(PageView), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('2 / 2'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Gallery'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('selected map pin fits; zoom controls and pan move the real map camera', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final data = restaurantJson('map-restaurant')..['location'] = {'latitude': 23.77, 'longitude': 90.4};
    final queries = <Map<String, dynamic>>[];
    final api = _Api()..onGet = (path, query) async {
      if (path == '/discovery/options') return response({'cuisines': ['Deutsch', 'Italienisch']});
      queries.add(query!);
      return response({'deals': [data]});
    };
    await tester.pumpWidget(_app(api, ExploreMapScreen(initialRestaurant: DealModel.fromJson(data))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    final controller = tester.widget<FlutterMap>(find.byType(FlutterMap)).mapController!;
    final initialZoom = controller.camera.zoom;
    await tester.tap(find.byTooltip('Vergrößern'));
    await tester.pump();
    expect(controller.camera.zoom, initialZoom + 1);
    await tester.tap(find.byTooltip('Verkleinern'));
    await tester.pump();
    expect(controller.camera.zoom, initialZoom);
    final initialCenter = controller.camera.center;
    await tester.dragFrom(const Offset(120, 330), const Offset(80, 50));
    await tester.pump(const Duration(milliseconds: 500));
    expect(controller.camera.center, isNot(initialCenter));
    expect(find.text('Am besten bewertet'), findsOneWidget);
    await tester.tap(find.text('Am günstigsten'));
    await tester.pump();
    expect(queries.last['sort'], 'priceAsc');
    await tester.tap(find.text('Deutsch'));
    await tester.pump();
    expect(queries.last['cuisine'], 'Deutsch');
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('Saved renders API entries with actual image URLs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final data = restaurantJson('saved-restaurant')
      ..['images'] = ['https://example.test/photo.jpg'];
    (data['dishes'] as List).first['images'] = [
      'https://example.test/dish.jpg',
    ];
    final api = _Api()
      ..onGet = (_, _) async => response({
        'items': [
          {'restaurant': data, 'dishId': ''},
        ],
      });
    final saved = SavedProvider(dealRepository: DealRepository(apiClient: api))
      ..bindUser('user');
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: saved),
          ChangeNotifierProvider(create: (_) => LocationProvider()),
        ],
        child: const MaterialApp(home: SavedDishesScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text(data['title']), findsOneWidget);
    expect(
      tester.getSize(find.byType(RestaurantCard)).height,
      greaterThan(100),
    );
    expect(tester.getSize(find.byType(RestaurantCard)).height, lessThan(350));
    expect(find.text(data['title']).hitTestable(), findsOneWidget);
  });
  testWidgets(
    'role user lands on customer Home without owner setup or eager GPS requests',
    (tester) async {
      final user = {
        '_id': 'user',
        'name': 'Guest',
        'email': 'guest@example.test',
        'role': 'user',
        'isVerified': true,
      };
      SharedPreferences.setMockInitialValues({
        'nk_user': jsonEncode(user),
        'nk_token': 'test-session',
      });
      final api = _Api()
        ..onGet = (_, _) async => response({'success': true, 'data': user});
      await tester.pumpWidget(
        _app(
          api,
          ChangeNotifierProvider(
            create: (_) => OwnerRestaurantProvider(
              repository: OwnerRestaurantRepository(apiClient: api),
            ),
            child: const AuthenticatedLandingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MainBottomNav), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(ExploreMapScreen), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  test(
    'missing locations are unknown, active dishes retain database identity and ratings',
    () {
      final restaurant = DealModel.fromJson(restaurantJson('restaurant'));
      expect(DealLocation.fromJson(null).label, isEmpty);
      expect(
        DealLocation.fromJson({'latitude': 95, 'longitude': 0}).hasCoordinates,
        isFalse,
      );
      expect(
        DealLocation.fromJson({
          'latitude': '0',
          'longitude': '0',
        }).hasCoordinates,
        isTrue,
      );
      expect(
        restaurant.restaurantName,
        'Restaurant with a long name - preserved',
      );
      expect(restaurant.activeDishes, hasLength(2));
      expect(restaurant.featuredDish!.id, 'dish-a');
      expect(restaurant.featuredDish!.rating, 5);
    },
  );
  test(
    'late search response cannot replace newer search and filters survive refresh',
    () async {
      final api = _Api();
      final first = Completer<Response>(), second = Completer<Response>();
      final queries = <Map<String, dynamic>>[];
      api.onGet = (_, query) {
        queries.add(query!);
        return queries.length == 1 ? first.future : second.future;
      };
      final provider = DealProvider(
        dealRepository: DealRepository(apiClient: api),
        autoLoad: false,
      );
      final old = provider.fetchDeals(search: 'old');
      final recent = provider.fetchDeals(
        search: 'new',
        location: 'Berlin',
        latitude: 52,
        longitude: 13,
      );
      second.complete(
        response({
          'deals': [restaurantJson('new')],
        }),
      );
      await recent;
      first.complete(
        response({
          'deals': [restaurantJson('old')],
        }),
      );
      await old;
      expect(provider.deals.single.id, 'new');
      expect(queries.last['title'], 'new');
      expect(queries.last['location'], 'Berlin');
      api.onGet = (_, query) async {
        queries.add(query!);
        return response({'deals': []});
      };
      await provider.fetchDeals();
      expect(queries.last['latitude'], 52);
      expect(queries.last['location'], 'Berlin');
      provider.dispose();
    },
  );
  test(
    'saved dishes use API, failed save stays unsaved and account switch discards old data',
    () async {
      final api = _Api()..onGet = (_, _) async => response({'items': []});
      final saved = SavedProvider(
        dealRepository: DealRepository(apiClient: api),
      );
      saved.bindUser('first');
      await Future<void>.delayed(Duration.zero);
      final restaurant = DealModel.fromJson(restaurantJson('restaurant'));
      expect(await saved.toggleSave(restaurant, dishId: 'dish-a'), isTrue);
      expect(api.writes.single, '/saved/restaurant:dish-a');
      expect(saved.isSaved('restaurant', dishId: 'dish-a'), isTrue);
      expect(saved.isSaved('restaurant'), isFalse);
      api.rejectWrites = true;
      expect(await saved.toggleSave(restaurant, dishId: 'dish-b'), isFalse);
      expect(saved.isSaved('restaurant', dishId: 'dish-b'), isFalse);
      saved.bindUser('second');
      expect(saved.entries, isEmpty);
      await Future<void>.delayed(Duration.zero);
      saved.dispose();
    },
  );
  test(
    'review requests retain separate restaurant results and expose failures',
    () async {
      final api = _Api();
      api.onGet = (path, _) async => response({
        'reviews': [reviewJson(path, 'dish-a')],
      });
      final reviews = ReviewProvider(
        reviewRepository: ReviewRepository(apiClient: api),
      );
      await reviews.fetchReviewsForDeal('one');
      await reviews.fetchReviewsForDeal('two');
      expect(reviews.reviewsForDeal('one').single.id, contains('one'));
      expect(reviews.reviewsForDeal('two').single.id, contains('two'));
      api.onGet = (_, _) => Future.error(Exception('Offline'));
      await reviews.fetchReviewsForDeal('three');
      expect(reviews.reviewsForDeal('three'), isEmpty);
      expect(reviews.errorFor('three'), isNotNull);
    },
  );
  for (final width in [320.0, 393.0]) {
    testWidgets(
      'reference restaurant card fits $width px including long names',
      (tester) async {
        tester.view.physicalSize = Size(width, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final api = _Api()..onGet = (_, _) async => response({'items': []});
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => SavedProvider(
                  dealRepository: DealRepository(apiClient: api),
                ),
              ),
              ChangeNotifierProvider(create: (_) => LocationProvider()),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    RestaurantCard(
                      deal: DealModel.fromJson(restaurantJson('restaurant')),
                    ),
                    RestaurantCard(
                      deal: DealModel.fromJson(restaurantJson('restaurant')),
                      compact: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'dish details and all reviews display only the selected database dish',
    (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = _Api()
        ..onGet = (path, _) async => path.startsWith('/deals/')
            ? response({'deal': restaurantJson('restaurant')})
            : response({
                'reviews': [
                  reviewJson('first review', 'dish-a'),
                  reviewJson('second review', 'dish-b'),
                ],
              });
      await tester.pumpWidget(
        _app(
          api,
          DishDetailsScreen(
            deal: DealModel.fromJson(restaurantJson('restaurant')),
            dish: DealDish.fromJson(
              (restaurantJson('restaurant')['dishes'] as List)[0],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('A dish with a very long descriptive name'),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(find.text('Alle anzeigen'), 350);
      await tester.tap(find.text('Alle anzeigen'));
      await tester.pumpAndSettle();
      expect(find.byType(AllReviewsScreen), findsOneWidget);
      expect(find.text('first review'), findsOneWidget);
      expect(find.text('second review'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'review form starts unrated and uses verified visit with selected dish',
    (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = _Api()
        ..onGet = (_, _) async => response({
          'eligible': true,
          'checkIn': {
            '_id': 'visit',
            'checkedInAt': '2026-06-04T19:30:00Z',
            'partySize': 4,
            'restaurantId': {'dishes': restaurantJson('restaurant')['dishes']},
          },
        });
      await tester.pumpWidget(
        _app(
          api,
          const WriteReviewScreen(dealId: 'restaurant', dishId: 'dish-a'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.star_border), findsNWidgets(5));
      expect(find.text('4 Personen'), findsOneWidget);
      expect(
        find.text('A dish with a very long descriptive name'),
        findsWidgets,
      );
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _app(_Api api, Widget home) => MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) =>
          AuthProvider(authRepository: AuthRepository(apiClient: api)),
    ),
    ChangeNotifierProvider(create: (_) => AppLanguageProvider()),
    ChangeNotifierProvider(
      create: (_) => DealProvider(
        dealRepository: DealRepository(apiClient: api),
        autoLoad: false,
      ),
    ),
    ChangeNotifierProvider(
      create: (_) =>
          ReviewProvider(reviewRepository: ReviewRepository(apiClient: api)),
    ),
    ChangeNotifierProvider(
      create: (_) =>
          SavedProvider(dealRepository: DealRepository(apiClient: api)),
    ),
    ChangeNotifierProvider(create: (_) => LocationProvider()),
  ],
  child: MaterialApp(home: home),
);
