import 'package:get/get.dart';

class PracticeTestController extends GetxController {
  final selectedCategory = 'all'.obs;
  final selectedSort = 'newest'.obs;
  final selectedFilters = <String>{}.obs;
  final bookmarkedTests = <String>{}.obs;

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  void toggleFilter(String filter) {
    if (selectedFilters.contains(filter)) {
      selectedFilters.remove(filter);
    } else {
      selectedFilters.add(filter);
    }
  }

  bool isBookmarked(String testId) => bookmarkedTests.contains(testId);

  void toggleBookmark(String testId) {
    if (bookmarkedTests.contains(testId)) {
      bookmarkedTests.remove(testId);
    } else {
      bookmarkedTests.add(testId);
    }
  }
}
