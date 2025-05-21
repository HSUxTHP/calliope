import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import '../views/sketcher.dart';

class DrawnLine {
  final List<Offset?> points;
  final Color color;
  final double width;

  DrawnLine({required this.points, required this.color, required this.width});

  DrawnLine copy() => DrawnLine(
    points: List.from(points),
    color: color,
    width: width,
  );
}

class DrawController extends GetxController {
  final repaintKey = GlobalKey();

  // Line logic
  final lines = <DrawnLine>[].obs;
  final undoStack = <List<DrawnLine>>[];
  final redoStack = <List<DrawnLine>>[];

  final selectedColor = Colors.black.obs;
  final selectedWidth = 4.0.obs;
  final isEraser = false.obs;

  // Frame logic
  final frames = <List<DrawnLine>>[].obs;
  final currentFrame = Rxn<List<DrawnLine>>();

  final isPlaying = false.obs;
  Timer? _playbackTimer;
  int _currentIndex = 0;
  final int fps = 6; // 6 frame/sec

  @override
  void onInit() {
    super.onInit();
    addFrame(); // Thêm 1 frame trắng ban đầu
  }

  // Vẽ
  void startStroke(Offset point) {
    undoStack.add(List.from(lines.map((l) => l.copy())));
    redoStack.clear();
    final color = isEraser.value ? Colors.white : selectedColor.value;
    final width = selectedWidth.value;
    lines.add(DrawnLine(points: [point], color: color, width: width));
  }

  void addPoint(Offset point) {
    if (lines.isNotEmpty) {
      lines.last.points.add(point);
      lines.refresh();
    }
  }

  void endStroke() {
    if (lines.isNotEmpty) {
      lines.last.points.add(null);
      lines.refresh();
    }
  }

  void undo() {
    if (undoStack.isNotEmpty) {
      redoStack.add(List.from(lines.map((l) => l.copy())));
      lines.value = undoStack.removeLast();
    }
  }

  void redo() {
    if (redoStack.isNotEmpty) {
      undoStack.add(List.from(lines.map((l) => l.copy())));
      lines.value = redoStack.removeLast();
    }
  }

  void clearCanvas() {
    undoStack.add(List.from(lines.map((l) => l.copy())));
    lines.clear();
  }

  void toggleEraser() => isEraser.value = !isEraser.value;
  void changeColor(Color color) => selectedColor.value = color;
  void changeWidth(double width) => selectedWidth.value = width;

  // Lưu ảnh
  Future<Uint8List?> captureImage() async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 2.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        return byteData?.buffer.asUint8List();
      }
    } catch (e) {
      print('Lỗi khi capture ảnh: $e');
    }
    return null;
  }

  // Thumbnail preview
  Future<Uint8List> renderThumbnail(List<DrawnLine> lines) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, 160, 90));
    final painter = Sketcher(lines: lines);
    painter.paint(canvas, const Size(160, 90));
    final picture = recorder.endRecording();
    final image = await picture.toImage(160, 90);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  // Phát frame liên tục
  void togglePlayback() {
    isPlaying.value = !isPlaying.value;
    if (isPlaying.value) {
      _currentIndex = 0;
      _playbackTimer = Timer.periodic(Duration(milliseconds: 1000 ~/ fps), (_) {
        if (frames.isEmpty) return;
        _currentIndex = (_currentIndex + 1) % frames.length;
        lines.value = frames[_currentIndex].map((l) => l.copy()).toList();
      });
    } else {
      _playbackTimer?.cancel();
    }
  }

  // Thêm frame trắng vào đầu danh sách
  void addFrame() {
    final emptyFrame = <DrawnLine>[];
    frames.insert(0, emptyFrame); // đưa vào đầu
    lines.value = emptyFrame;
    currentFrame.value = emptyFrame;
  }

  // Chọn frame để vẽ
  void selectFrame(List<DrawnLine> frame) {
    lines.value = frame.map((l) => l.copy()).toList();
    currentFrame.value = frame;
  }

  // Lưu nét vẽ hiện tại vào frame đang chọn
  void saveCurrentFrame() {
    final index = frames.indexOf(currentFrame.value!);
    if (index != -1) {
      frames[index] = lines.map((l) => l.copy()).toList();
      currentFrame.value = frames[index];
    }
  }

  // Xoá frame
  void removeFrame(List<DrawnLine> frame) {
    if (frames.contains(frame)) {
      final index = frames.indexOf(frame);
      frames.remove(frame);
      if (frames.isNotEmpty) {
        final newIndex = index > 0 ? index - 1 : 0;
        selectFrame(frames[newIndex]);
      } else {
        lines.clear();
        currentFrame.value = null;
      }
    }
  }
}
