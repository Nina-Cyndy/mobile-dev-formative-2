import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// Shared primary action button with a built-in loading state, used across
/// auth, opportunity, and profile screens so button styling stays consistent
/// instead of every screen re-declaring its own ElevatedButton.
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool outlined;
  final Color? color;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.outlined = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
              Text(label),
            ],
          );

    if (outlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color ?? AppColors.aluBlue),
          foregroundColor: color ?? AppColors.aluBlue,
        ),
        child: child,
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: color != null
          ? ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white)
          : null,
      child: child,
    );
  }
}
