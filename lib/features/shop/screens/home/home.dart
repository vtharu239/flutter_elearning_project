import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/widgets/custom_shapes/container/primary_header_container.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Cho phép giao diện cuộn theo chiều dọc
        child: Column(
          children: [
            TPrimaryHeaderContainer(
              child: Container()
            ),
          ],
        ),
      ),
    );
  }
}