import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/check_in_provider.dart';
import '../../providers/deal_provider.dart';
import '../../providers/owner_restaurant_provider.dart';
import '../../providers/saved_provider.dart';
import '../constants/app_colors.dart';

/// Enables pull-to-refresh on every vertically scrollable app page.
class AppRefreshBoundary extends StatefulWidget {
  final Widget child;

  const AppRefreshBoundary({super.key, required this.child});

  @override
  State<AppRefreshBoundary> createState() => _AppRefreshBoundaryState();
}

class _AppRefreshBoundaryState extends State<AppRefreshBoundary> {
  Future<void>? _activeRefresh;

  Future<void> _refresh() {
    final active = _activeRefresh;
    if (active != null) return active;

    final refresh = _refreshData();
    _activeRefresh = refresh;
    refresh.whenComplete(() {
      if (mounted) _activeRefresh = null;
    });
    return refresh;
  }

  Future<void> _refreshData() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      return;
    }

    final refreshes = <Future<void>>[
      authProvider.refreshCurrentUser().then((_) {}),
    ];

    if (authProvider.currentUser?.isRestaurantOwner == true) {
      refreshes.add(context.read<OwnerRestaurantProvider>().refreshOwnerData());
    } else {
      refreshes.addAll([
        context.read<DealProvider>().fetchDeals(),
        context.read<CategoryProvider>().fetchCategories(),
        context.read<SavedProvider>().loadSavedDeals(),
        context.read<CheckInProvider>().fetchMyCheckIns(),
      ]);
    }

    await Future.wait(refreshes);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      color: AppColors.primary,
      onRefresh: _refresh,
      child: ScrollConfiguration(
        behavior: const _AlwaysRefreshScrollBehavior(),
        child: widget.child,
      ),
    );
  }
}

class _AlwaysRefreshScrollBehavior extends MaterialScrollBehavior {
  const _AlwaysRefreshScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics());
  }
}
