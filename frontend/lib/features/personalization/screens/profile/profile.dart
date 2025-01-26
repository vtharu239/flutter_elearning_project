import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/styles/section_heading.dart';
import 'package:flutter_elearning_project/common/widgets/appbar/appbar.dart';
import 'package:flutter_elearning_project/common/widgets/images/t_circular_images.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/widgets/change_birthday.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/widgets/change_email.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/widgets/change_gender.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/widgets/change_name.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/widgets/change_phone_number.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/widgets/change_username.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/widgets/profile_menu.dart';
import 'package:flutter_elearning_project/utils/constants/image_strings.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TAppBar(showBackArrow: true, title: Text('Profile')),

      /// -- Body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// Profile Picture
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    const TCircularImages(
                        image: TImages.user, width: 80, height: 80),
                    TextButton(
                        onPressed: () {},
                        child: const Text('Change Profile Picture')),
                  ],
                ),
              ),

              /// Details
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Heading Profile Info
              const TSectionHeading(
                  title: "Thông tin hồ sơ", showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwItems),

              TProfileMenu(title: 'Tên', value: "Palm", onPressed: () => Get.to(ChangeName())),
              TProfileMenu(
                  title: 'Tên người dùng', value: "pamela", onPressed: () => Get.to(ChangeUsername())),

              const SizedBox(height: TSizes.spaceBtwItems),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Heading Personal Info
              const TSectionHeading(
                  title: "Thông tin cá nhân", showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwItems),

              TProfileMenu(
                  title: 'ID người dùng',
                  value: "223344",
                  icon: Iconsax.copy,
                  onPressed: () {}),
              TProfileMenu(title: 'E-mail', value: "pamela", onPressed: () => Get.to(ChangeEmail())),
              TProfileMenu(
                  title: 'Số điện thoại',
                  value: "+84-909123123",
                  onPressed: () => Get.to(ChangePhoneNumber())),
              TProfileMenu(title: 'Giới tính', value: "Nữ", onPressed: () => Get.to(ChangeGender())),
              TProfileMenu(
                  title: 'Ngày sinh', value: "20/01/2000", onPressed: () => Get.to(ChangeBirthdate())),

              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              // Center(
              //   child: TextButton(
              //     onPressed: () {},
              //     child: const Text('Xóa tài khoản',
              //         style: TextStyle(color: Colors.red)),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}