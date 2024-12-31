import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      image: 'assets/onboarding1.png',
      title: 'Học tập mọi lúc mọi nơi',
      description: 'Truy cập kho tài liệu học tập đa dạng và phong phú',
    ),
    OnboardingPage(
      image: 'assets/onboarding2.png',
      title: 'Theo dõi tiến độ',
      description: 'Dễ dàng theo dõi và đánh giá quá trình học tập của bạn',
    ),
    OnboardingPage(
      image: 'assets/onboarding3.png',
      title: 'Tương tác trực tiếp',
      description: 'Trao đổi với giáo viên và bạn học mọi lúc',
    ),
  ];

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300), // Thời gian thực hiện hiệu ứng chuyển trang
        curve: Curves.easeInOut, // Hiệu ứng chuyển động
      );
    } else { // Nếu đang ở trang cuối cùng
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // Điều hướng đến một màn hình mới và loại bỏ màn hình hiện tại khỏi ngăn xếp điều hướng (navigation stack)
      );
    }
  }

  void _onSkipPressed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack( // Cho phép chồng nhiều widget lên nhau theo trật tự lớp (layer). 
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return _pages[index];
            },
          ),
          Positioned( // Cố định widget con tại một vị trí cụ thể trong Stack
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _onSkipPressed,
              child: Text('Bỏ qua'),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(24.0),
              child: Column(
                children: [
                  SmoothPageIndicator( // Hiển thị chấm chỉ trang
                    controller: _pageController,
                    count: _pages.length,
                    effect: WormEffect( // Hiệu ứng động khi chuyển trang
                      dotHeight: 10,
                      dotWidth: 10,
                      type: WormType.thin,
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _onNextPressed,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Bắt đầu' : 'Tiếp tục',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0), // Giúp đặt khoảng cách (padding) đối xứng theo chiều ngang - thêm khoảng cách 24 pixel vào cả bên trái và bên phải của widget.
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Các widget con sẽ được căn giữa theo chiều dọc (Column)
        children: [
          Image.asset(image, height: 300),
          SizedBox(height: 40),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey[600]
                  : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}