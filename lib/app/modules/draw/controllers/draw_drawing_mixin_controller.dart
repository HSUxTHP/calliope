import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../data/models/DrawnLine_model.dart';

mixin DrawDrawingMixin on GetxController {
  final lines = <DrawnLine>[].obs;
  final undoStack = <List<DrawnLine>>[];
  final redoStack = <List<DrawnLine>>[];

  final selectedColor = Colors.black.obs;
  final selectedWidth = 4.0.obs;
  final isEraser = false.obs;

  IconData get currentToolIcon => isEraser.value ? MdiIcons.eraser : Icons.brush;
  String get currentToolTooltip => isEraser.value ? 'Tẩy' : 'Bút';

  void startStroke(Offset point) {
    undoStack.add(lines.map((l) => l.copy()).toList());
    redoStack.clear();

    final color = isEraser.value ? Colors.white : selectedColor.value;
    lines.add(DrawnLine(points: [point], color: color, width: selectedWidth.value));
  }

  void addPoint(Offset point) {
    if (lines.isNotEmpty) {
      lines.last.points.add(point);
    }
  }

  void endStroke() {
    if (lines.isNotEmpty) {
      saveCurrentFrame();
      lines.refresh(); // Cập nhật lại canvas
    }
  }


  void undo() {
    if (undoStack.isNotEmpty) {
      redoStack.add(List.from(lines.map((l) => l.copy())));
      lines.value = undoStack.removeLast();
      saveCurrentFrame();
    }
  }

  void redo() {
    if (redoStack.isNotEmpty) {
      undoStack.add(List.from(lines.map((l) => l.copy())));
      lines.value = redoStack.removeLast();
      saveCurrentFrame();
    }
  }

  void clearCanvas() {
    undoStack.add(List.from(lines.map((l) => l.copy())));
    lines.clear();
    saveCurrentFrame();
  }

  void toggleEraser() => isEraser.toggle();
  void changeColor(Color color) => selectedColor.value = color;
  void changeWidth(double width) => selectedWidth.value = width.clamp(1.0, 30.0);

  // Placeholder to be implemented in main controller
  void saveCurrentFrame() {}
}
