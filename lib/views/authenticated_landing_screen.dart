import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/owner_restaurant_provider.dart';
import 'auth/signin_screen.dart';
import 'main_navigation/main_bottom_nav.dart';
import 'restaurant_owner/create_edit_restaurant_screen.dart';
import 'restaurant_owner/owner_dashboard_screen.dart';
import 'restaurant_owner/owner_workspace_screen.dart';

/// Resolves the correct first page after login and after an app/browser reload.
class AuthenticatedLandingScreen extends StatefulWidget {
  const AuthenticatedLandingScreen({super.key});

  @override
  State<AuthenticatedLandingScreen> createState() =>
      _AuthenticatedLandingScreenState();
}

class _AuthenticatedLandingScreenState
    extends State<AuthenticatedLandingScreen> {
  bool _isResolvingOwner = true;
  bool _ownerLoadFailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveOwner());
  }

  Future<void> _resolveOwner() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isInitialized) await auth.initialization;
    if (!mounted) return;

    if (auth.currentUser?.isRestaurantOwner != true) {
      setState(() => _isResolvingOwner = false);
      return;
    }

    final ownerProvider = context.read<OwnerRestaurantProvider>();
    ownerProvider.clear();
    final success = await ownerProvider.fetchMyRestaurant();
    if (!mounted) return;
    setState(() {
      _isResolvingOwner = false;
      _ownerLoadFailed = !success;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final owner = context.watch<OwnerRestaurantProvider>();

    if (!auth.isInitialized || _isResolvingOwner) {
      return const _LandingLoader();
    }
    if (!auth.isAuthenticated) return const SignInScreen();
    if (auth.currentUser?.isRestaurantOwner != true) {
      return const MainBottomNav();
    }
    if (_ownerLoadFailed) {
      return _OwnerLoadError(
        message: owner.errorMessage,
        onRetry: () {
          setState(() {
            _isResolvingOwner = true;
            _ownerLoadFailed = false;
          });
          _resolveOwner();
        },
      );
    }

    final restaurant = owner.restaurant;
    if (restaurant == null) {
      return const CreateEditRestaurantScreen(isInitialSetup: true);
    }
    if (restaurant.isApproved) return const OwnerDashboardScreen();
    return const OwnerWorkspaceScreen();
  }
}

class _LandingLoader extends StatelessWidget {
  const _LandingLoader();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}

class _OwnerLoadError extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const _OwnerLoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 52,
                color: AppColors.textGrey,
              ),
              const SizedBox(height: 16),
              Text(
                message ?? 'Restaurantdaten konnten nicht geladen werden.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
