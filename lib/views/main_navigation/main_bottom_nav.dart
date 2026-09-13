import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_language_provider.dart';
import '../home/home_screen.dart';
import '../map_explore/explore_map_screen.dart';
import '../saved_bookmarks/saved_dishes_screen.dart';
import '../profile/profile_screen.dart';
import '../../core/constants/app_text_styles.dart';

class MainBottomNav extends StatefulWidget {
  final int initialIndex;

  const MainBottomNav({super.key, this.initialIndex = 0});

  @override
  State<MainBottomNav> createState() => _MainBottomNavState();
}

class _MainBottomNavState extends State<MainBottomNav> {
  late int _currentIndex;

  final Set<int> _visited = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _visited.add(_currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppLanguageProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      // IndexedStack so each tab keeps its scroll position — a cross-fade here
      // would rebuild the subtree and throw that away, so the motion lives in
      // the nav item instead.
      body: IndexedStack(
        index: _currentIndex,
        children: [
          if (_visited.contains(0))
            const HomeScreen()
          else
            const SizedBox.shrink(),
          if (_visited.contains(1))
            ExploreMapScreen(active: _currentIndex == 1)
          else
            const SizedBox.shrink(),
          if (_visited.contains(2))
            SavedDishesScreen(active: _currentIndex == 2)
          else
            const SizedBox.shrink(),
          if (_visited.contains(3))
            const ProfileScreen()
          else
            const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.cardBorder, width: 1.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: language.text('Startseite', 'Home'),
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.map_outlined,
                activeIcon: Icons.map,
                label: language.text('Karte', 'Map'),
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.favorite_border,
                activeIcon: Icons.favorite,
                label: language.text('Gespeichert', 'Saved'),
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: language.text('Profil', 'Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        if (_currentIndex == index) return;
        setState(() {
          _currentIndex = index;
          _visited.add(index);
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 18 : 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          // Design uses an outline icon even when active, on a #FFFBE7 pill.
          color: isSelected ? const Color(0xFFFFFBE7) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // A small bump each time a tab becomes active.
            TweenAnimationBuilder<double>(
              key: ValueKey(isSelected),
              tween: Tween(begin: isSelected ? 0.8 : 1, end: 1),
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutBack,
              builder: (context, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textGrey,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                fontSize: AppFontSizes.captionSmall,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textGrey,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
