import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/owner_page_background.dart';
import '../../core/utils/open_external_link.dart';
import '../../data/repositories/site_content_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_language_provider.dart';
import '../auth/signin_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'terms_screen.dart';
import 'privacy_policy_screen.dart';
import 'my_check_ins_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late final Future<Map<String, String>> _social = SiteContentRepository()
      .getSocialLinks();
  void _open(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final language = context.watch<AppLanguageProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(language.text('Profil', 'Profile')),
        automaticallyImplyLeading: Navigator.canPop(context),
      ),
      body: OwnerPageBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8F8FF), Color(0xFFFFFBDC)],
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 24,
                    backgroundImage: user?.avatar?.isNotEmpty == true
                        ? CachedNetworkImageProvider(user!.avatar!)
                        : null,
                    child: user?.avatar?.isNotEmpty == true
                        ? null
                        : const Icon(Icons.person, color: AppColors.textGrey),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? '',
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                            fontSize: 11,
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
            _section(language.text('Konto', 'Account'), [
              _tile(
                Icons.manage_accounts_outlined,
                language.text('Profil bearbeiten', 'Edit profile'),
                () => _open(const EditProfileScreen()),
              ),
              _tile(
                Icons.key_outlined,
                language.text('Kennwort ändern', 'Change password'),
                () => _open(const ChangePasswordScreen()),
              ),
              _tile(
                Icons.location_on_outlined,
                language.text('Meine Check-ins', 'My check-ins'),
                () => _open(const MyCheckInsScreen()),
              ),
            ]),
            FutureBuilder<Map<String, String>>(
              future: _social,
              builder: (context, snapshot) {
                final links = snapshot.data ?? {};
                if (links.isEmpty) return const SizedBox.shrink();
                return _section(language.text('Folgen Sie uns', 'Follow us'), [
                  for (final link in links.entries)
                    _tile(
                      link.key == 'Instagram'
                          ? Icons.camera_alt_outlined
                          : Icons.music_note_outlined,
                      link.key,
                      () => openExternalLink(context, link.value),
                    ),
                ]);
              },
            ),
            _section(language.text('Hilfe & Recht', 'Help & legal'), [
              _tile(
                Icons.verified_user_outlined,
                language.text('Geschäftsbedingungen', 'Terms and conditions'),
                () => _open(const TermsScreen()),
              ),
              _tile(
                Icons.shield_outlined,
                language.text('Datenschutzrichtlinie', 'Privacy policy'),
                () => _open(const PrivacyPolicyScreen()),
              ),
            ]),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                alignment: Alignment.centerLeft,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                await auth.logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                  (_) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: Text(language.text('Abmelden', 'Log out')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFFDDDDDD)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
          ),
        ),
        ...children,
      ],
    ),
  );
  Widget _tile(IconData icon, String title, VoidCallback action) => ListTile(
    leading: Icon(icon, size: 20),
    title: Text(title, style: const TextStyle(fontSize: 14)),
    trailing: const Icon(Icons.chevron_right, size: 18),
    onTap: action,
  );
}
