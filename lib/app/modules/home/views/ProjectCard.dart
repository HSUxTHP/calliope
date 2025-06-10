import 'package:flutter/material.dart';

class ProjectCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String createdAt;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ProjectCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.createdAt,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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

            // ✅ Tên + menu 3 chấm
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tên project
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Nút 3 chấm
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'delete' && onDelete != null) {
                        onDelete!();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text("Xoá"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Created date
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Created: $createdAt",
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
