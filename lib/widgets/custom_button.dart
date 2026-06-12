import 'package:flutter/material.dart';
import '../../cores/theme/app_colors.dart';
import '../../cores/theme/app_text_styles.dart';
import '../../cores/constants/app_sizes.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final ButtonStyle? style;
  final bool isLoading;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final double? elevation;
  final ButtonType buttonType;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style,
    this.isLoading = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.elevation,
    this.buttonType = ButtonType.filled,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ?? AppSizes.buttonHeightMedium;
    final buttonRadius = borderRadius ?? AppSizes.radiusLarge;

    switch (buttonType) {
      case ButtonType.filled:
        return SizedBox(
          width: width,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: enabled && !isLoading ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? AppColors.primaryColor,
              foregroundColor: textColor ?? AppColors.white,
              elevation: elevation ?? 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonRadius),
              ),
              disabledBackgroundColor: AppColors.grey300,
              disabledForegroundColor: AppColors.grey500,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (prefixIcon != null) ...[
                        prefixIcon!,
                        const SizedBox(width: AppSizes.paddingSmall),
                      ],
                      Text(
                        label,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: textColor ?? AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (suffixIcon != null) ...[
                        const SizedBox(width: AppSizes.paddingSmall),
                        suffixIcon!,
                      ],
                    ],
                  ),
          ),
        );

      case ButtonType.outlined:
        return SizedBox(
          width: width,
          height: buttonHeight,
          child: OutlinedButton(
            onPressed: enabled && !isLoading ? onPressed : null,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: backgroundColor ?? AppColors.primaryColor,
                width: 2,
              ),
              foregroundColor: textColor ?? AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonRadius),
              ),
              disabledForegroundColor: AppColors.grey500,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryColor,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (prefixIcon != null) ...[
                        prefixIcon!,
                        const SizedBox(width: AppSizes.paddingSmall),
                      ],
                      Text(
                        label,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: textColor ?? AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (suffixIcon != null) ...[
                        const SizedBox(width: AppSizes.paddingSmall),
                        suffixIcon!,
                      ],
                    ],
                  ),
          ),
        );

      case ButtonType.text:
        return TextButton(
          onPressed: enabled && !isLoading ? onPressed : null,
          style: TextButton.styleFrom(
            foregroundColor: textColor ?? AppColors.primaryColor,
            disabledForegroundColor: AppColors.grey500,
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryColor,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (prefixIcon != null) ...[
                      prefixIcon!,
                      const SizedBox(width: AppSizes.paddingSmall),
                    ],
                    Text(
                      label,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: textColor ?? AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (suffixIcon != null) ...[
                      const SizedBox(width: AppSizes.paddingSmall),
                      suffixIcon!,
                    ],
                  ],
                ),
        );
    }
  }
}

enum ButtonType { filled, outlined, text }
