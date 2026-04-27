import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class RatingBar extends StatelessWidget {
  final double rating;
  final double size;

  const RatingBar({super.key, required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        IconData icon;
        Color color;
        if (rating >= starValue) {
          icon = Icons.star;
          color = AppColors.ratingStar;
        } else if (rating >= starValue - 0.5) {
          icon = Icons.star_half;
          color = AppColors.ratingStar;
        } else {
          icon = Icons.star_border;
          color = AppColors.ratingStarEmpty;
        }
        return Icon(icon, size: size, color: color);
      }),
    );
  }
}
