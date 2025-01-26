import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/profile.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ChangeUsername extends StatelessWidget {
  const ChangeUsername({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thay đổi tên người dùng',
            style: Theme.of(context).textTheme.headlineSmall),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tên người dùng không được trùng',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            
            const SizedBox(height: TSizes.spaceBtwSections),

            Form(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Tên người dùng mới',
                  prefixIcon: Icon(Iconsax.user),
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.to(const ProfileScreen()),
                child: const Text('Lưu'),
              ),
            )
          ],
        ),
      ),
    );
  }
}