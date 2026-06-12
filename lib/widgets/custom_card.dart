import 'package:flutter/material.dart';
import '../../cores/theme/app_colors.dart';
import '../../cores/constants/app_sizes.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final double? elevation;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Border? border;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const CustomCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.padding,
    this.margin,
    this.border,
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? EdgeInsets.zero,
        decoration: BoxDecoration(
          color: gradient != null
              ? null
              : (backgroundColor ?? AppColors.surfaceColor),
          gradient: gradient,
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppSizes.radiusLarge,
          ),
          border: border,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: AppSizes.shadowBlurRadius,
              spreadRadius: AppSizes.shadowSpreadRadius,
              offset: const Offset(0, AppSizes.shadowOffset),
            ),
          ],
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppSizes.paddingLarge),
          child: child,
        ),
      ),
    );
  }
}
