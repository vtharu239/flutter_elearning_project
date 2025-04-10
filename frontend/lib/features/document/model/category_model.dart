class Category {
  final String title;
  final List<String> subCategories;

  Category({required this.title, required this.subCategories});
}

final List<Category> categories = [
  Category(
    title: "Tìm hiểu về StudyMate",
    subCategories: ["Tính năng trên StudyMate", "Khóa học trên StudyMate"],
  ),
  Category(
    title: "Review của học viên StudyMate",
    subCategories: ["Học viên IELTS", "Học viên TOEIC"],
  ),
  Category(
    title: "Luyện thi IELTS",
    subCategories: [
      "IELTS Listening",
      "IELTS Reading",
      "IELTS Speaking",
      "IELTS Writing",
      "IELTS Materials",
      "Thông tin kỳ thi IELTS",
      "Kinh nghiệm thi IELTS",
      "The Reading Hub"
    ],
  ),
  Category(
    title: "Luyện thi TOEIC",
    subCategories: ["TOEIC Listening"],
  ),
];
