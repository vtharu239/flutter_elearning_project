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
            activeColor: const Color(0xFF00A2FF),
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
            activeColor: const Color(0xFF00A2FF),
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
            activeColor: const Color(0xFF00A2FF),
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
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF00A2FF),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00A2FF), // Màu xanh #00A2FF
            foregroundColor: Colors.white, // Màu chữ trắng
            padding: const EdgeInsets.symmetric(
                vertical: 10), // Điều chỉnh padding nếu cần
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Bo góc
            ),
          ),
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
