import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/app_motion.dart';
import '../../core/widgets/auth_backdrop.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../authenticated_landing_screen.dart';
import 'verify_otp_screen.dart';

/// Frame `Sign up.png`:
///   heading   @ y 191, subtitle @ y 223
///   4 fields  353 x 40 at y 327 / 379 / 431 / 483  (52px pitch)
///   button    353 x 40 @ y 595
///   footer    @ y 650
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _joinAsRestaurantOwner = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
      isRestaurantOwner: _joinAsRestaurantOwner,
    );
    if (!mounted) return;

    if (success) {
      if (_joinAsRestaurantOwner) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AuthenticatedLandingScreen()),
          (route) => false,
        );
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyOtpScreen(email: _emailController.text.trim()),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Registrierung fehlgeschlagen.',
          ),
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
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 191.h - AppSizes.topInset),
                Text(
                  'Melden Sie sich an',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading(),
                ).fadeSlideUp(),

                SizedBox(height: 11.h),
                Text(
                  'Erstellen Sie Ihr Konto und entdecken Sie die besten\nSpezialitäten Ihrer Stadt.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(
                    size: AppFontSizes.authBody,
                    height: 1.45,
                  ),
                ).fadeSlideUp(delay: Motion.step(1)),

                SizedBox(height: 73.h),
                CustomTextField(
                  controller: _nameController,
                  hintText: 'Benutzername',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Bitte Namen eingeben'
                      : null,
                ).fadeSlideUp(delay: Motion.step(2)),

                SizedBox(height: 12.h),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'E-Mail',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Bitte E-Mail eingeben'
                      : null,
                ).fadeSlideUp(delay: Motion.step(3)),

                SizedBox(height: 12.h),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Neues Passwort',
                  isPassword: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Bitte Passwort eingeben';
                    }
                    if (v.length < 6) {
                      return 'Mindestens 6 Zeichen erforderlich';
                    }
                    return null;
                  },
                ).fadeSlideUp(delay: Motion.step(4)),

                SizedBox(height: 12.h),
                CustomTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Passwort bestätigen',
                  isPassword: true,
                  validator: (v) => v != _passwordController.text
                      ? 'Passwörter stimmen nicht überein'
                      : null,
                ).fadeSlideUp(delay: Motion.step(5)),

                SizedBox(height: 20.h),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(
                    () => _joinAsRestaurantOwner = !_joinAsRestaurantOwner,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 18.w,
                        height: 18.w,
                        margin: EdgeInsets.only(top: 1.h),
                        decoration: BoxDecoration(
                          color: _joinAsRestaurantOwner
                              ? AppColors.primary
                              : Colors.white,
                          borderRadius: BorderRadius.circular(4.w),
                          border: Border.all(
                            color: _joinAsRestaurantOwner
                                ? AppColors.primary
                                : AppColors.inputBorder,
                            width: 1.2,
                          ),
                        ),
                        child: _joinAsRestaurantOwner
                            ? Icon(Icons.check, size: 13.w, color: Colors.white)
                            : null,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Als Restaurantbesitzer registrieren',
                              style: AppTextStyles.label(
                                size: AppFontSizes.labelSmall,
                                color: AppColors.textDark,
                                weight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Die Freigabe durch einen Administrator ist erforderlich.',
                              style: AppTextStyles.body(
                                size: AppFontSizes.caption,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).fadeSlideUp(delay: Motion.step(6)),

                SizedBox(height: 28.h),
                CustomButton(
                  text: 'Melden Sie sich an',
                  isLoading: authProvider.isLoading,
                  onPressed: _handleSignUp,
                ).fadeSlideUp(delay: Motion.step(7)),

                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sie haben bereits ein Konto? ',
                      style: AppTextStyles.body(size: AppFontSizes.labelSmall),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'anmelden',
                        style: AppTextStyles.label(
                          size: AppFontSizes.labelSmall,
                          color: AppColors.primary,
                          weight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ).fadeSlideUp(delay: Motion.step(8)),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
