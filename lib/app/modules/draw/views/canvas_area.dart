import 'package:flutter/material.dart';
import 'DrawingCanvas.dart';

class CanvasArea extends StatelessWidget {
  const CanvasArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24), // 👈 thêm bo tròn
        child: Container(
          width: 1050,
          height: 590.625,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface, // 👈 phụ thuộc theme
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const DrawingCanvas(),
        ),
      ),
    );
  }
}
