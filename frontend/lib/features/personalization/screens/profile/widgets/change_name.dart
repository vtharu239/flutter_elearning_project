import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/widgets/appbar/appbar.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/profile.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ChangeName extends StatelessWidget {
  const ChangeName({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Thay đổi tên',
            style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Headings
            Text(
              'Tên của bạn sẽ hiển thị trên nhiều trang khác nhau...',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Text fields and button
            Form(
                child: Column(
              children: [
                TextFormField(
                  expands: false,
                  decoration: const InputDecoration(
                      labelText: 'Họ',
                      prefixIcon: Icon(Iconsax.user)),
                ),
                const SizedBox(height: TSizes.spaceBtwInputFields),
                TextFormField(
                  expands: false,
                  decoration: const InputDecoration(
                      labelText: 'Tên', prefixIcon: Icon(Iconsax.user)),
                ),
              ],
            )),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: () => Get.to(const ProfileScreen()), child: const Text('Lưu')),
            )
          ],
        ),
      ),
    );
  }
}
