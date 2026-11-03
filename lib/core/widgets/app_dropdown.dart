import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/app_spacing.dart';

/// Shared dropdown with an anchored menu and the same field styling everywhere.
/// Keeps form validation/reset support for review and restaurant forms.
class AppDropdown<T> extends FormField<T> {
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final InputDecoration decoration;
  final Widget? hint;

  AppDropdown({
    super.key,
    required T? value,
    required this.items,
    required this.onChanged,
    this.decoration = const InputDecoration(),
    this.hint,
    super.validator,
    super.onSaved,
    super.autovalidateMode,
  }) : super(
         initialValue: value,
         enabled: onChanged != null,
         builder: (field) => (field as _AppDropdownState<T>)._buildField(),
       );

  @override
  FormFieldState<T> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends FormFieldState<T> {
  bool _focused = false;
  bool _menuOpen = false;

  @override
  AppDropdown<T> get widget => super.widget as AppDropdown<T>;

  @override
  void didUpdateWidget(covariant AppDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      setValue(widget.initialValue);
    }
  }

  @override
  void reset() {
    super.reset();
    widget.onChanged?.call(value);
  }

  OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radius),
        borderSide: BorderSide(color: color, width: width),
      );

  Widget _buildField() {
    final enabled = widget.onChanged != null && widget.items.isNotEmpty;
    final selected = widget.items
        .where((item) => item.value == value)
        .firstOrNull;
    final textStyle = const TextStyle(
      fontFamily: AppTextStyles.sansFamily,
      fontSize: AppFontSizes.body,
      fontWeight: FontWeight.w500,
      color: AppColors.textDark,
      height: 1.4,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final fieldWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : 160.0;
        final menuWidth = math.min(
          math.max(fieldWidth, 160.0),
          screenWidth - 32,
        );
        return Focus(
          onFocusChange: (focused) => setState(() => _focused = focused),
          child: PopupMenuButton<T>(
            enabled: enabled,
            tooltip: widget.decoration.labelText ?? 'Auswählen',
            position: PopupMenuPosition.under,
            offset: const Offset(0, 6),
            constraints: BoxConstraints(
              minWidth: menuWidth,
              maxWidth: menuWidth,
              maxHeight: 320,
            ),
            color: AppColors.cardWhite,
            surfaceTintColor: Colors.transparent,
            elevation: 6,
            shadowColor: AppColors.textDark.withValues(alpha: .16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
            clipBehavior: Clip.antiAlias,
            menuPadding: const EdgeInsets.all(6),
            onOpened: () => setState(() => _menuOpen = true),
            onCanceled: () => setState(() => _menuOpen = false),
            onSelected: (selection) {
              setState(() => _menuOpen = false);
              didChange(selection);
              widget.onChanged?.call(selection);
            },
            itemBuilder: (_) => [
              for (final item in widget.items)
                PopupMenuItem<T>(
                  value: item.value,
                  enabled: item.enabled,
                  height: 48,
                  padding: EdgeInsets.zero,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: item.value == value
                          ? AppColors.primaryLight
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: DefaultTextStyle(
                            style: textStyle.copyWith(
                              color: !item.enabled
                                  ? AppColors.textGrey
                                  : item.value == value
                                  ? AppColors.primaryDark
                                  : AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            child: item.child,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 18,
                          child: item.value == value
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
            child: InputDecorator(
              isFocused: _focused || _menuOpen,
              isEmpty: selected == null,
              decoration: widget.decoration.copyWith(
                enabled: enabled,
                filled: true,
                fillColor: enabled ? AppColors.inputFill : AppColors.cardBorder,
                isDense: true,
                constraints: const BoxConstraints(minHeight: 48),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: _border(AppColors.inputBorder),
                enabledBorder: _border(AppColors.inputBorder),
                disabledBorder: _border(AppColors.cardBorder),
                focusedBorder: _border(AppColors.primary, 1.4),
                errorBorder: _border(AppColors.badgeRed),
                focusedErrorBorder: _border(AppColors.badgeRed, 1.4),
                errorText: errorText,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: DefaultTextStyle(
                      style: textStyle.copyWith(
                        color: enabled && selected != null
                            ? AppColors.textDark
                            : AppColors.textGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      child:
                          selected?.child ??
                          widget.hint ??
                          const Text('Auswählen'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _menuOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: enabled ? AppColors.primary : AppColors.textGrey,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
