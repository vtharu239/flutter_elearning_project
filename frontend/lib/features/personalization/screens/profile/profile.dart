import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/styles/section_heading.dart';
import 'package:flutter_elearning_project/common/widgets/appbar/appbar.dart';
import 'package:flutter_elearning_project/common/widgets/images/t_circular_images.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/widgets/change_email.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/widgets/change_phone_number.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/widgets/change_username.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/widgets/profile_menu.dart';
import 'package:flutter_elearning_project/utils/constants/image_strings.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:flutter_elearning_project/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

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
                onPressed: () => _showNameDialog(context),
              ),
              TProfileMenu(
                  title: 'Tên người dùng',
                  value: "pamela",
                  onPressed: () => Get.to(const ChangeUsername())),

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
              TProfileMenu(
                  title: 'E-mail',
                  value: "pamela",
                  onPressed: () => Get.to(const ChangeEmail())),
              TProfileMenu(
                  title: 'Số điện thoại',
                  value: "+84-909123123",
                  onPressed: () => Get.to(const ChangePhoneNumber())),
              TProfileMenu(
                title: 'Giới tính',
                value: "Nữ",
                onPressed: () => _showGenderDialog(context),
              ),
              TProfileMenu(
                title: 'Ngày sinh',
                value: "20/01/2000",
                onPressed: () => _showBirthdateDialog(context),
              ),

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

void _showNameDialog(BuildContext context) {
  final darkMode = THelperFunctions.isDarkMode(context);

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Thay đổi tên'),
        backgroundColor: darkMode ? Colors.grey[850] : Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: firstNameController,
              decoration: const InputDecoration(
                labelText: 'Họ',
                prefixIcon: Icon(Iconsax.user),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),
            TextFormField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: 'Tên',
                prefixIcon: Icon(Iconsax.user),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle save logic here
              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      );
    },
  );
}

void _showGenderDialog(BuildContext context) {
  final darkMode = THelperFunctions.isDarkMode(context);

  String selectedGender = 'Nữ';
  final List<String> genderOptions = ['Nam', 'Nữ', 'Khác'];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Thay đổi giới tính'),
            backgroundColor: darkMode ? Colors.grey[850] : Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: genderOptions.map((gender) {
                return RadioListTile<String>(
                  title: Text(gender),
                  value: gender,
                  groupValue: selectedGender,
                  onChanged: (value) {
                    setState(() => selectedGender = value!);
                  },
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle save logic here
                  Navigator.pop(context);
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      );
    },
  );
}

void _showBirthdateDialog(BuildContext context) {
  final darkMode = THelperFunctions.isDarkMode(context);

  DateTime selectedDate = DateTime(2000, 1, 1);
  final TextEditingController dateController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Thay đổi ngày sinh'),
        backgroundColor: darkMode ? Colors.grey[850] : Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: 'Ngày sinh',
                prefixIcon: const Icon(Iconsax.calendar),
                suffixIcon: IconButton(
                  icon: const Icon(Iconsax.calendar_search),
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      dateController.text =
                          DateFormat('dd/MM/yyyy').format(picked);
                      selectedDate = picked;
                    }
                  },
                ),
              ),
              readOnly: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle save logic here
              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      );
    },
  );
}
