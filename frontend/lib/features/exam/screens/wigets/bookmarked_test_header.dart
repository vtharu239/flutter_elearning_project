import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class BookmarkedTestsHeader extends StatelessWidget {
  const BookmarkedTestsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Đề thi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Iconsax.bookmark),
          label: const Text('Đã lưu'),
        ),
      ],
    );
  }
}