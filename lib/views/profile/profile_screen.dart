import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/owner_restaurant_provider.dart';
import '../restaurant_owner/owner_workspace_screen.dart';
import '../auth/signin_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final ownerProvider = context.watch<OwnerRestaurantProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profil',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              // User Profile Banner Card
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
                      backgroundImage: user?.avatar != null
                          ? CachedNetworkImageProvider(user!.avatar!)
                          : null,
                      child: user?.avatar == null
                          ? const Icon(Icons.person, size: 30, color: AppColors.primary)
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
                                  user?.name ?? 'Vicky Jams',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                              if (user?.isRestaurantOwner == true)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: AppColors.primary.withValues(alpha: 0.3)),
                                  ),
                                  child: const Text(
                                    'Owner',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user?.email ?? 'vickyjams@gmail.com',
                            style: const TextStyle(
                              fontSize: 12.5,
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

              // Restaurant Owner Workspace Access
              _buildSectionBox(
                title: 'Restaurantbesitzer',
                children: [
                  _buildListTile(
                    icon: Icons.storefront_outlined,
                    title: 'Restaurantverwaltung',
                    subtitle: ownerProvider.restaurant != null
                        ? (ownerProvider.restaurant!.isApproved
                            ? '„${ownerProvider.restaurant!.title}“ ist live'
                            : ownerProvider.restaurant!.isPending
                                ? 'Wartet auf Genehmigung'
                                : 'Abgelehnt (Überarbeiten)')
                        : 'Eigenes Restaurant erstellen & verwalten',
                    badge: ownerProvider.restaurant != null
                        ? (ownerProvider.restaurant!.isApproved
                            ? 'Genehmigt'
                            : ownerProvider.restaurant!.isPending
                                ? 'Ausstehend'
                                : 'Abgelehnt')
                        : null,
                    badgeColor: ownerProvider.restaurant != null
                        ? (ownerProvider.restaurant!.isApproved
                            ? const Color(0xFF065F46)
                            : ownerProvider.restaurant!.isPending
                                ? const Color(0xFFB45309)
                                : Colors.red.shade700)
                        : null,
                    badgeBg: ownerProvider.restaurant != null
                        ? (ownerProvider.restaurant!.isApproved
                            ? const Color(0xFFECFDF5)
                            : ownerProvider.restaurant!.isPending
                                ? const Color(0xFFFFFBE7)
                                : Colors.red.shade50)
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OwnerWorkspaceScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Group 1: Konto
              _buildSectionBox(
                title: 'Konto',
                children: [
                  _buildListTile(
                    icon: Icons.person_outline,
                    title: 'Profil bearbeiten',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, color: AppColors.divider),
                  _buildListTile(
                    icon: Icons.vpn_key_outlined,
                    title: 'Kennwort ändern',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Group 2: Social
              _buildSectionBox(
                title: 'Folgen Sie uns',
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

              // Group 3: Legal & Help
              _buildSectionBox(
                title: 'Hilfe & Recht',
                children: [
                  _buildListTile(
                    icon: Icons.verified_user_outlined,
                    title: 'Geschäftsbedingungen',
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
                    title: 'Datenschutzrichtlinie',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
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
                    children: const [
                      Icon(Icons.logout, color: AppColors.badgeRed, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Abmelden',
                        style: TextStyle(
                          color: AppColors.badgeRed,
                          fontSize: 14.5,
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
                fontSize: 12,
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
                fontSize: 14,
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
                  fontSize: 10.5,
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
              style: const TextStyle(fontSize: 11.5, color: AppColors.textGrey),
            )
          : null,
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGrey),
      onTap: onTap,
    );
  }
}
