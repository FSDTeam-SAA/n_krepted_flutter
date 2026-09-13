import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_text_styles.dart';

/// Design: 353 x 40 pill-ish field, 10px radius, 1px #6CD5E7 border,
/// 14px hint in #B1B1B1, 13px left padding.
class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final bool isPassword;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus != _focused) {
        setState(() => _focused = _focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.w),
    borderSide: BorderSide(color: color, width: width),
  );

  @override
  Widget build(BuildContext context) {
    final isSingleLine = widget.maxLines == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: AppTextStyles.label(size: AppFontSizes.labelSmall),
          ),
          SizedBox(height: 6.h),
        ],
        // A hair of lift on focus — enough to notice, not enough to distract.
        AnimatedScale(
          scale: _focused ? 1.01 : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.isPassword ? _obscureText : false,
            keyboardType: widget.keyboardType,
            readOnly: widget.readOnly,
            onTap: widget.onTap,
            validator: widget.validator,
            maxLines: widget.maxLines,
            cursorColor: AppColors.primary,
            style: AppTextStyles.body(
              size: AppFontSizes.body,
              color: AppColors.textDark,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: widget.hintText,
              hintStyle: AppTextStyles.body(
                size: AppFontSizes.body,
                color: AppColors.textLightGrey,
              ),
              filled: true,
              fillColor: AppColors.inputFill,
              prefixIcon: widget.prefixIcon,
              // A plain tappable icon, not IconButton — IconButton enforces a
              // 48px minimum that would push the field past the design's 40.
              suffixIcon: widget.isPassword
                  ? GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _obscureText = !_obscureText),
                      child: Icon(
                        _obscureText
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18.w,
                        color: AppColors.textLightGrey,
                      ),
                    )
                  : widget.suffixIcon,
              suffixIconConstraints: BoxConstraints(
                minWidth: 36.w,
                minHeight: 20.h,
              ),
              // Vertical padding, not a height constraint: the decorator centres
              // the text between these and lands on exactly 40.
              contentPadding: EdgeInsets.symmetric(
                horizontal: 13.w,
                vertical: isSingleLine ? 11.h : 12.h,
              ),
              border: _border(AppColors.inputBorder, 1),
              enabledBorder: _border(AppColors.inputBorder, 1),
              focusedBorder: _border(AppColors.primary, 1.4),
              errorBorder: _border(AppColors.badgeRed, 1),
              focusedErrorBorder: _border(AppColors.badgeRed, 1.4),
              errorStyle: AppTextStyles.body(
                size: AppFontSizes.captionSmall,
                color: AppColors.badgeRed,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
