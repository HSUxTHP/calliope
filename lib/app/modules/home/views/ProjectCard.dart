import 'package:flutter/material.dart';

class ProjectCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String createdAt;
  final VoidCallback? onTap; // ✅ THÊM DÒNG NÀY

  const ProjectCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.createdAt,
    this.onTap, // ✅ THÊM VÀO CONSTRUCTOR
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // ✅ ÁP DỤNG onTap
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(imageUrl, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(title, style: Theme.of(context).textTheme.titleMedium),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text("Created: $createdAt", style: Theme.of(context).textTheme.bodySmall),
            ),
          ],
        ),
      ),
    );
  }
}
