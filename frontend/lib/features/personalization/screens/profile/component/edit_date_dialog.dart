import 'package:flutter/material.dart';

class EditDateDialog extends StatefulWidget {
  final DateTime initialDate;
  final void Function(DateTime) onSave;

  const EditDateDialog({
    super.key,
    required this.initialDate,
    required this.onSave,
  });

  @override
  State<EditDateDialog> createState() => _EditDateDialogState();
}

class _EditDateDialogState extends State<EditDateDialog> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chọn ngày sinh'),
      content: SizedBox(
        height: 200,
        width: 300,
        child: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00A2FF), // Màu xanh cho ngày được chọn
            ),
          ),
          child: CalendarDatePicker(
            initialDate: widget.initialDate,
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            onDateChanged: (DateTime value) {
              setState(() {
                selectedDate = value;
              });
            },
          ),
        ),
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
            widget.onSave(selectedDate);
            Navigator.pop(context);
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}
