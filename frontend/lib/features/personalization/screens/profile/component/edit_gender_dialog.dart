import 'package:flutter/material.dart';

class EditGenderDialog extends StatefulWidget {
  final String initialValue;
  final void Function(String) onSave;

  const EditGenderDialog({
    super.key,
    required this.initialValue,
    required this.onSave,
  });

  @override
  State<EditGenderDialog> createState() => _EditGenderDialogState();
}

class _EditGenderDialogState extends State<EditGenderDialog> {
  late String selectedGender;

  @override
  void initState() {
    super.initState();
    selectedGender = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chọn giới tính'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<String?>(
            title: const Text('Nam'),
            value: 'male',
            groupValue: selectedGender,
            onChanged: (value) {
              setState(() {
                selectedGender = value!;
              });
            },
          ),
          RadioListTile<String?>(
            title: const Text('Nữ'),
            value: 'female',
            groupValue: selectedGender,
            onChanged: (value) {
              setState(() {
                selectedGender = value!;
              });
            },
          ),
          RadioListTile<String?>(
            title: const Text('Khác'),
            value: 'other',
            groupValue: selectedGender,
            onChanged: (value) {
              setState(() {
                selectedGender = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(selectedGender);
            Navigator.pop(context);
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}