import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/styles/section_heading.dart';
import 'package:flutter_elearning_project/common/widgets/custom_shapes/container/primary_header_container.dart';
import 'package:flutter_elearning_project/common/widgets/images/t_circular_images.dart';
import 'package:flutter_elearning_project/common/widgets/list_tiles/settings_menu_tile.dart';
import 'package:flutter_elearning_project/features/authentication/screens/login/login.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/profile.dart';
import 'package:flutter_elearning_project/features/personalization/screens/settings/UserAuthController.dart';
import 'package:flutter_elearning_project/utils/constants/image_strings.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// -- Header with Cover Image
            TPrimaryHeaderContainer(
              child: Stack(
                children: [
                  /// Cover Image
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(TImages.defaultCover),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  /// Dãy ngang màu đen với opacity 0.2 chứa tên, email và nút chỉnh sửa
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 170,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// Cột chứa tên và email
                          Padding(
                            padding: const EdgeInsets.only(left: 90, top: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pamela',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                          fontSize: 20),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.email_outlined,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'palm@gmail.com',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// Nút Edit
                  Positioned(
                    right: 10,
                    bottom: 25,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black54,
                      ),
                      child: IconButton(
                        onPressed: () => Get.to(const ProfileScreen()),
                        icon: const Icon(Iconsax.edit, color: Colors.white),
                      ),
                    ),
                  ),

                  /// User Profile Card
                  const Positioned(
                    left: 20,
                    bottom: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TCircularImages(
                          image: TImages.user,
                          width: 80,
                          height: 80,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// -- Body
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  /// -- Account Settings
                  const TSectionHeading(title: 'Account Settings'),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  TSettingsMenuTile(
                    icon: Iconsax.safe_home,
                    title: 'My Addresses',
                    subTitle: 'Set shopping delivery address',
                    onTap: () {},
                  ),
                  TSettingsMenuTile(
                    icon: Iconsax.safe_home,
                    title: 'My Addresses',
                    subTitle: 'Set shopping delivery address',
                    onTap: () {},
                  ),
                  TSettingsMenuTile(
                    icon: Iconsax.safe_home,
                    title: 'My Addresses',
                    subTitle: 'Set shopping delivery address',
                    onTap: () {},
                  ),
                  TSettingsMenuTile(
                    icon: Iconsax.safe_home,
                    title: 'My Addresses',
                    subTitle: 'Set shopping delivery address',
                    onTap: () {},
                  ),

                  /// -- App Settings
                  const SizedBox(height: TSizes.spaceBtwSections),
                  const TSectionHeading(
                      title: 'App Settings', showActionButton: false),
                  const SizedBox(height: TSizes.spaceBtwItems),
                  const TSettingsMenuTile(
                      icon: Iconsax.document_upload,
                      title: 'Load Data',
                      subTitle: 'Upload Data to your Database'),
                  TSettingsMenuTile(
                    icon: Iconsax.security,
                    title: 'Switch Mode',
                    subTitle: 'Switch to Light or Dark Mode',
                    trailing: Switch(value: true, onChanged: (value) {}),
                  ),
                  TSettingsMenuTile(
                    icon: Iconsax.security,
                    title: 'Switch Mode',
                    subTitle: 'Switch to Light or Dark Mode',
                    trailing: Switch(value: false, onChanged: (value) {}),
                  ),
                  TSettingsMenuTile(
                    icon: Iconsax.security,
                    title: 'Switch Mode',
                    subTitle: 'Switch to Light or Dark Mode',
                    trailing: Switch(value: true, onChanged: (value) {}),
                  ),

                  const TSettingsMenuTile(
                      icon: Iconsax.document_upload,
                      title: 'Load Data',
                      subTitle: 'Upload Data to your Database'),

                  /// Logout Button
                  const SizedBox(height: TSizes.spaceBtwSections),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                        onPressed: () {
                          // Use the authentication controller to logout
                          final authController =
                              Provider.of<UserAuthController>(context,
                                  listen: false);
                          authController.logout();

                          // Navigate to login screen
                          Get.offAll(() => const LoginScreen());
                        },
                        child: const Text('Đăng xuất')),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
