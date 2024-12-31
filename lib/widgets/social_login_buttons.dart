import 'package:flutter/material.dart';

class SocialLoginButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Hoặc đăng nhập với'),
            ),
            Expanded(child: Divider()),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _SocialButton(
              icon: 'assets/google.png',
              label: 'Google',
              onPressed: () {
                // TODO: Implement Google sign in
              },
            ),
            _SocialButton(
              icon: 'assets/facebook.png',
              label: 'Facebook',
              onPressed: () {
                // TODO: Implement Facebook sign in
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Row(
        children: [
          Image.asset(icon, height: 24),
          SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}