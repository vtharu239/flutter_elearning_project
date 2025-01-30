import 'package:flutter_elearning_project/utils/constants/image_strings.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class SettingController extends GetxController {
  RxString bannerImage = RxString(TImages.defaultCover); // Ảnh bìa mặc định
  RxString avatarImage = RxString(TImages.user);

  void updateBanner(String newImage) {
    bannerImage.value = newImage;
  }

  void updateAvatar(String newImage) {
    avatarImage.value = newImage;
  }
}