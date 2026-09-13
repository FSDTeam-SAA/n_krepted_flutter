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

/// Frame `Forgot Password (1).png`:
///   heading  @ y 285, subtitle @ y 316
///   e-mail   353 x 40 @ y 420
///   button   353 x 40 @ y 532
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.forgotPassword(email);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Wenn die E-Mail-Adresse registriert ist, wurde ein sicherer Link zum Zurücksetzen gesendet.',
          ),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Fehler beim Senden.'),
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
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 285.h - AppSizes.topInset),
                    Text(
                      'Passwort vergessen?',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading(),
                    ).fadeSlideUp(),

                    SizedBox(height: 10.h),
                    Text(
                      'Stellen Sie Ihr Konto sicher wieder her und setzen Sie Ihre\nkulinarische Reise fort.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(
                        size: AppFontSizes.authBody,
                        height: 1.45,
                      ),
                    ).fadeSlideUp(delay: Motion.step(1)),

                    SizedBox(height: 75.h),
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'E-Mail',
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) => (val == null || val.trim().isEmpty)
                          ? 'Bitte geben Sie Ihre E-Mail ein'
                          : null,
                    ).fadeSlideUp(delay: Motion.step(2)),

                    SizedBox(height: 72.h),
                    CustomButton(
                      text: 'Bestätigungscode senden',
                      isLoading: authProvider.isLoading,
                      onPressed: _handleSendOtp,
                    ).fadeSlideUp(delay: Motion.step(3)),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
            const AuthBackButton(),
          ],
        ),
      ),
    );
  }
}
