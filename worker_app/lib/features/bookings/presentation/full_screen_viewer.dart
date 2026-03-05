import 'package:flutter/material.dart';
import 'dart:io';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:worker_app/core/theme/app_colors.dart';

class FullScreenViewer extends StatelessWidget {
  final String imagePath;
  final String title;

  const FullScreenViewer({
    super.key,
    required this.imagePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFile = imagePath.contains('/') || imagePath.contains('\\');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Hero(
          tag: imagePath,
          child: isFile
              ? Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                )
              : const Icon(
                  LucideIcons.image,
                  color: AppColors.mutedFog,
                  size: 100,
                ),
        ),
      ),
    );
  }
}
