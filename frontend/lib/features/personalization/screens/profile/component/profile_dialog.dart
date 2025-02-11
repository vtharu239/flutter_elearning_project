import 'package:flutter/material.dart';

class EditFieldDialog extends StatelessWidget {
  final String title;
  final String initialValue;
  final String? Function(String?)? validator;
  final void Function(String) onSave;
  final TextInputType? keyboardType;

  const EditFieldDialog({
    super.key,
    required this.title,
    required this.initialValue,
    this.validator,
    required this.onSave,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue);

    return AlertDialog(
      title: Text(title),
      content: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: title,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            onSave(controller.text);
            Navigator.pop(context);
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}
