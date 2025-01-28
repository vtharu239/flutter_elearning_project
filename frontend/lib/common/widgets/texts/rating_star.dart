import 'package:flutter/material.dart';
import 'package:flutter_elearning_project/utils/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

// Rating Widget
class RatingStars extends StatelessWidget {
  final double rating;
  final int ratingCount;
  final double size;

  const RatingStars({
    super.key,
    required this.rating,
    required this.ratingCount,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            if (index < rating.floor()) {
              return Icon(Iconsax.star1, size: size, color: Colors.amber);
            } else if (index == rating.floor() && rating % 1 != 0) {
              return Icon(Iconsax.star1, size: size, color: Colors.grey[300]);
            }
            return Icon(Iconsax.star1, size: size, color: Colors.grey[300]);
          }),
        ),
        const SizedBox(width: TSizes.xs),
        Text(rating.toString()),
        const SizedBox(width: TSizes.xs),
        Text('($ratingCount)', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}