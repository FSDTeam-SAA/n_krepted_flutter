import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../home/home_screen.dart';
import '../map_explore/explore_map_screen.dart';
import '../saved_bookmarks/saved_dishes_screen.dart';
import '../profile/profile_screen.dart';

class MainBottomNav extends StatefulWidget {
  final int initialIndex;

  const MainBottomNav({super.key, this.initialIndex = 0});

  @override
  State<MainBottomNav> createState() => _MainBottomNavState();
}

class _MainBottomNavState extends State<MainBottomNav> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreMapScreen(),
    SavedDishesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      // IndexedStack so each tab keeps its scroll position — a cross-fade here
      // would rebuild the subtree and throw that away, so the motion lives in
      // the nav item instead.
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
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
                label: 'Heim',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.map_outlined,
                activeIcon: Icons.map,
                label: 'Karte',
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.favorite_border,
                activeIcon: Icons.favorite,
                label: 'Gespeichert',
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profil',
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
        setState(() => _currentIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 18 : 10, vertical: 6),
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
              builder: (context, value, child) => Transform.scale(scale: value, child: child),
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
                fontSize: 11,
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
