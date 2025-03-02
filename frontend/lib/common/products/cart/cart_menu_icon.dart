import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/utils/constants/colors.dart';
import 'package:iconsax/iconsax.dart';

class TNotifyCounterIcon extends StatelessWidget {
  const TNotifyCounterIcon({
    super.key,
    required this.onPressed, required this.iconColor,
  });

  final Color iconColor;
  final VoidCallback onPressed;
  

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(onPressed: onPressed, icon: Icon(Iconsax.notification, color: iconColor)),
        Positioned(
          right: 0,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: TColors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
                child: Text('2',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .apply(color: TColors.white, fontSizeFactor: 0.8))),
          ),
        ),
      ],
    );
  }
}