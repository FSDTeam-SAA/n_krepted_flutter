import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_language_provider.dart';
import '../../providers/owner_restaurant_provider.dart';
import '../auth/signin_screen.dart';
import 'edit_profile_screen.dart';
import 'user_profile_screen.dart';
import 'change_password_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';
import 'my_check_ins_screen.dart';
import '../restaurant_owner/create_edit_restaurant_screen.dart';
import '../restaurant_owner/owner_workspace_screen.dart';
import '../restaurant_details/restaurant_details_screen.dart';
import '../../core/constants/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final ownerProvider = context.watch<OwnerRestaurantProvider>();
    final language = context.watch<AppLanguageProvider>();
    final user = authProvider.currentUser;
    if (user?.role == 'user') return const UserProfileScreen();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: Navigator.canPop(context),
        title: Text(
          language.text('Profil', 'Profile'),
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: AppFontSizes.heading,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0F7FA), Color(0xFFFFF9E6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      backgroundImage: user?.avatar?.isNotEmpty == true
                          ? CachedNetworkImageProvider(user!.avatar!)
                          : null,
                      child: user?.avatar?.isNotEmpty != true
                          ? const Icon(
                              Icons.person,
                              size: 30,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  user?.name ?? '',
                                  style: const TextStyle(
                                    fontSize: AppFontSizes.titleSmall,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                              if (user?.isRestaurantOwner == true)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    language.text('Inhaber', 'Owner'),
                                    style: const TextStyle(
                                      fontSize: AppFontSizes.captionSmall,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                              fontSize: AppFontSizes.smallPlus,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Group 1: Konto
              _buildSectionBox(
                title: language.text('Konto', 'Account'),
                children: [
                  if (user?.isRestaurantOwner == true &&
                      ownerProvider.restaurant != null) ...[
                    _buildListTile(
                      icon: Icons.storefront_outlined,
                      title: language.text(
                        'Restaurantverwaltung',
                        'Restaurant management',
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OwnerWorkspaceScreen(),
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildListTile(
                      icon: Icons.preview_outlined,
                      title: language.text(
                        'Restaurantdetails ansehen',
                        'View restaurant details',
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RestaurantDetailsScreen(
                            deal: ownerProvider.restaurant!,
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildListTile(
                      icon: Icons.edit_note_outlined,
                      title: language.text(
                        'Restaurant bearbeiten',
                        'Edit restaurant',
                      ),
                      subtitle: ownerProvider.restaurant?.title,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateEditRestaurantScreen(
                            restaurant: ownerProvider.restaurant,
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                  ],
                  if (user?.role == 'user') ...[
                    _buildListTile(
                      icon: Icons.location_on_outlined,
                      title: language.text('Meine Check-ins', 'My check-ins'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyCheckInsScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                  ],
                  _buildListTile(
                    icon: Icons.person_outline,
                    title: user?.isRestaurantOwner == true
                        ? language.text(
                            'Inhaberprofil bearbeiten',
                            'Edit owner profile',
                          )
                        : language.text('Profil bearbeiten', 'Edit profile'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  _buildListTile(
                    icon: Icons.vpn_key_outlined,
                    title: language.text('Passwort ändern', 'Change password'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Group 2: Social
              if (user?.isRestaurantOwner != true) ...[
                _buildSectionBox(
                  title: language.text('Folgen Sie uns', 'Follow us'),
                  children: [
                    _buildListTile(
                      icon: Icons.camera_alt_outlined,
                      title: 'Instagram',
                      onTap: () {},
                    ),
                    const Divider(height: 1, color: AppColors.divider),
                    _buildListTile(
                      icon: Icons.music_note_outlined,
                      title: 'TikTok',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Group 3: Legal & Help
              _buildSectionBox(
                title: language.text('Hilfe & Recht', 'Help & legal'),
                children: [
                  _buildListTile(
                    icon: Icons.verified_user_outlined,
                    title: language.text(
                      'Geschäftsbedingungen',
                      'Terms and conditions',
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TermsScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  _buildListTile(
                    icon: Icons.shield_outlined,
                    title: language.text(
                      'Datenschutzerklärung',
                      'Privacy policy',
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Logout Button
              GestureDetector(
                onTap: () async {
                  await authProvider.logout();
                  ownerProvider.clear();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                    (route) => false,
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.badgeRed, width: 1.2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.logout,
                        color: AppColors.badgeRed,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        language.text('Abmelden', 'Log out'),
                        style: const TextStyle(
                          color: AppColors.badgeRed,
                          fontSize: AppFontSizes.bodyLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionBox({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 12, bottom: 4),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: AppFontSizes.small,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    String? badge,
    Color? badgeColor,
    Color? badgeBg,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textDark, size: 20),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: AppFontSizes.body,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: badgeBg ?? const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: AppFontSizes.tinyPlus,
                  fontWeight: FontWeight.bold,
                  color: badgeColor ?? const Color(0xFF065F46),
                ),
              ),
            ),
        ],
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: AppFontSizes.caption,
                color: AppColors.textGrey,
              ),
            )
          : null,
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: AppColors.textGrey,
      ),
      onTap: onTap,
    );
  }
}
