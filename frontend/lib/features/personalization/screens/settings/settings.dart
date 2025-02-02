import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/common/styles/section_heading.dart';
import 'package:flutter_elearning_project/common/widgets/custom_shapes/container/primary_header_container.dart';
import 'package:flutter_elearning_project/common/widgets/images/t_circular_images.dart';
import 'package:flutter_elearning_project/common/widgets/list_tiles/settings_menu_tile.dart';
import 'package:flutter_elearning_project/features/authentication/screens/login/login.dart';
import 'package:flutter_elearning_project/features/personalization/screens/course/my_courses.dart';
import 'package:flutter_elearning_project/features/personalization/screens/course/test_result.dart';
import 'package:flutter_elearning_project/features/personalization/screens/profile/profile.dart';
import 'package:flutter_elearning_project/features/personalization/screens/settings/UserAuthController.dart';
import 'package:flutter_elearning_project/providers/theme_provider.dart';
import 'package:flutter_elearning_project/utils/constants/image_strings.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// -- Header with Cover Image
            TPrimaryHeaderContainer(
              child: Stack(
                children: [
                  /// Cover Image
                  Container(
                    width: double.infinity,
                    height: 250,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(TImages.defaultCover),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  /// Dãy ngang màu đen với opacity 0.2 chứa tên, email và nút chỉnh sửa
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 170,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          /// Cột chứa tên và email
                          Padding(
                            padding: const EdgeInsets.only(left: 90, top: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pamela',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                          fontSize: 20),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.email_outlined,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'palm@gmail.com',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// Nút Edit
                  Positioned(
                    right: 10,
                    bottom: 25,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black54,
                      ),
                      child: IconButton(
                        onPressed: () => Get.to(const ProfileScreen()),
                        icon: const Icon(Iconsax.edit, color: Colors.white),
                      ),
                    ),
                  ),

                  /// User Profile Card
                  const Positioned(
                    left: 20,
                    bottom: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TCircularImages(
                          image: TImages.user,
                          width: 80,
                          height: 80,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            TabBar(
              controller: _tabController,
              labelColor: isDarkMode ? Colors.white : Colors.blue[700],
              unselectedLabelColor: Colors.grey,
              indicatorColor: isDarkMode ? Colors.white : Colors.blue[700],
              tabs: const [
                Tab(text: 'Khóa học'),
                Tab(text: 'Kết quả luyện thi'),
              ],
            ),

            // Tab Bar View
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Courses Tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(TSizes.defaultSpace),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Các khóa đã kích hoạt',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        const EnrolledCourseCard(
                          courseName: 'Complete TOEIC',
                          progress: 0.07,
                          nextLesson: 'Ngữ pháp TOEIC - Đại từ',
                          status: 'Đã kích hoạt',
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        Text(
                          'Các khóa học thử',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        const EnrolledCourseCard(
                          courseName: '[Practical English] 3600 từ vựng',
                          progress: 0,
                          nextLesson:
                              'Nature, the world (Thiên nhiên, thế giới)',
                          status: 'Học thử',
                        ),
                      ],
                    ),
                  ),

                  // Test Results Tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(TSizes.defaultSpace),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Kết quả các bài luyện thi',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: TSizes.spaceBtwItems),
                        const LatestTestResultsSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Settings Section
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  const TSectionHeading(
                    title: 'Cài đặt ứng dụng',
                    buttonTitle: '',
                  ),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  // Language Settings
                  TSettingsMenuTile(
                    icon: Iconsax.language_square,
                    title: 'Ngôn ngữ',
                    subTitle: 'Thay đổi ngôn ngữ của ứng dụng',
                    trailing: DropdownButton<String>(
                      value: 'Vietnamese',
                      items: const [
                        DropdownMenuItem(
                            value: 'English', child: Text('English')),
                        DropdownMenuItem(
                            value: 'Vietnamese', child: Text('Tiếng Việt')),
                      ],
                      onChanged: (value) {},
                    ),
                  ),

                  // Dark Mode Toggle
                  TSettingsMenuTile(
                    icon: Iconsax.moon,
                    title: 'Chế độ sáng, tối',
                    subTitle: 'Chọn chế độ giao diện',
                    trailing: DropdownButton<ThemeModeType>(
                      value: Provider.of<ThemeProvider>(context).themeMode,
                      items: const [
                        DropdownMenuItem(
                          value: ThemeModeType.system,
                          child: Text('Hệ thống'),
                        ),
                        DropdownMenuItem(
                          value: ThemeModeType.light,
                          child: Text('Sáng'),
                        ),
                        DropdownMenuItem(
                          value: ThemeModeType.dark,
                          child: Text('Tối'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          Provider.of<ThemeProvider>(context, listen: false)
                              .setTheme(value);
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: TSizes.spaceBtwSections),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        final authController = Provider.of<UserAuthController>(
                            context,
                            listen: false);
                        authController.logout();
                        Get.offAll(() => const LoginScreen());
                      },
                      child: const Text('Đăng xuất'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
