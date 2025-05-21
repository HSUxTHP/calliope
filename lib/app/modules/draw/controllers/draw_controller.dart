import 'package:get/get.dart';
import 'package:flutter/material.dart';

class DrawController extends GetxController {
  final lines = <DrawnLine>[].obs;
  final undoneLines = <DrawnLine>[].obs;
  final selectedColor = Colors.black.obs;
  final selectedWidth = 4.0.obs;

  void addLine(DrawnLine line) {
    lines.add(line);
    undoneLines.clear(); // xóa redo khi vẽ mới
  }

  void clear() {
    lines.clear();
    undoneLines.clear();
  }

  void undo() {
    if (lines.isNotEmpty) {
      undoneLines.add(lines.removeLast());
    }
  }

  void redo() {
    if (undoneLines.isNotEmpty) {
      lines.add(undoneLines.removeLast());
    }
  }
}

class DrawnLine {
  final List<Offset> points;
  final Color color;
  final double width;

  DrawnLine({
    required this.points,
    required this.color,
    required this.width,
  });
}
