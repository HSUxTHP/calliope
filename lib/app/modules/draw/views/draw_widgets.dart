import 'dart:typed_data';
import 'package:flutter/material.dart';

Widget iconButton(IconData icon, VoidCallback onPressed,
    {String? tooltip, Color? color}) {
  return IconButton(
    icon: Icon(icon, size: 20, color: color ?? Colors.black),
    tooltip: tooltip,
    onPressed: onPressed,
  );
}

Widget roundedControl({
  required String label,
  required VoidCallback onMinus,
  required VoidCallback onPlus,
  Widget? trailing,
}) {
  return Container(
    height: 34,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: Colors.grey,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.black),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onMinus,
          child: const CircleAvatar(
            radius: 9,
            backgroundColor: Color(0xFFFFFFFF),
            child: Icon(Icons.remove, size: 12, color: Colors.black),
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black)),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onPlus,
          child: const CircleAvatar(
            radius: 9,
            backgroundColor: Color(0xFFFFFFFF),
            child: Icon(Icons.add, size: 12, color: Colors.black),
          ),
        ),
        if (trailing != null) trailing,
      ],
    ),
  );
}

class ThumbnailItem extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final Future<Uint8List> futureImage;
  final Color borderColor;
  final bool? isHidden;
  final VoidCallback? onToggleVisibility;

  const ThumbnailItem({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.futureImage,
    required this.borderColor,
    this.isHidden,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? borderColor.withOpacity(0.05) : Colors.white,
              border: Border.all(
                color: isSelected ? borderColor : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: FutureBuilder<Uint8List>(
              future: futureImage,
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Opacity(
                      opacity: isHidden == true ? 0.4 : 1.0,
                      child: Image.memory(snapshot.data!, fit: BoxFit.cover),
                    ),
                  );
                }
                return const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 1.2)),
                );
              },
            ),
          ),
          if (onToggleVisibility != null)
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                onTap: onToggleVisibility,
                child: Icon(
                  isHidden == true ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                  color: Colors.black54,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
