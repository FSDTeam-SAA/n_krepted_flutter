import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_sizes.dart';
import 'core/constants/app_text_styles.dart';
import 'core/network/api_client.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/deal_repository.dart';
import 'data/repositories/review_repository.dart';
import 'data/repositories/booking_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/deal_provider.dart';
import 'providers/category_provider.dart';
import 'providers/review_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/saved_provider.dart';
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
  final bookingRepository = BookingRepository(apiClient: apiClient);

  runApp(
    MultiProvider(
      providers: [
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
          create: (_) => BookingProvider(bookingRepository: bookingRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => SavedProvider(dealRepository: dealRepository),
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
    return MaterialApp(
      title: 'Signature Dish',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.background,
        ),
        fontFamily: AppTextStyles.sansFamily,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: AppColors.textDark),
        ),
        // Same soft slide on every pushed route, on both platforms.
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      // One place to keep the 393 x 852 design mapping in sync with the window.
      builder: (context, child) {
        AppSizes.init(context);
        return MediaQuery.withNoTextScaling(child: child ?? const SizedBox.shrink());
      },
      home: const SplashScreen(),
    );
  }
}
