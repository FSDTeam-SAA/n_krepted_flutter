import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/app_motion.dart';
import '../../core/widgets/auth_backdrop.dart';
import '../../core/widgets/auth_back_button.dart';
import '../../core/widgets/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../main_navigation/main_bottom_nav.dart';

/// Frame `OTP.png`:
///   heading  @ y 284, subtitle @ y 316
///   6-character verification code
///   button   353 x 40 @ y 532
class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({super.key, required this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _handleVerify() async {
    if (_otpCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bitte geben Sie den vollständigen 6-stelligen Code ein.',
          ),
          backgroundColor: AppColors.badgeRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyOtp(widget.email, _otpCode);
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Ungültiger Code.'),
          backgroundColor: AppColors.badgeRed,
        ),
      );
      return;
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainBottomNav()),
      (route) => false,
    );
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 284.h - AppSizes.topInset),
                  Text(
                    'Bestätigungscode prüfen',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.heading(),
                  ).fadeSlideUp(),

                  SizedBox(height: 11.h),
                  Text(
                    'Bestätigen Sie Ihr Konto, um Signature Dish weiter zu\nentdecken.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body(
                      size: AppFontSizes.authBody,
                      height: 1.45,
                    ),
                  ).fadeSlideUp(delay: Motion.step(1)),

                  SizedBox(height: 75.h),
                  Row(
                    children: List.generate(11, (itemIndex) {
                      if (itemIndex.isOdd) {
                        return SizedBox(width: 7.w);
                      }
                      final otpIndex = itemIndex ~/ 2;
                      return Expanded(
                        child: _OtpBox(
                          controller: _controllers[otpIndex],
                          focusNode: _focusNodes[otpIndex],
                          onChanged: (v) => _onDigitChanged(otpIndex, v),
                        ).fadeSlideUp(delay: Motion.step(2 + otpIndex, ms: 55)),
                      );
                    }),
                  ),

                  SizedBox(height: 69.h),
                  CustomButton(
                    text: 'Verifizieren',
                    isLoading: authProvider.isLoading,
                    onPressed: _handleVerify,
                  ).fadeSlideUp(delay: Motion.step(8)),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
            const AuthBackButton(),
          ],
        ),
      ),
    );
  }
}

/// One responsive verification-code cell, 10px radius, #6CD5E7 border.
class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      if (widget.focusNode.hasFocus != _focused) {
        setState(() => _focused = widget.focusNode.hasFocus);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _focused ? 1.05 : 1,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.w),
          border: Border.all(
            color: _focused ? AppColors.primary : AppColors.inputBorder,
            width: _focused ? 1.4 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.next,
          maxLength: 1,
          cursorColor: AppColors.primary,
          style: AppTextStyles.body(
            size: AppFontSizes.subtitle,
            color: AppColors.textDark,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
            TextInputFormatter.withFunction((oldValue, newValue) {
              return newValue.copyWith(text: newValue.text.toUpperCase());
            }),
          ],
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}
