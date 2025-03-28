import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/config/api_constants.dart';
import 'package:flutter_elearning_project/features/course/controller/CourseCurriculumItem.dart';
import 'package:flutter_elearning_project/features/course/controller/PaymentService.dart';
import 'package:flutter_elearning_project/features/course/controller/PaymentWebView.dart';
import 'package:flutter_elearning_project/features/course/controller/course_model.dart';
import 'package:flutter_elearning_project/features/course/controller/course_controller.dart';
import 'package:flutter_elearning_project/features/course/controller/course_objective.dart';
import 'package:flutter_elearning_project/features/course/controller/course_rating_stat.dart';
import 'package:flutter_elearning_project/features/course/controller/course_review.dart';
import 'package:flutter_elearning_project/features/course/controller/course_teacher.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Thêm thư viện

class CourseDetailScreen extends StatefulWidget {
  final int courseId;
  final bool? paymentSuccess;
  const CourseDetailScreen(
      {super.key, required this.courseId, this.paymentSuccess});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CourseController courseController;
  Course? courseData;
  List<CourseObjective> objectives = [];
  List<CourseTeacher> teachers = [];
  List<CourseCurriculumItem> curriculumItems = [];
  List<CourseReview> reviews = [];
  RatingStats? ratingStats;

  bool isLoading = true;
  bool isLoadingObjectives = true;
  bool isLoadingTeachers = true;
  bool isLoadingCurriculum = true;
  bool isLoadingReviews = true;
  bool isLoadingRatingStats = true;
  bool hasPurchased = false;

