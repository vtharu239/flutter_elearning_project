import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';

class PasswordVerificationDialog extends StatefulWidget {
  final Function(String) onVerified;

  const PasswordVerificationDialog({super.key, required this.onVerified});

  @override
  State<PasswordVerificationDialog> createState() => _PasswordVerificationDialogState();
}

class _PasswordVerificationDialogState extends State<PasswordVerificationDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Xác thực mật khẩu'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Vui lòng nhập mật khẩu hiện tại để tiếp tục'),
          const SizedBox(height: TSizes.spaceBtwItems),
          TextField(
            controller: _passwordController,
            obscureText: _obscureText,
            decoration: InputDecoration(
              hintText: 'Mật khẩu hiện tại',
              suffixIcon: IconButton(
                icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              ),
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
          onPressed: _isLoading
              ? null
              : () {
                  if (_passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng nhập mật khẩu')),
                    );
                    return;
                  }
                  widget.onVerified(_passwordController.text);
                },
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Tiếp tục'),
        ),
      ],
    );
  }
}