import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_sizes.dart';
import 'core/theme/app_theme.dart';
import 'core/network/api_client.dart';
import 'core/widgets/app_refresh_boundary.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/deal_repository.dart';
import 'data/repositories/review_repository.dart';
import 'data/repositories/check_in_repository.dart';
import 'data/repositories/owner_restaurant_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/deal_provider.dart';
import 'providers/category_provider.dart';
import 'providers/review_provider.dart';
import 'providers/check_in_provider.dart';
import 'providers/saved_provider.dart';
import 'providers/owner_restaurant_provider.dart';
import 'providers/app_language_provider.dart';
import 'providers/location_provider.dart';
import 'views/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Core Services & Repositories
  final apiClient = ApiClient();
  final authRepository = AuthRepository(apiClient: apiClient);
  final dealRepository = DealRepository(apiClient: apiClient);
  final reviewRepository = ReviewRepository(apiClient: apiClient);
  final checkInRepository = CheckInRepository(apiClient: apiClient);
  final ownerRestaurantRepository = OwnerRestaurantRepository(
    apiClient: apiClient,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppLanguageProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => DealProvider(dealRepository: dealRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(dealRepository: dealRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ReviewProvider(reviewRepository: reviewRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => CheckInProvider(repository: checkInRepository),
        ),
        ChangeNotifierProxyProvider<AuthProvider, SavedProvider>(
          create: (_) => SavedProvider(dealRepository: dealRepository),
          update: (_, auth, saved) => saved!..bindUser(auth.currentUser?.id),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              OwnerRestaurantProvider(repository: ownerRestaurantRepository),
        ),
      ],
      child: const SignatureDishApp(),
    ),
  );
}

class SignatureDishApp extends StatelessWidget {
  const SignatureDishApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<AppLanguageProvider?>();
    return MaterialApp(
      title: 'Signature Dish',
      debugShowCheckedModeBanner: false,
      locale: languageProvider?.locale ?? const Locale('de'),
      supportedLocales: const [Locale('de')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light,
      // One place to keep the 393 x 852 design mapping in sync with the window.
      builder: (context, child) {
        AppSizes.init(context);
        return AppRefreshBoundary(
          child: MediaQuery.withNoTextScaling(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}
