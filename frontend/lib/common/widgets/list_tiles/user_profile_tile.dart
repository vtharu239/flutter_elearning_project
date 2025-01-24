// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/widgets/images/t_circular_images.dart';
import 'package:flutter_elearning_project/features/personalization/screens/settings/UserAuthController.dart';
import 'package:flutter_elearning_project/utils/constants/colors.dart';
import 'package:flutter_elearning_project/utils/constants/image_strings.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class TUserProfileTile extends StatelessWidget {
  const TUserProfileTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<UserAuthController>(
      builder: (context, authController, child) {
        return ListTile(
          leading: const CircleAvatar(
            child: Icon(Iconsax.user),
          ),
          title: Text(authController.fullName,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .apply(color: Colors.white)),
          subtitle: Text(authController.email ?? 'user@example.com',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .apply(color: Colors.white)),
        );
      },
    );
  }
}
