import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/products/cart/cart_menu_icon.dart';
import 'package:flutter_elearning_project/common/widgets/appbar/appbar.dart';
import 'package:flutter_elearning_project/features/personalization/controllers/auth_controller.dart';
import 'package:flutter_elearning_project/utils/constants/colors.dart';
import 'package:flutter_elearning_project/utils/constants/text_strings.dart';
import 'package:get/get.dart';

class THomeAppBar extends StatelessWidget {
  const THomeAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (controller) {
      return Obx(() => TAppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mừng bạn quay lại, ${controller.user.value?.fullName ?? 'User'}!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  softWrap: true, // Ensure the text wraps
                  overflow: TextOverflow
                      .visible, // Allow text to overflow into next line if necessary
                ),
                Text(
                  TTexts.homeAppbarSubTitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white70),
                  softWrap: true, // Ensure the text wraps
                  overflow: TextOverflow
                      .visible, // Allow text to overflow into next line if necessary
                ),
              ],
            ),
            actions: [
              TNotifyCounterIcon(
                onPressed: () {},
                iconColor: TColors.white,
              )
            ],
          ));
    });
  }
}
