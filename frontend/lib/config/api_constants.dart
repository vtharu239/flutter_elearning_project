class ApiConstants {
  static const String baseUrl =

      // -- Phuong
      'https://equipped-living-osprey.ngrok-free.app';

  // - Ngoc
  // 'https://clear-tomcat-informally.ngrok-free.app';

  // -- Xuan
  // 'https://resolved-sawfish-equally.ngrok-free.app';

  // API endpoints

  static const String imageBaseUrl = baseUrl; // Để load ảnh từ backend

  static const String auth = '/auth';
  static const String email = '/email';
  static const String password = '/password';

  static const String signupEndpoint = '/signup';
  static const String loginEndpoint = '/login';
  static const String checkUserEmailEndpoint = '/check-username-email';
  static const String sendConfirmationEndpoint = '/send-confirmation-email';
  static const String verifyEmail = '/verify-email';
  static const String verifyEmailEndpoint = '/verify-email-token';
  static const String sendOTP = '/send-otp';
  static const String verifyOTP = '/verify-otp';
  static const String resetPassword = '/reset-password';
  static const String getProfile = '/profile';
  static const String getAllCourse = '/getAllCourse';
  static const String getAllCategory = '/getAllCategory';
  static const String getAllTests = '/getAllTests';
  static const String getTest = '/getTest';
  static const String getTestDetail = '/getTestDetail';
  static const String addComment = '/addComment';

  // Headers mặc địnhs
  static Map<String, String> getHeaders({bool isImage = false}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      'Access-Control-Allow-Origin': '*',
    };
    if (isImage) {
      headers.remove('Content-Type'); // Không cần Content-Type cho ảnh
    }
    return headers;
  }

  // Hàm tiện ích để lấy full URL
  static String getUrl(String endpoint) => baseUrl + endpoint;
}
