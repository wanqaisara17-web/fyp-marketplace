import 'package:flutter/material.dart';
import '../../cores/theme/app_colors.dart';
import '../../cores/theme/app_text_styles.dart';
import '../../cores/constants/app_sizes.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool centerTitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? titleColor;
  final double? elevation;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onLeadingPressed;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.centerTitle = false,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.titleColor,
    this.elevation,
    this.bottom,
    this.onLeadingPressed,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.headlineMedium.copyWith(
          color: titleColor ?? AppColors.textPrimaryColor,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.surfaceColor,
      elevation: elevation ?? 0,
      leading:
          leading ??
          (showBackButton && Navigator.of(context).canPop()
              ? GestureDetector(
                  onTap: onLeadingPressed ?? () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back),
                )
              : null),
      actions: actions,
      bottom: bottom,
      scrolledUnderElevation: 0,
    );
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(
      AppSizes.appBarHeight + (bottom?.preferredSize.height ?? 0),
    );
  }
}
