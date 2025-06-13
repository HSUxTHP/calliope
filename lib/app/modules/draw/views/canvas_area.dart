import 'package:flutter/material.dart';
import 'DrawingCanvas.dart';

class CanvasArea extends StatelessWidget {
  const CanvasArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        child: Container(
          width: 1050,
          height: 590.625,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
            // 👉 Nếu muốn có hình gợi ý để người dùng vẽ khớp khung:
            // image: DecorationImage(
            //   image: AssetImage('assets/guide_frame.png'),
            //   fit: BoxFit.cover,
            // ),
          ),
          child: const DrawingCanvas(),
        ),
      ),
    );
  }
}
