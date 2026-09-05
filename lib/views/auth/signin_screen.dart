import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/app_brand_logo.dart';
import '../../core/widgets/app_motion.dart';
import '../../core/widgets/auth_backdrop.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../authenticated_landing_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

/// Frame `Sign in (1).png`. Measured stack, top to bottom:
///   logo    153 x 89  @ y 146   (centred)
///   heading           @ y 271
///   subtitle 2 lines  @ y 300
///   e-mail   353 x 40 @ y 398
///   password 353 x 40 @ y 450
///   remember row      @ y 504
///   button   353 x 40 @ y 591
///   footer            @ y 646
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthenticatedLandingScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Anmeldung fehlgeschlagen.',
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
                SizedBox(height: 146.h - AppSizes.topInset),
                Center(child: const AppBrandLogo(width: 153).popIn(from: 0.9)),

                SizedBox(height: 37.h),
                Text(
                  'Willkommen bei Signature Dish',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading(),
                ).fadeSlideUp(delay: Motion.step(1)),

                SizedBox(height: 9.h),
                Text(
                  'Melden Sie sich an, um weiterhin unvergessliche Spezialitäten\nin Ihrer Nähe zu entdecken.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body(size: 12.6, height: 1.2),
                ).fadeSlideUp(delay: Motion.step(2)),

                SizedBox(height: 74.h),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'E-Mail',
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? 'Bitte geben Sie Ihre E-Mail ein'
                      : null,
                ).fadeSlideUp(delay: Motion.step(3)),

                SizedBox(height: 12.h),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Passwort',
                  isPassword: true,
                  validator: (val) => (val == null || val.isEmpty)
                      ? 'Bitte geben Sie Ihr Passwort ein'
                      : null,
                ).fadeSlideUp(delay: Motion.step(4)),

                SizedBox(height: 15.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _rememberMe = !_rememberMe),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 14.w,
                            height: 14.w,
                            decoration: BoxDecoration(
                              color: _rememberMe
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(3.w),
                              border: Border.all(
                                color: _rememberMe
                                    ? AppColors.primary
                                    : AppColors.textLightGrey,
                                width: 1.2,
                              ),
                            ),
                            child: _rememberMe
                                ? Icon(
                                    Icons.check,
                                    size: 10.w,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Erinnere dich an mich',
                            style: AppTextStyles.body(size: 13),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      ),
                      child: Text(
                        'Passwort vergessen?',
                        style: AppTextStyles.label(
                          size: 13,
                          color: AppColors.primary,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ).fadeSlideUp(delay: Motion.step(5)),

                SizedBox(height: 74.h),
                CustomButton(
                  text: 'anmelden',
                  isLoading: authProvider.isLoading,
                  onPressed: _handleLogin,
                ).fadeSlideUp(delay: Motion.step(6)),

                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sie haben noch kein Konto? ',
                      style: AppTextStyles.body(size: 13),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      ),
                      child: Text(
                        'Melden Sie sich an',
                        style: AppTextStyles.label(
                          size: 13,
                          color: AppColors.primary,
                          weight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ).fadeSlideUp(delay: Motion.step(7)),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