  List<bool> _expandedItems = [];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    courseController = Get.find<CourseController>();
    // Khởi tạo hasPurchased từ SharedPreferences
    _loadPurchaseStatus();
    // Fetch dữ liệu khóa học
    fetchCourseDetail().then((_) {
      fetchCourseObjectives();
      fetchCourseTeachers();
      fetchCourseCurriculum();
      fetchCourseReviews();
      fetchCourseRatingStats();
    });
  }

  // Hàm load trạng thái đã mua từ SharedPreferences
  Future<void> _loadPurchaseStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      hasPurchased = prefs.getBool('hasPurchased_${widget.courseId}') ?? false;
    });
  }

  // Hàm lưu trạng thái đã mua vào SharedPreferences
  Future<void> _savePurchaseStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasPurchased_${widget.courseId}', value);
    setState(() {
      hasPurchased = value;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void showErrorSnackbar(String message) {
    if (mounted) {
      // Kiểm tra mounted để tránh lỗi liên quan đến BuildContext
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red, // Tùy chọn: thêm màu để nổi bật lỗi
        ),
      );
    }
  }

  Future<void> fetchCourseDetail() async {
    try {
      setState(() => isLoading = true);

      final existingCourse = courseController.allCourses
          .firstWhereOrNull((course) => course.id == widget.courseId);

      if (existingCourse != null) {
        setState(() {
          courseData = existingCourse;
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.getCourseById}/${widget.courseId}'),
        headers: ApiConstants.getHeaders(),
      );

      if (response.statusCode == 200) {
        setState(() {
          courseData = Course.fromJson(jsonDecode(response.body));
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load course detail: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        // Kiểm tra mounted trước khi sử dụng context
        showErrorSnackbar('Error loading course: $e');
      }
    }
  }

  Future<void> fetchCourseObjectives() async {
    try {
      setState(() => isLoadingObjectives = true);

      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.courseObjectives}/${widget.courseId}'),
        headers: ApiConstants.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          objectives =
              data.map((json) => CourseObjective.fromJson(json)).toList();
          isLoadingObjectives = false;
        });
      } else {
        throw Exception(
            'Failed to load course objectives: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoadingObjectives = false);
      if (mounted) {
        // Kiểm tra mounted
        showErrorSnackbar('Error loading course objectives: $e');
      }
    }
  }

  Future<void> fetchCourseTeachers() async {
    try {
      setState(() => isLoadingTeachers = true);

      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.courseTeachers}/${widget.courseId}'),
        headers: ApiConstants.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          teachers = data.map((json) => CourseTeacher.fromJson(json)).toList();
          isLoadingTeachers = false;
        });
      } else {
        throw Exception(
            'Failed to load course teachers: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoadingTeachers = false);
      if (mounted) {
        // Kiểm tra mounted
        showErrorSnackbar('Error loading course teachers: $e');
      }
    }
  }

  Future<void> fetchCourseCurriculum() async {
    try {
      setState(() => isLoadingCurriculum = true);

      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.courseCurriculum}/${widget.courseId}'),
        headers: ApiConstants.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          curriculumItems =
              data.map((json) => CourseCurriculumItem.fromJson(json)).toList();
          _expandedItems = List<bool>.filled(curriculumItems.length, false);
          isLoadingCurriculum = false;
        });
      } else {
        throw Exception(
            'Failed to load course curriculum: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() => isLoadingCurriculum = false);
      log('Error loading course curriculum: $e');
      if (mounted) {
        // Kiểm tra mounted
        showErrorSnackbar('Error loading course curriculum: $e');
      }
    }
  }

  Widget _buildCourseCurriculum() {
    if (isLoadingCurriculum) {
      return const Center(child: CircularProgressIndicator());
    }

    if (curriculumItems.isEmpty) {
      return const Center(
          child: Text('Chưa có dữ liệu chương trình học cho khóa học này.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chương trình học',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...curriculumItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildCurriculumItem(index, item);
          }),
        ],
      ),
    );
  }

  Widget _buildCurriculumItem(int index, CourseCurriculumItem item) {
    return ExpansionTile(
      title: Row(
        children: [
          Expanded(
            child: Text(
              item.section,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            '${item.lessonCount} bài',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          if (!hasPurchased)
            const Icon(
              Icons.lock,
              size: 20,
              color: Colors.grey,
            ),
        ],
      ),
      onExpansionChanged: (expanded) {
        if (!hasPurchased && expanded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vui lòng mua khóa học để xem toàn bộ nội dung!'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        setState(() {
          _expandedItems[index] = expanded;
        });
      },
      children: item.lessons.map((lesson) {
        final hasSubItems = lesson.subItems.isNotEmpty;
        return ExpansionTile(
          title: Row(
            children: [
              Icon(
                hasSubItems ? Icons.star : Icons.check_circle,
                color: hasSubItems ? Colors.amber : Colors.green,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  lesson.lesson,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        hasSubItems ? FontWeight.bold : FontWeight.normal,
                    color: hasSubItems ? Colors.blue : Colors.black,
                  ),
                ),
              ),
              if (!hasSubItems)
                ElevatedButton(
                  onPressed: () {
                    _startLessonPreview(lesson.lesson);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    'Học thử',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),
          children: hasSubItems
              ? lesson.subItems.map((subItem) {
                  final hasVocabularyWords = subItem.vocabularyWords.isNotEmpty;
                  return ExpansionTile(
                    title: Row(
                      children: [
                        const Icon(
                          Icons.arrow_right,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            subItem.name,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        if (!hasVocabularyWords)
                          ElevatedButton(
                            onPressed: () {
                              _startLessonPreview(subItem.name);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                            child: const Text(
                              'Học thử',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                    children: hasVocabularyWords
                        ? subItem.vocabularyWords
                            .map((word) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 48, vertical: 8),
                                  child: ExpansionTile(
                                    title: Text(
                                      word.word,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (word.pronunciationUK != null &&
                                                word.pronunciationUK!
                                                    .isNotEmpty)
                                              Text(
                                                'UK: ${word.pronunciationUK}',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey),
                                              ),
                                            if (word.pronunciationUS != null &&
                                                word.pronunciationUS!
                                                    .isNotEmpty)
                                              Text(
                                                'US: ${word.pronunciationUS}',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey),
                                              ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Định nghĩa: ${word.definition}',
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                            if (word.explanation != null &&
                                                word.explanation!.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8),
                                                child: Text(
                                                  'Giải thích: ${word.explanation}',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Ví dụ:',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            ...word.examples.map((example) =>
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 4),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        '- ${example.sentence}',
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                      Text(
                                                        '  Dịch: ${example.translation}',
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey),
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                            const SizedBox(height: 8),
                                            ElevatedButton(
                                              onPressed: () {
                                                _startLessonPreview(word.word);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8),
                                              ),
                                              child: const Text(
                                                'Học thử',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList()
                        : [],
                  );
                }).toList()
              : [],
        );
      }).toList(),
    );
  }

  void _startLessonPreview(String lessonName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang mở bài học thử: $lessonName...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> fetchCourseReviews() async {
    try {
      setState(() => isLoadingReviews = true);

      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.courseReviews}/${widget.courseId}'),
        headers: ApiConstants.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          reviews = data.map((json) => CourseReview.fromJson(json)).toList();
          isLoadingReviews = false;
        });
      } else {
        throw Exception(
            'Failed to load course reviews: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoadingReviews = false);
      if (mounted) {
        // Kiểm tra mounted
        showErrorSnackbar('Error loading course reviews: $e');
      }
    }
  }

  Future<void> fetchCourseRatingStats() async {
    try {
      setState(() => isLoadingRatingStats = true);

      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.courseRatingStats}/${widget.courseId}'),
        headers: ApiConstants.getHeaders(),
      );

      if (response.statusCode == 200) {
        setState(() {
          ratingStats = RatingStats.fromJson(jsonDecode(response.body));
          isLoadingRatingStats = false;
        });
      } else {
        throw Exception('Failed to load rating stats: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoadingRatingStats = false);
      if (mounted) {
        // Kiểm tra mounted
        showErrorSnackbar('Error loading rating stats: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: _buildHeader(),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        labelColor: Colors.blue,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.blue,
                        tabs: const [
                          Tab(text: 'Giá & Đăng ký'),
                          Tab(text: 'Mục tiêu khóa học'),
                          Tab(text: 'Thông tin khóa học'),
                          Tab(text: 'Chương trình học'),
                          Tab(text: 'Đánh giá'),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildPricingAndRegistration(),
                  _buildCourseObjectives(),
                  _buildCourseInfo(),
                  _buildCourseCurriculum(),
                  _buildReviews(),
                ],
              ),
            ),
    );
  }

  Widget _buildCourseObjectives() {
    if (isLoadingObjectives) {
      return const Center(child: CircularProgressIndicator());
    }

    if (objectives.isEmpty) {
      return const Center(
          child:
              Text('Không có mục tiêu nào được định nghĩa cho khóa học này.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bạn sẽ đạt được gì sau khóa học?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...objectives.asMap().entries.map((entry) {
            final index = entry.key;
            final objective = entry.value;
            return _buildObjectiveItem(
              (index + 1).toString(),
              objective.description,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildObjectiveItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            courseData?.title ?? 'Loading...',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '#${courseData?.categoryName ?? 'Phần mềm online'}',
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRatingBar(),
        ],
      ),
    );
  }

  Widget _buildRatingBar() {
    return Row(
      children: [
        Text(
          courseData?.rating.toString() ?? '0',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Row(
          children: List.generate(
            5,
            (index) => Icon(
              Icons.star,
              color: index < (courseData?.rating ?? 0).floor()
                  ? Colors.amber
                  : Colors.amber.shade200,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '(${courseData?.ratingCount ?? 0} Đánh giá)',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(width: 16),
        Text(
          '${courseData?.studentCount ?? 0} Học viên',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildPricingAndRegistration() {
    final discountedPrice = courseData?.originalPrice != null
        ? courseData!.originalPrice *
            (1 - (courseData!.discountPercentage / 100))
        : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ưu đãi đặc biệt tháng 2/2025:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      '${discountedPrice.toStringAsFixed(0)}đ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${courseData?.originalPrice.toStringAsFixed(0)}đ',
                      style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-${courseData?.discountPercentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                hasPurchased
                    ? ElevatedButton(
                        onPressed: () {
                          _startLearning();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text(
                          'Học ngay',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _showCourseRegistrationDialog();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            child: const Text(
                              'ĐĂNG KÝ HỌC NGAY',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () {
                              _startFreeTrial();
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            child: const Text('Học thử miễn phí'),
                          ),
                        ],
                      ),
                const SizedBox(height: 24),
                _buildCourseStats(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Chưa chắc chắn khóa học này dành cho bạn? ',
                      style: TextStyle(color: Colors.grey[700]),
                    )
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Liên hệ để nhận tư vấn miễn phí!'),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startLearning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang mở khóa học ${courseData?.title}...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _processPurchase() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Dialog(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text('Đang tạo thanh toán...'),
                ],
              ),
            ),
          );
        },
      );

      final PaymentService paymentService = PaymentService();
      final discountedPrice = courseData?.originalPrice != null
          ? courseData!.originalPrice *
              (1 - (courseData!.discountPercentage / 100))
          : 0.0;

      final paymentResult = await paymentService.createPayment(
        courseId: courseData!.id,
        amount: discountedPrice,
        orderDescription: 'Thanh toán khóa học: ${courseData!.title}',
      );

      if (mounted) {
        // Kiểm tra mounted trước khi sử dụng Navigator
        Navigator.of(context).pop();
      }

      if (paymentResult['success'] == true &&
          paymentResult['paymentUrl'] != null) {
        final orderId = paymentResult['orderId'];

        if (mounted) {
          // Kiểm tra mounted trước khi push Navigator
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PaymentWebView(
                paymentUrl: paymentResult['paymentUrl'],
                orderId: orderId,
                courseId: widget.courseId,
                onPaymentComplete: (success) {
                  _handlePaymentComplete(success, orderId);
                },
              ),
            ),
          );
        }
      } else if (mounted) {
        // Kiểm tra mounted trước khi sử dụng ScaffoldMessenger
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Không thể tạo thanh toán: ${paymentResult['message'] ?? 'Đã xảy ra lỗi'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Kiểm tra mounted trước khi sử dụng Navigator và ScaffoldMessenger
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handlePaymentComplete(bool success, int orderId) async {
    try {
      if (success) {
        await _savePurchaseStatus(true); // Lưu trạng thái đã mua
        if (mounted) {
          // Kiểm tra mounted
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Thanh toán thành công! Bạn đã đăng ký khóa học này.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else if (mounted) {
        // Kiểm tra mounted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn đã hủy thanh toán.'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Kiểm tra mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xác thực thanh toán: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCourseRegistrationDialog() {
    final discountedPrice = courseData?.originalPrice != null
        ? courseData!.originalPrice *
            (1 - (courseData!.discountPercentage / 100))
        : 0.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[700],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Thông tin khóa học',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          courseData?.title ?? 'Khóa học',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              courseData?.rating.toString() ?? '0',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: List.generate(
                                5,
                                (index) => Icon(
                                  Icons.star,
                                  color:
                                      index < (courseData?.rating ?? 0).floor()
                                          ? Colors.amber
                                          : Colors.amber.shade200,
                                  size: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${courseData?.ratingCount ?? 0} Đánh giá)',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        if (!isLoadingObjectives && objectives.isNotEmpty) ...[
                          const Text(
                            'Mục tiêu khóa học:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...objectives.take(3).map((objective) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.check_circle,
                                        color: Colors.green, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        objective.description,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          if (objectives.length > 3)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '...và ${objectives.length - 3} mục tiêu khác',
                                style: TextStyle(
                                    color: Colors.blue[700],
                                    fontStyle: FontStyle.italic),
                              ),
                            ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                        ],
                        if (!isLoadingTeachers && teachers.isNotEmpty) ...[
                          const Text(
                            'Giảng viên:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...teachers.take(2).map((teacher) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.person, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${teacher.name}, ${teacher.credentials}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                        ],
                        const Text(
                          'Bạn sẽ nhận được:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildStatItem(Icons.book,
                            '${courseData?.topics ?? 0} chủ đề, ${courseData?.lessons ?? 0} bài học'),
                        _buildStatItem(Icons.assignment,
                            '${courseData?.exercises ?? 0} bài tập thực hành'),
                        _buildStatItem(Icons.access_time,
                            'Truy cập ${courseData?.validity ?? 12} tháng'),
                        _buildStatItem(
                            Icons.devices, 'Học trên điện thoại và máy tính'),
                        _buildStatItem(
                            Icons.support_agent, 'Hỗ trợ trực tuyến 24/7'),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              '${discountedPrice.toStringAsFixed(0)}đ',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${courseData?.originalPrice.toStringAsFixed(0)}đ',
                              style: TextStyle(
                                fontSize: 16,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '-${courseData?.discountPercentage.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ưu đãi này còn hiệu lực trong 2 ngày',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      if (!hasPurchased) ...[
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _processPurchase();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: const Text(
                            'MUA KHÓA HỌC NGAY',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _startFreeTrial();
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: const Text('HỌC THỬ MIỄN PHÍ'),
                        ),
                      ] else ...[
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _startLearning();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: const Text(
                            'Học ngay',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startFreeTrial() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đang chuẩn bị bài học thử...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildCourseStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildStatItem(Icons.people,
              '${courseData?.studentCount ?? 0} học viên đã đăng ký'),
          _buildStatItem(Icons.book,
              '${courseData?.topics ?? 0} chủ đề, ${courseData?.lessons ?? 0} bài học'),
          _buildStatItem(Icons.assignment,
              '${courseData?.exercises ?? 0} bài tập thực hành'),
          _buildStatItem(Icons.access_time,
              'Combo 5 khóa học có giá trị ${courseData?.validity ?? 12} tháng'),
          _buildStatItem(
              Icons.devices, 'Có thể học trên điện thoại và máy tính'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildCourseInfo() {
    if (isLoadingTeachers) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            courseData?.description ?? 'Không có mô tả',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          if (teachers.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bài học được biên soạn và giảng dạy bởi:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...teachers.map((teacher) => _buildTeacherInfo(
                        teacher.name,
                        teacher.credentials,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          _buildCourseStats(),
        ],
      ),
    );
  }

  Widget _buildTeacherInfo(String name, String credentials) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.person, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: '$name, ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: credentials),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviews() {
    if (isLoadingReviews || isLoadingRatingStats) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reviews.isEmpty || ratingStats == null) {
      return const Center(
          child: Text('Chưa có đánh giá nào cho khóa học này.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewStats(),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Tất cả đánh giá',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text('Mới nhất'),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reviews.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _buildReviewCard(reviews[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(CourseReview review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                child: const Icon(Icons.person),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      review.userInfo,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: const TextStyle(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStats() {
    if (ratingStats == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.groups_outlined, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '${ratingStats!.totalStudents}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Text('Học viên'),
              ],
            ),
            const SizedBox(width: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.rate_review_outlined, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '${ratingStats!.totalReviews}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Text('Nhận xét'),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      ratingStats!.averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.star, color: Colors.amber[400], size: 24),
                  ],
                ),
                const Text('Đánh giá trung bình'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildRatingBars(),
      ],
    );
  }

  Widget _buildRatingBars() {
    if (ratingStats == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: ratingStats!.ratingDistribution.map((rating) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '${rating['stars']}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(Icons.star, color: Colors.amber[400], size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: rating['percentage'] as double,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.amber[400],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text(
                  '${rating['count']}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
