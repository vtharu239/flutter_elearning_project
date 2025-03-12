class ApiConstants {
  static const String baseUrl =

      // -- Phuong
      // 'https://equipped-living-osprey.ngrok-free.app';

  // - Ngoc
  // 'https://clear-tomcat-informally.ngrok-free.app';

  // -- Xuan
  'https://resolved-sawfish-equally.ngrok-free.app';

  // API endpoints

  static const String imageBaseUrl = baseUrl; // Để load ảnh từ backend

  static const String signupEmail = '/signup/email';
  static const String signupPhone = '/signup/phone';
  static const String verifyOtpSetPassword = '/verify-otp-set-password';
  static const String login = '/login';
  static const String socialLogin = '/social-login';
  
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
  
  static const String initiatePhoneChange = '/profile/initiate-phone-change';
  static const String completePhoneChange = '/profile/complete-phone-change';
  static const String unlinkPhone = '/profile/unlink-phone';

  static const String initiateEmailChange = '/profile/initiate-email-change';
  static const String completeEmailChange = '/profile/complete-email-change';
  static const String unlinkEmail = '/profile/unlink-email';

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
