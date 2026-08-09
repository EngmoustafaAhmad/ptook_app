import 'package:flutter/material.dart';
import 'package:ptook/core/Theme/app_colors.dart';

class HeaderImage extends StatelessWidget {
  final String? imageUrl;

  const HeaderImage({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) return const SizedBox();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.surface,
            child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
          ),
        ),
      ),
    );
  }
}