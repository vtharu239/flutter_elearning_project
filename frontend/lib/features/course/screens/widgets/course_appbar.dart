import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/products/cart/cart_menu_icon.dart';
import 'package:flutter_elearning_project/common/widgets/appbar/appbar.dart';
import 'package:flutter_elearning_project/utils/constants/colors.dart';
import 'package:flutter_elearning_project/utils/constants/text_strings.dart';

class TCourseAppBar extends StatelessWidget {
  const TCourseAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return TAppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TTexts.courseAppbarTitle,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            softWrap: true, // Ensure the text wraps
            overflow: TextOverflow
                .visible, // Allow text to overflow into next line if necessary
          ),
          Text(
            TTexts.courseAppbarSubTitle,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
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
        ),
      ],
    );
  }
}
