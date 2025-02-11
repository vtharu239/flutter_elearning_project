import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/styles/section_heading.dart';
import 'package:flutter_elearning_project/common/widgets/appbar/appbar.dart';
import 'package:flutter_elearning_project/common/widgets/images/t_circular_images.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/widgets/profile_menu.dart';
import 'package:flutter_elearning_project/utils/constants/image_strings.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TAppBar(showBackArrow: true, title: Text('Trang cá nhân')),

      /// -- Body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// Cover Image Section
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(TImages.defaultCover),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -90,
                    child: Column(
                      children: [
                        const TCircularImages(
                            image: TImages.user, width: 100, height: 100),
                        TextButton(
                            onPressed: () {},
                            child: const Text('Đổi ảnh đại diện')),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      onPressed: () {
                        // Chức năng thay đổi ảnh bìa
                      },
                      icon: const Icon(Iconsax.edit, color: Colors.blue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 70),

              /// Details
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Heading Profile Info
              const TSectionHeading(
                  title: "Thông tin hồ sơ", showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwItems),

              TProfileMenu(
                title: 'Tên',
                value: "Palm",
                onPressed: () => {},
              ),
              TProfileMenu(
                  title: 'Tên người dùng',
                  value: "pamela",
                  onPressed: () => {},
              ),

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
                  onPressed: () => {},
              ),
              TProfileMenu(
                  title: 'E-mail',
                  value: "pamela",
                  onPressed: () => {},
              ),
              TProfileMenu(
                  title: 'Số điện thoại',
                  value: "+84-909123123",
                  onPressed: () => {},
              ),
              TProfileMenu(
                title: 'Giới tính',
                value: "Nữ",
                onPressed: () => {},
              ),
              TProfileMenu(
                title: 'Ngày sinh',
                value: "20/01/2000",
                onPressed: () => {},
              ),

              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),
            ],
          ),
        ),
      ),
    );
  }
}
