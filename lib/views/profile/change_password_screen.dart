import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_language_provider.dart';
import '../../core/widgets/owner_page_background.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.changePassword(
      _currentPasswordController.text,
      _newPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      final language = context.read<AppLanguageProvider>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            language.text(
              'Passwort erfolgreich geändert!',
              'Password changed successfully!',
            ),
          ),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ??
                context.read<AppLanguageProvider>().text(
                  'Fehler beim Ändern des Passworts.',
                  'Failed to change password.',
                ),
          ),
          backgroundColor: AppColors.badgeRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final language = context.watch<AppLanguageProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          language.text('Kennwort ändern', 'Change password'),
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: OwnerPageBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _currentPasswordController,
                          hintText: language.text(
                            'Aktuelles Passwort',
                            'Current password',
                          ),
                          labelText: language.text(
                            'Aktuelles Passwort',
                            'Current password',
                          ),
                          isPassword: true,
                          validator: (v) => (v == null || v.isEmpty)
                              ? language.text(
                                  'Bitte aktuelles Passwort eingeben',
                                  'Enter your current password',
                                )
                              : null,
                        ),

                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _newPasswordController,
                          hintText: language.text(
                            'Neues Passwort',
                            'New password',
                          ),
                          labelText: language.text(
                            'Neues Passwort',
                            'New password',
                          ),
                          isPassword: true,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return language.text(
                                'Bitte neues Passwort eingeben',
                                'Enter a new password',
                              );
                            }
                            if (v.length < 6) {
                              return language.text(
                                'Mindestens 6 Zeichen erforderlich',
                                'At least 6 characters are required',
                              );
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _confirmPasswordController,
                          hintText: language.text(
                            'Passwort bestätigen',
                            'Confirm password',
                          ),
                          labelText: language.text(
                            'Passwort bestätigen',
                            'Confirm password',
                          ),
                          isPassword: true,
                          validator: (v) {
                            if (v != _newPasswordController.text) {
                              return language.text(
                                'Passwörter stimmen nicht überein',
                                'Passwords do not match',
                              );
                            }
                            return null;
                          },
                        ),

                        const Spacer(),
                        const SizedBox(height: 30),

                        CustomButton(
                          text: language.text('Speichern', 'Save'),
                          isLoading: authProvider.isLoading,
                          onPressed: _handleSave,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
