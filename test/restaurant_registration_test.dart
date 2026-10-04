import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:n_krepted_flutter/core/services/restaurant_draft_store.dart';
import 'package:n_krepted_flutter/core/network/api_client.dart';
import 'package:n_krepted_flutter/data/repositories/auth_repository.dart';
import 'package:n_krepted_flutter/data/repositories/owner_restaurant_repository.dart';
import 'package:n_krepted_flutter/providers/auth_provider.dart';
import 'package:n_krepted_flutter/providers/owner_restaurant_provider.dart';
import 'package:n_krepted_flutter/views/restaurant_owner/create_edit_restaurant_screen.dart';

class _Documents extends PathProviderPlatform {
  final String path;
  _Documents(this.path);
  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory folder;
  late PathProviderPlatform original;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    folder = await Directory.systemTemp.createTemp(
      'restaurant_registration_test',
    );
    original = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _Documents(folder.path);
  });
  tearDown(() async {
    PathProviderPlatform.instance = original;
    await folder.delete(recursive: true);
  });

  test(
    'draft retains dish photos after the picker cache is deleted and isolates owners',
    () async {
      final selected = File('${folder.path}/picked.png');
      await selected.writeAsBytes([1, 2, 3]);
      await RestaurantDraftStore.save('owner-1', {
        'title': 'Unfinished Restaurant',
        'imageFiles': [XFile(selected.path)],
        'newPhotoCategories': ['interior'],
        'signatureDishes': [
          {
            'name': 'Pasta',
            'description': 'Fresh pasta',
            'price': 12,
            'imageFiles': [XFile(selected.path)],
          },
        ],
      });
      await selected.delete();
      final restored = await RestaurantDraftStore.load('owner-1');
      expect(restored?['title'], 'Unfinished Restaurant');
      expect(restored?['newPhotoCategories'], ['interior']);
      final photos = (restored?['imageFiles'] as List).cast<XFile>();
      expect(await photos.single.readAsBytes(), [1, 2, 3]);
      final dish = (restored?['signatureDishes'] as List).single as Map;
      expect(dish['description'], 'Fresh pasta');
      expect(await (dish['imageFiles'] as List<XFile>).single.readAsBytes(), [
        1,
        2,
        3,
      ]);
      expect(await RestaurantDraftStore.load('owner-2'), isNull);
      await RestaurantDraftStore.clear('owner-1');
      expect(await RestaurantDraftStore.load('owner-1'), isNull);
    },
  );

  testWidgets(
    'registration shows categorized uploads and dishes without a fake GPS value or Startpreis',
    (tester) async {
      tester.view.physicalSize = const Size(320, 760);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final auth = AuthProvider(
        authRepository: AuthRepository(apiClient: ApiClient()),
      );
      await auth.initialization;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: auth),
            ChangeNotifierProvider(
              create: (_) => OwnerRestaurantProvider(
                repository: OwnerRestaurantRepository(apiClient: ApiClient()),
              ),
            ),
          ],
          child: const MaterialApp(
            home: CreateEditRestaurantScreen(isInitialSetup: true),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Innenbereich'), findsOneWidget);
      expect(find.text('Außenbereich'), findsOneWidget);
      expect(find.text('Startpreis (€)'), findsNothing);
      expect(find.text('48.137154'), findsNothing);
      expect(find.text('Breitengrad (Lat)'), findsNothing);
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -1100),
      );
      await tester.pumpAndSettle();
      expect(find.text('Signature-Gericht hinzufügen'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      auth.dispose();
    },
  );
}
