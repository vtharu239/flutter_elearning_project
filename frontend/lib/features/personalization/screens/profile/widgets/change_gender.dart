import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/widgets/appbar/appbar.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/profile.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:get/get.dart';

class ChangeGender extends StatefulWidget {
  const ChangeGender({super.key});

  @override
  _ChangeGenderState createState() => _ChangeGenderState();
}

class _ChangeGenderState extends State<ChangeGender> {
  String _selectedGender = 'Nữ';
  final List<String> _genderOptions = ['Nam', 'Nữ', 'Khác'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Thay đổi giới tính',
            style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn giới tính của bạn',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            Column(
              children: _genderOptions.map((gender) {
                return RadioListTile<String>(
                  title: Text(gender),
                  value: gender,
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.to(ProfileScreen()),
                child: const Text('Lưu'),
              ),
            )
          ],
        ),
      ),
    );
  }
}