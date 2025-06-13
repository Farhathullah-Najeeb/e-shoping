// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final void Function(String?)? onChanged;
  final int maxLines;
  final FocusNode? focusNode;
  final bool? filled;
  final Color? fillColor;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText = '',
    this.prefixIcon,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.onChanged,
    this.maxLines = 1,
    this.focusNode,
    this.filled,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colorScheme.outline, width: 1.2),
    );

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      maxLines: maxLines,
      focusNode: focusNode,
      validator: validator,
      cursorColor: colorScheme.primary,
      style: TextStyle(color: colorScheme.onSurface),

      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
        ),
        labelStyle: WidgetStateTextStyle.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.focused)) {
            return TextStyle(color: colorScheme.primary, fontSize: 16);
          }
          return TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16);
        }),

        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: colorScheme.onSurfaceVariant)
            : null,
        suffixIcon: suffixIcon,
        suffixIconColor: colorScheme.onSurfaceVariant,

        border: defaultBorder,
        enabledBorder: defaultBorder,
        focusedBorder: defaultBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
        ),
        errorBorder: defaultBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: defaultBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.error, width: 2.0),
        ),

        filled: filled ?? true,
        fillColor:
            fillColor ?? colorScheme.surfaceContainerHighest.withOpacity(0.2),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
