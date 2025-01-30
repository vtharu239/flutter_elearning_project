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
  final String? buttonTitle; // Cho phép null, dùng giá trị mặc định nếu không truyền vào
  final bool showActionButton;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.apply(color: textColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (showActionButton)
          TextButton(
            onPressed: onPressed,
            child: Text(buttonTitle ?? "Xem tất cả"), // Mặc định là "Xem tất cả" nếu không truyền vào
          ),
      ],
    );
  }
}
