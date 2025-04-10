// import 'package:flutter/material.dart';
// import 'package:flutter_elearning_project/features/shop/screens/home/widgets/course_schedule_model.dart';

// class DailyScheduleTab extends StatefulWidget {
//   final int courseId;

//   const DailyScheduleTab({super.key, required this.courseId});

//   @override
//   State<DailyScheduleTab> createState() => _DailyScheduleTabState();
// }

// class _DailyScheduleTabState extends State<DailyScheduleTab> {
//   CourseScheduleModel? schedule;
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     loadSchedule();
//   }

//   Future<void> loadSchedule() async {
//     final data = await ScheduleService.fetchSchedule(widget.courseId);
//     setState(() {
//       schedule = data;
//       isLoading = false;
//     });
//   }

//   void toggleCheckbox(int index) async {
//     setState(() {
//       schedule!.daily[index].checked = !schedule!.daily[index].checked;
//     });

//     final success = await ScheduleService.updateSchedule(schedule!);
//     if (!success) {
//       // rollback nếu lỗi
//       setState(() {
//         schedule!.daily[index].checked = !schedule!.daily[index].checked;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Lỗi cập nhật trạng thái')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) return const Center(child: CircularProgressIndicator());

//     return ListView.builder(
//       itemCount: schedule?.daily.length ?? 0,
//       itemBuilder: (context, index) {
//         final task = schedule!.daily[index];
//         return CheckboxListTile(
//           title: Text(task.title),
//           value: task.checked,
//           onChanged: (_) => toggleCheckbox(index),
//         );
//       },
//     );
//   }0.
// }0.
