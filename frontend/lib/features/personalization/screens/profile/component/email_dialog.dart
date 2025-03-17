import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';

class EmailDialog extends StatelessWidget {
  final String email;
  final VoidCallback onChange;
  final VoidCallback onUnlink;

  const EmailDialog({
    super.key,
    required this.email,
    required this.onChange,
    required this.onUnlink,
  });

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final localPart = parts[0];
    final domainPart = parts[1];
    if (localPart.length <= 2) return email;
    return '${localPart.substring(0, 2)}****@$domainPart';
  }

  @override
  Widget build(BuildContext context) {
    final maskedEmail = _maskEmail(email);

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
            Icons.email,
            size: 40,
            color: Colors.blue,
          ),
          const SizedBox(height: TSizes.spaceBtwItems),
          Text(
            'Email của bạn:',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: TSizes.sm),
          Text(
            maskedEmail,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: const Text(
        'Email này được liên kết với tài khoản của bạn và chỉ hiển thị cho bạn. '
        'Nếu bạn đổi email khác, email này có thể vẫn được giữ lại vì mục đích khôi phục tài khoản.',
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
                child: const Text('Thay đổi email'),
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
                child: const Text('Hủy liên kết email'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
