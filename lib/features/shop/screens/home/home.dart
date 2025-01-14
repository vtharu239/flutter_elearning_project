import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/styles/section_heading.dart';
import 'package:flutter_elearning_project/common/widgets/custom_shapes/container/primary_header_container.dart';
import 'package:flutter_elearning_project/common/widgets/custom_shapes/container/search_container.dart';
import 'package:flutter_elearning_project/features/shop/screens/home/widgets/home_appbar.dart';
import 'package:flutter_elearning_project/features/shop/screens/home/widgets/home_categories.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        // Cho phép giao diện cuộn theo chiều dọc
        child: Column(
          children: [
            /// -- Header
            TPrimaryHeaderContainer(
              child: Column(
                children: [
                  /// -- AppBar
                  THomeAppBar(),
                  SizedBox(height: TSizes.spaceBtwSections),

                  /// -- SearchBar
                  TSerachContainer(text: 'Tìm kiếm tài liệu hoặc khóa học...'),
                  SizedBox(height: TSizes.spaceBtwSections),

                  /// -- Categories
                  Padding(
                    padding: EdgeInsets.only(left: TSizes.defaultSpace),
                    child: Column(
                      children: [
                        /// -- Heading
                        TSectionHeading(
                            title: 'Thể loại',
                            showActionButton: false,
                            textColor: Colors.white),
                        SizedBox(height: TSizes.spaceBtwItems),

                        /// -- Categories
                        THomeCategories(),
                      ],
                    ),
                  ),
                  SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
