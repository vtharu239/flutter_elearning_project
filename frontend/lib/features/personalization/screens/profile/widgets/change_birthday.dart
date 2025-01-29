import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/widgets/appbar/appbar.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/profile.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class ChangeBirthdate extends StatefulWidget {
  const ChangeBirthdate({super.key});

  @override
  _ChangeBirthdateState createState() => _ChangeBirthdateState();
}

class _ChangeBirthdateState extends State<ChangeBirthdate> {
  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text('Thay đổi ngày sinh',
            style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn ngày sinh của bạn',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            TextFormField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Ngày sinh',
                prefixIcon: const Icon(Iconsax.calendar),
                suffixIcon: IconButton(
                  icon: const Icon(Iconsax.calendar_search),
                  onPressed: () => _selectDate(context),
                ),
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedDate != null
                    ? () => Get.to(ProfileScreen())
                    : null,
                child: const Text('Lưu'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
