import 'dart:io';
import 'package:flutter/material.dart';

class CustomImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const CustomImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (imagePath.startsWith('http')) {
      imageWidget = Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
      );
    } else {
      final file = File(imagePath);
      if (file.existsSync()) {
        imageWidget = Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildErrorPlaceholder(),
        );
      } else {
        imageWidget = _buildErrorPlaceholder();
      }
    }

    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: imageWidget,
      );
    }
    return imageWidget;
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }
}
