import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';

// Price Widget
class CoursePrice extends StatelessWidget {
  final double originalPrice;
  final double? discountPrice;
  final int? discountPercentage;

  const CoursePrice({
    super.key,
    required this.originalPrice,
    this.discountPrice,
    this.discountPercentage,
  });

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: TSizes.sm,
          runSpacing: TSizes.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (discountPrice != null) ...[
              Text(
                '${formatPrice(discountPrice!)} VNĐ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: darkMode ? Colors.green[200] : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              // Kiểm tra kích thước để quyết định layout
              constraints.maxWidth > 200
                  ? // Có thể điều chỉnh số 200 theo nhu cầu
                  Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${formatPrice(originalPrice)} VNĐ',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                  ),
                        ),
                        if (discountPercentage != null) ...[
                          const SizedBox(width: TSizes.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: TSizes.sm,
                              vertical: TSizes.xs,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(TSizes.sm),
                            ),
                            child: Text(
                              '-$discountPercentage%',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.red),
                            ),
                          ),
                        ],
                      ],
                    )
                  : // Nếu màn hình nhỏ, hiển thị từng phần tử riêng
                  Wrap(
                      spacing: TSizes.sm,
                      runSpacing: TSizes.xs,
                      children: [
                        Text(
                          '${formatPrice(originalPrice)} VNĐ',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                  ),
                        ),
                        if (discountPercentage != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: TSizes.sm,
                              vertical: TSizes.xs,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(TSizes.sm),
                            ),
                            child: Text(
                              '-$discountPercentage%',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.red),
                            ),
                          ),
                      ],
                    ),
            ] else
              Text(
                '${formatPrice(originalPrice)} VNĐ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
              ),
          ],
        );
      },
    );
  }

// Hàm tiện ích để định dạng số
  String formatPrice(double price) {
    // Chuyển số thành chuỗi và tách phần nguyên
    String priceStr = price.toStringAsFixed(0);

    // Thêm dấu chấm phân cách mỗi 3 chữ số từ phải qua
    String result = '';
    int count = 0;

    for (int i = priceStr.length - 1; i >= 0; i--) {
      if (count == 3 && i != 0) {
        result = '.$result';
        count = 0;
      }
      result = priceStr[i] + result;
      count++;
    }

    return result;
  }
}
