import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:get/get.dart';

class EditFieldDialog extends StatefulWidget {
  final String title;
  final String? initialValue;
  final Function(String) onSave;
  final TextInputType? keyboardType;

  const EditFieldDialog({
    super.key,
    required this.title,
    this.initialValue,
    required this.onSave,
    this.keyboardType,
  });

  @override
  State<EditFieldDialog> createState() => _EditFieldDialogState();
}

class _EditFieldDialogState extends State<EditFieldDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validateField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập ${widget.title.toLowerCase()}';
    }

    switch (widget.title) {
      case 'Số điện thoại':
        if (value.contains(' ')) {
          return 'Số điện thoại không được chứa khoảng trắng';
        }
        if (!RegExp(r'^\d+$').hasMatch(value)) {
          return 'Số điện thoại không được chứa chữ cái hoặc ký tự đặc biệt';
        }
        if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
          return 'Số điện thoại phải có 10 chữ số';
        }
        break;
      case 'Tên người dùng':
        if (value.length > 20) {
          return 'Tên người dùng không được quá 20 ký tự';
        }
        if (value.contains(' ')) {
          return 'Tên người dùng không được chứa khoảng trắng';
        }
        if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
          return 'Tên người dùng chỉ được chứa chữ cái, số và dấu gạch dưới';
        }
        break;
      case 'Họ và tên':
        if (value.length > 50) {
          return 'Họ và tên không được quá 50 ký tự';
        }
        if (!RegExp(r'^[a-zA-ZÀ-ỹ\s]+$').hasMatch(value)) {
          return 'Họ và tên chỉ được chứa chữ cái và khoảng trắng';
        }
        break;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chỉnh sửa ${widget.title}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              TextFormField(
                controller: _controller,
                keyboardType: widget.keyboardType,
                decoration: InputDecoration(
                  labelText: widget.title,
                ),
                validator: _validateField,
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSave(_controller.text);
                        Get.back();
                      }
                    },
                    child: const Text('Lưu'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
