import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/features/authentication/screens/signup/verify_email.dart';
import 'package:flutter_elearning_project/features/authentication/screens/signup/widgets/terms_comditions_checkbox.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:flutter_elearning_project/utils/constants/text_strings.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TSignupForm extends StatelessWidget {
  TSignupForm({super.key});

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void register(BuildContext context) async {
    // Kiểm tra các trường dữ liệu
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneNoController.text.isEmpty ||
        passwordController.text.isEmpty) {
      showErrorDialog(context, 'Vui lòng nhập đầy đủ thông tin!');
      return;
    }

    final Map<String, String> userData = {
      "firstName": firstNameController.text,
      "lastName": lastNameController.text,
      "username": usernameController.text,
      "email": emailController.text,
      "phoneNo": phoneNoController.text,
      "password": passwordController.text,
    };

    final Uri url = Uri.parse('http://localhost:4000/signup');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        final email = responseBody['email'] as String?;

        // Navigate with proper null checking
        Get.to(
            () => VerifyEmailScreen(userEmail: email ?? emailController.text));
      } else {
        showErrorDialog(context, response.body);
      }
    } catch (e) {
      showErrorDialog(context, 'Lỗi kết nối đến server.');
    }
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: firstNameController,
                  decoration: const InputDecoration(
                      labelText: TTexts.firstName,
                      prefixIcon: Icon(Iconsax.user)),
                ),
              ),
              const SizedBox(width: TSizes.spaceBtwInputFields),
              Expanded(
                child: TextFormField(
                  controller: lastNameController,
                  decoration: const InputDecoration(
                      labelText: TTexts.lastName,
                      prefixIcon: Icon(Iconsax.user)),
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          TextFormField(
            controller: usernameController,
            decoration: const InputDecoration(
                labelText: TTexts.username,
                prefixIcon: Icon(Iconsax.user_edit)),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          TextFormField(
            controller: emailController,
            decoration: const InputDecoration(
                labelText: TTexts.email, prefixIcon: Icon(Iconsax.direct)),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          TextFormField(
            controller: phoneNoController,
            decoration: const InputDecoration(
                labelText: TTexts.phoneNo, prefixIcon: Icon(Iconsax.call)),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: TTexts.password,
              prefixIcon: Icon(Iconsax.password_check),
              suffixIcon: Icon(Iconsax.eye_slash),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          const TTermsAndConditionCheckbox(),
          const SizedBox(height: TSizes.spaceBtwSections),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => register(context),
              child: const Text(TTexts.createAccount),
            ),
          ),
        ],
      ),
    );
  }
}
