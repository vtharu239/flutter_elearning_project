// ignore_for_file: file_names, unnecessary_to_list_in_spreads, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class CourseDetailScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const CourseDetailScreen({Key? key}) : super(key: key);

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
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
                    Tab(text: 'Đánh giá (680)'),
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

  Widget _buildPricingAndRegistration() {
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
                  // ignore: deprecated_member_use
                  color: Colors.grey.withOpacity(0.1),
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      '2.925.000đ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '5.346.000đ',
                      style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-45%',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {},
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
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Học thử miễn phí'),
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

  Widget _buildHeader() {
    // Previous header implementation remains the same
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Combo Advanced IELTS Intensive kèm chấm chữa giáo viên bản ngữ [Tặng TED Talks]',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '#Phần mềm online',
                  style: TextStyle(color: Colors.blue),
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
        const Text(
          '4.9',
          style: TextStyle(
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
              color: index < 4 ? Colors.amber : Colors.amber.shade200,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '(680 Đánh giá)',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          '107,333 Học viên',
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildCourseObjectives() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bạn sẽ đạt được gì sau khóa học?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildObjectiveItem(
            '1',
            'Xây dựng vốn từ vựng học thuật 99% sẽ xuất hiện trong 2 phần thi Listening và Reading',
          ),
          _buildObjectiveItem(
            '2',
            'Làm chủ tốc độ và các ngữ điệu khác nhau trong phần thi IELTS Listening',
          ),
          _buildObjectiveItem(
            '3',
            'Nắm chắc chiến thuật và phương pháp làm các dạng câu hỏi trong IELTS Listening và Reading',
          ),
          _buildObjectiveItem(
            '4',
            'Xây dựng ý tưởng viết luận, kỹ năng viết câu, bố cục các đoạn, liên kết ý và vốn từ vựng phong phú cho các chủ đề trong IELTS Writing',
          ),
          _buildObjectiveItem(
            '5',
            'Luyện tập phát âm, từ vựng, ngữ pháp và thực hành luyện nói các chủ đề thường gặp và forecast trong IELTS Speaking',
          ),
          _buildObjectiveItem(
            '6',
            'Được chấm chữa chi tiết (gồm điểm và nhận xét thành phần trong rubic) xác định được điểm yếu và cách khắc phục trong IELTS Speaking và Writing',
          ),
        ],
      ),
    );
  }

  Widget _buildCourseInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                _buildTeacherInfo(
                  'Ms. Phuong Nguyen',
                  'Macalester College, USA. TOEFL 114, IELTS 8.0, SAT 2280, GRE Verbal 165/170',
                ),
                const SizedBox(height: 8),
                _buildTeacherInfo(
                  'Ms. Uyen Tran',
                  'FTU. IELTS 8.0 (Listening 8.5, Reading 8.5)',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildCourseStats(),
        ],
      ),
    );
  }

  Widget _buildCourseCurriculum() {
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
          _buildCourseCard(
            courseNumber: '1',
            title:
                '[IELTS Intensive Listening] Chiến lược làm bài - Chữa đề - Luyện nghe IELTS Listening theo phương pháp Dictation',
            rating: 4.9,
            reviews: 222,
            students: 30506,
            features: [
              'Dành cho các bạn band 4.0+ đang target band 7.0+ IELTS Listening',
              'Giải quyết triệt để các vấn đề thường gặp khi nghe IELTS như miss thông tin, âm nối, tốc độ nói nhanh, ngữ điệu khó bằng phần mềm luyện nghe chép chính tả',
              'Hướng dẫn chi tiết phương pháp làm từng dạng bài trong IELTS Listening',
              'Luyện đề và thống kê kết quả theo từng part, từng dạng câu hỏi hàng ngày'
            ],
          ),
          const SizedBox(height: 16),
          _buildCourseCard(
            courseNumber: '2',
            title:
                '[IELTS Intensive Reading] Chiến lược làm bài - Chữa đề - Từ vựng IELTS Reading',
            rating: 4.9,
            reviews: 136,
            students: 32536,
            features: [
              'Dành cho các bạn từ band 4.0 trở lên target 7.0+ IELTS Reading',
              'Nắm trọn 4000 từ vựng có xác suất 99% sẽ xuất hiện trong phần thi IELTS Reading và Listening tổng hợp từ đề thi thật',
              'Hướng dẫn chi tiết phương pháp làm từng dạng câu hỏi trong IELTS Reading',
              'Luyện đề và thống kê kết quả theo từng part, từng dạng câu hỏi hàng ngày'
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard({
    required String courseNumber,
    required String title,
    required double rating,
    required int reviews,
    required int students,
    required List<String> features,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    const Text(
                      'KHÓA HỌC',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      courseNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                rating.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    size: 16,
                    color: index < rating.floor()
                        ? Colors.amber
                        : (index < rating
                            ? Colors.amber.shade200
                            : Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '($reviews Đánh giá)',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$students Học viên',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...features
              .map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ignore: duplicate_ignore
                        // ignore: prefer_const_constructors
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildReviews() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewStats(),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _buildReviewCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherInfo(String name, String credentials) {
    return Row(
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
          _buildStatItem(Icons.people, '107,333 học viên đã đăng ký'),
          _buildStatItem(Icons.book, '97 chủ đề, 1,127 bài học'),
          _buildStatItem(Icons.assignment, '2,546 bài tập thực hành'),
          _buildStatItem(
              Icons.access_time, 'Combo 5 khóa học có giá trị 12 tháng'),
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

  Widget _buildReviewCard() {
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Khánh Phương',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '17, THPT Chuyên Phan Bội Châu',
                      style: TextStyle(
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
          const Text(
            'Khóa IELTS Intensive Speaking giúp mình cải thiện rõ rệt khả năng phát âm, luyện lấy, stress và xây dựng vốn từ vựng cho các chủ đề thường gặp trong bài thi nói...',
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStats() {
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
                    const Text(
                      '107,333',
                      style: TextStyle(
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
                    const Text(
                      '680',
                      style: TextStyle(
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
                    const Text(
                      '4.9',
                      style: TextStyle(
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
        const SizedBox(height: 24),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
      ],
    );
  }

  Widget _buildRatingBars() {
    final ratings = [
      {'stars': 5, 'count': 580, 'percentage': 0.85},
      {'stars': 4, 'count': 75, 'percentage': 0.11},
      {'stars': 3, 'count': 15, 'percentage': 0.02},
      {'stars': 2, 'count': 7, 'percentage': 0.01},
      {'stars': 1, 'count': 3, 'percentage': 0.01},
    ];

    return Column(
      children: ratings.map((rating) {
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
