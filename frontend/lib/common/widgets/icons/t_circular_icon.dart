import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/utils/constants/colors.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:flutter_elearning_project/utils/helpers/helper_functions.dart';

class TCircularIcon extends StatelessWidget {
  const TCircularIcon({
    super.key,
    required this.icon,
    this.width,
    this.height,
    this.size = TSizes.lg,
    this.onPressed,
    this.color,
    this.backgroundColor,
  });

  final double? width, height, size;
  final IconData icon;
  final Color? color;
  final Color? backgroundColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          color: backgroundColor != null
              ? backgroundColor!
              : THelperFunctions.isDarkMode(context)
                  ? TColors.black.withValues(alpha: 0.9)
                  : TColors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(100)),
      child: IconButton(onPressed: () {}, icon: Icon(icon, color: color, size: size)),
    );
  }
}
