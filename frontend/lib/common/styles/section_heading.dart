import 'package:flutter/material.dart';

class TSectionHeading extends StatelessWidget {
  const TSectionHeading({
    super.key,
    required this.title,
    this.textColor,
    this.buttonTitle,
    this.showActionButton = true,
    this.onPressed,
  });

  final String title;
  final Color? textColor;
  final String?
      buttonTitle; // Cho phép null, dùng giá trị mặc định nếu không truyền vào
  final bool showActionButton;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.apply(color: textColor)
                .copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showActionButton)
          TextButton(
            onPressed: onPressed,
            child: Text(
              buttonTitle ?? "Xem tất cả",
              style: TextStyle(color: Color(0xFF00A2FF)),
            ), // Mặc định là "Xem tất cả" nếu không truyền vào
          ),
      ],
    );
  }
}
