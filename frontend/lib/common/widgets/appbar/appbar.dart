import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:flutter_elearning_project/utils/device/device_utility.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class TAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TAppBar({
    super.key,
    this.title,
    this.actions,
    this.leadingIcon,
    this.leadingOnPressed,
    this.showBackArrow = false,
    this.padding = const EdgeInsets.symmetric(horizontal: TSizes.iconXs),
  });

  final Widget? title;
  final bool showBackArrow;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;
   final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: padding, // symetric horizontal: đối xứng theo chiều ngang
      child: AppBar(
        automaticallyImplyLeading: false, //// Ngăn mũi tên quay lại
        toolbarHeight: 100, // Tăng chiều cao của AppBar
        leading: showBackArrow
            ? IconButton(
                color: darkMode
                    ? Colors.white
                    : Colors
                        .black, // Màu trắng cho dark mode, đen cho light mode
                onPressed: () => Get.back(),
                icon: const Icon(Iconsax.arrow_left))
            : leadingIcon != null
                ? IconButton(
                    color: darkMode
                        ? Colors.white
                        : Colors
                            .black, // Màu trắng cho dark mode, đen cho light mode
                    onPressed: leadingOnPressed,
                    icon: Icon(leadingIcon))
                : null,
        title: title,
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(TDeviceUtils.getAppBarHeight());
}
