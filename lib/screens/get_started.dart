// import 'package:flutter/material.dart';
// import 'package:flutter_elearning_project/screens/auth/login_screen.dart';
// import 'package:flutter_elearning_project/theme/theme_provider.dart';
// import 'package:provider/provider.dart';

// class GetStartedScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         actions: [
//           // Thêm nút chuyển đổi theme
//           IconButton(
//             icon: Icon(
//               Provider.of<ThemeProvider>(context).isDarkMode 
//                 ? Icons.light_mode 
//                 : Icons.dark_mode,
//             ),
//             onPressed: () {
//               Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
//             },
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Spacer(),
//               Hero(
//                 tag: 'welcome_image',
//                 child: Image.asset('assets/welcome.png', height: 300),
//               ),
//               SizedBox(height: 40),
//               Text(
//                 'Học tập mọi lúc mọi nơi',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'Truy cập kho tài liệu học tập đa dạng và phong phú',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 16,
//                 ),
//               ),
//               Spacer(),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pushReplacement(
//                     context,
//                     PageRouteBuilder(
//                       pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
//                       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//                         return FadeTransition(opacity: animation, child: child);
//                       },
//                       transitionDuration: Duration(milliseconds: 500),
//                     ),
//                   );
//                 },
//                 child: Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.symmetric(vertical: 16),
//                   child: Text(
//                     'Bắt đầu',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 40),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }