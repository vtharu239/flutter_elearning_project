import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/personalization/screens/settings/settings.dart';
import 'package:flutter_elearning_project/features/shop/screens/home/home.dart';
import 'package:flutter_elearning_project/utils/constants/colors.dart';
import 'package:flutter_elearning_project/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final darkMode = THelperFunctions.isDarkMode(context);
    
    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) => controller.selectedIndex.value = index,

          backgroundColor: darkMode ? TColors.black : Colors.white,
          indicatorColor: darkMode ? TColors.white.withOpacity(0.1) : TColors.black.withOpacity(0.1),
          
          destinations: const [
            NavigationDestination(icon: Icon(Iconsax.home), label: "Trang chủ"),
            NavigationDestination(icon: Icon(Iconsax.element_3), label: "Khóa học"),
            NavigationDestination(icon: Icon(Iconsax.task_square), label: "Luyện thi"),
            NavigationDestination(icon: Icon(Iconsax.folder_2), label: "Tài liệu"),
            NavigationDestination(icon: Icon(Iconsax.user), label: "Cá nhân"),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}


class NavigationController extends GetxController{ // class từ GetX giúp quản lý trạng thái.
  final Rx<int> selectedIndex = 0.obs; // Rx là kiểu dữ liệu phản ứng (reactive)
                                       // .obs giúp GetX tự động cập nhật UI khi giá trị thay đổi

  final screens = [const HomeScreen(), Container(color: Colors.red), Container(color: Colors.orange), Container(color: Colors.yellow),const SettingScreen()];
}