import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';

class PhoneDialog extends StatelessWidget {
  final String phoneNo;
  final VoidCallback onChange;
  final VoidCallback onUnlink;

  const PhoneDialog({
    super.key,
    required this.phoneNo,
    required this.onChange,
    required this.onUnlink,
  });

  String _maskPhoneNumber(String phoneNo) {
    if (phoneNo.length < 4) return phoneNo;
    return phoneNo.replaceRange(4, phoneNo.length - 4, '****');
  }

  @override
  Widget build(BuildContext context) {
    final maskedPhone = _maskPhoneNumber(phoneNo);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
      ),
      titlePadding: const EdgeInsets.all(TSizes.defaultSpace),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
      actionsPadding: const EdgeInsets.all(TSizes.defaultSpace),
      title: Column(
        children: [
          const Icon(
            Icons.phone,
            size: 40,
            color: Colors.blue,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(
            'Số điện thoại của bạn:',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TSizes.sm),
          Text(
            maskedPhone,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: const Text(
        'Số điện thoại này được liên kết với tài khoản của bạn và chỉ hiển thị cho bạn. '
        'Nếu bạn đổi số điện thoại khác, số điện thoại này có thể vẫn được giữ lại vì mục đích khôi phục tài khoản.',
        textAlign: TextAlign.center,
      ),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onChange,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A2FF), // Màu xanh #00A2FF
                  foregroundColor: Colors.white, // Màu chữ trắng
                  padding: const EdgeInsets.symmetric(
                      vertical: 10), // Điều chỉnh padding nếu cần
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Bo góc
                  ),
                ),
                child: const Text('Thay đổi số điện thoại'),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onUnlink,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Hủy liên kết số điện thoại'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
