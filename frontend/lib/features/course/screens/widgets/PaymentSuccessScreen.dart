import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/course/screens/widgets/CourseDetailScreen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final int orderId;
  final int courseId; // Add courseId to navigate back to CourseDetailScreen
  final VoidCallback onContinue;

  const PaymentSuccessScreen({
    super.key,
    required this.orderId,
    required this.courseId,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 16),
              const Text(
                'Thanh toán thành công!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mã đơn hàng: $orderId',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              const Text(
                'Cảm ơn bạn đã đăng ký khóa học. Bạn có thể bắt đầu học ngay bây giờ!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Call the onContinue callback to notify the parent
                  onContinue();
                  // Navigate to CourseDetailScreen
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                          CourseDetailScreen(courseId: courseId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text(
                  'Tiếp tục học',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
