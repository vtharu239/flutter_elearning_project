import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';

class SearchResultScreen extends StatelessWidget {
  final String query;
  final String filter;

  const SearchResultScreen({
    super.key,
    required this.query,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kết quả tìm kiếm: $query')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (filter == 'all' || filter == 'course') ...[
                const Text('Khóa học',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: TSizes.spaceBtwItems),
                // CourseListSection with filtered results
              ],
              if (filter == 'all' || filter == 'test') ...[
                const Text('Đề thi',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: TSizes.spaceBtwItems),
                // TestListSection with filtered results
              ],
              // Add more sections as needed
            ],
          ),
        ),
      ),
    );
  }
}