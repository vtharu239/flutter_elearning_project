class ApiConstants {
  static const String baseUrl =

      // - Ngoc
      'https://clear-tomcat-informally.ngrok-free.app';

  // -- Xuan
  // 'https://resolved-sawfish-equally.ngrok-free.app';

  // API endpoints
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
  // Headers mặc địnhs
  static Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      'Access-Control-Allow-Origin': '*',
    };
  }

  // Hàm tiện ích để lấy full URL
  static String getUrl(String endpoint) => baseUrl + endpoint;
}
