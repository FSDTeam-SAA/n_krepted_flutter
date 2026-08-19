import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_text_styles.dart';

/// Design: 353 x 40, 10px radius, solid #0097B0, 15px white label.
class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final double fontSize;
  final Widget? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 40,
    this.borderRadius = 10,
    this.fontSize = 15,
    this.icon,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _pressed = false;

  bool get _enabled => !widget.isLoading && widget.onPressed != null;

  void _set(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ?? AppColors.primary;
    final fg = widget.textColor ?? (widget.isOutlined ? AppColors.primary : Colors.white);

    return GestureDetector(
      onTapDown: _enabled ? (_) => _set(true) : null,
      onTapUp: _enabled ? (_) => _set(false) : null,
      onTapCancel: () => _set(false),
      onTap: _enabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _enabled ? 1 : 0.55,
          duration: const Duration(milliseconds: 180),
          child: Container(
            width: widget.width == null ? double.infinity : widget.width!.w,
            height: widget.height.h,
            decoration: BoxDecoration(
              color: widget.isOutlined ? Colors.transparent : bg,
              borderRadius: BorderRadius.circular(widget.borderRadius.w),
              border: widget.isOutlined ? Border.all(color: fg, width: 1.2) : null,
            ),
            alignment: Alignment.center,
            child: widget.isLoading
                ? SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: widget.isOutlined ? AppColors.primary : Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        widget.icon!,
                        SizedBox(width: 8.w),
                      ],
                      Text(
                        widget.text,
                        style: AppTextStyles.label(
                          size: widget.fontSize,
                          color: fg,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
