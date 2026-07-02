import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final int rating;
  final Function(int) onChanged;
  final int maxStars;

  const RatingStars({
    super.key,
    required this.rating,
    required this.onChanged,
    this.maxStars = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxStars, (index) {
        final starIndex = index + 1;
        return IconButton(
          onPressed: () => onChanged(starIndex),
          iconSize: 40,
          icon: Icon(
            starIndex <= rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
          ),
        );
      }),
    );
  }
}
