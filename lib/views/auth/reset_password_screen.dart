import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/app_motion.dart';
import '../../core/widgets/auth_backdrop.dart';
import '../../core/widgets/auth_back_button.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import 'signin_screen.dart';

/// Frame `Change password (2).png`:
///   heading  @ y 258, subtitle @ y 290
///   fields   353 x 40 at y 394 / 446
///   button   353 x 40 @ y 558
class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String? code;

  const ResetPasswordScreen({super.key, required this.email, this.code});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resetPassword(
      widget.email,
      _passwordController.text.trim(),
      token: widget.code,
    );
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwort erfolgreich geändert! Bitte melden Sie sich an.'),
          backgroundColor: AppColors.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Fehler beim Zurücksetzen des Passworts.'),
          backgroundColor: AppColors.badgeRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AppSizes.init(context);
    final authProvider = context.watch<AuthProvider>();

    return AuthBackdrop(
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            const AuthBackButton(),
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 258.h - AppSizes.topInset),
                    Text(
                      'Kennwort ändern',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading(),
                    ).fadeSlideUp(),

                    SizedBox(height: 11.h),
                    Text(
                      'Ihr neues Passwort sollte leicht zu merken und schwer zu\nerraten sein.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(size: 12.6, height: 1.45),
                    ).fadeSlideUp(delay: Motion.step(1)),

                    SizedBox(height: 72.h),
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Neues Passwort',
                      isPassword: true,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Bitte Passwort eingeben';
                        if (v.length < 6) return 'Mindestens 6 Zeichen erforderlich';
                        return null;
                      },
                    ).fadeSlideUp(delay: Motion.step(2)),

                    SizedBox(height: 12.h),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Passwort bestätigen',
                      isPassword: true,
                      validator: (v) =>
                          v != _passwordController.text ? 'Passwörter stimmen nicht überein' : null,
                    ).fadeSlideUp(delay: Motion.step(3)),

                    SizedBox(height: 72.h),
                    CustomButton(
                      text: 'Speichern',
                      isLoading: authProvider.isLoading,
                      onPressed: _handleReset,
                    ).fadeSlideUp(delay: Motion.step(4)),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
