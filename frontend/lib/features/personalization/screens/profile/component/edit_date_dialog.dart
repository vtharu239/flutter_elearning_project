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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
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
