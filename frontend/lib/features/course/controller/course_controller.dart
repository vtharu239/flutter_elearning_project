import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class CourseController extends GetxController {
  final RxString selectedCategory = 'all'.obs;
  final RxList<String> featuredCourses = <String>[].obs;
  
  void setCategory(String category) {
    selectedCategory.value = category;
  }
}