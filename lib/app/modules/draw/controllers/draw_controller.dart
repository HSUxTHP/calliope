import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import '../views/sketcher.dart';
import 'DrawnLine.dart';

class DrawController extends GetxController {
  final repaintKey = GlobalKey();

  // Trạng thái vẽ
  final lines = <DrawnLine>[].obs;
  final undoStack = <List<DrawnLine>>[];
  final redoStack = <List<DrawnLine>>[];

  final selectedColor = Colors.black.obs;
  final selectedWidth = 4.0.obs;
  final isEraser = false.obs;

  // Frame
  final frames = <List<DrawnLine>>[].obs;
  final currentFrame = Rxn<List<DrawnLine>>();
  final currentFrameIndex = 0.obs;
  final Map<List<DrawnLine>, Uint8List> thumbnailCache = {};

  // Playback
  final isPlaying = false.obs;
  Timer? _playbackTimer;
  int _currentIndex = 0;
  final int fps = 6;

  @override
  void onInit() {
    super.onInit();
    addFrame();
  }

  // Vẽ
  void startStroke(Offset point) {
    undoStack.add(List.from(lines.map((l) => l.copy())));
    redoStack.clear();
    final color = isEraser.value ? Colors.white : selectedColor.value;
    lines.add(DrawnLine(points: [point], color: color, width: selectedWidth.value));
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
      lines.refresh();  }
  }

  // Undo/Redo
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

  // Công cụ
  void toggleEraser() => isEraser.toggle();
  void changeColor(Color color) => selectedColor.value = color;
  void changeWidth(double width) => selectedWidth.value = width.clamp(1.0, 30.0);

  // Frame
  void addFrame() {
    final empty = <DrawnLine>[];
    frames.insert(0, empty);
    lines.value = empty;
    currentFrame.value = empty;
    currentFrameIndex.value = 0;
  }

  void selectFrame(List<DrawnLine> frame) {
    final index = frames.indexOf(frame);
    if (index != -1) {
      currentFrameIndex.value = index;
      lines.value = frame.map((l) => l.copy()).toList();
      currentFrame.value = frame;
    }
  }

  void saveCurrentFrame() {
    final index = frames.indexOf(currentFrame.value!);
    if (index != -1) {
      frames[index] = lines.map((l) => l.copy()).toList();
      currentFrame.value = frames[index];
    }
  }

  void removeFrame(List<DrawnLine> frame) {
    final index = frames.indexOf(frame);
    if (index != -1) {
      frames.removeAt(index);
      thumbnailCache.remove(frame);
      if (frames.isNotEmpty) {
        final newIndex = (index > 0) ? index - 1 : 0;
        selectFrame(frames[newIndex]);
      } else {
        lines.clear();
        currentFrame.value = null;
      }
    }
  }

  // Playback
  void togglePlayback() {
    isPlaying.toggle();
    if (isPlaying.value) {
      _currentIndex = 0;
      _playbackTimer = Timer.periodic(Duration(milliseconds: 1000 ~/ fps), (_) {
        if (frames.isEmpty) return;
        _currentIndex = (_currentIndex + 1) % frames.length;
        lines.value = frames[_currentIndex].map((l) => l.copy()).toList();
        currentFrameIndex.value = _currentIndex;
      });
    } else {
      _playbackTimer?.cancel();
    }
  }

  // Capture
  Future<Uint8List?> captureImage() async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 2.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        return byteData?.buffer.asUint8List();
      }
    } catch (e) {
      print('Lỗi capture: $e');
    }
    return null;
  }

  Future<Uint8List> renderThumbnail(List<DrawnLine> lines) async {
    if (thumbnailCache.containsKey(lines)) {
      return thumbnailCache[lines]!;
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, 160, 90));
    final painter = Sketcher(lines: lines);
    painter.paint(canvas, const Size(160, 90));
    final picture = recorder.endRecording();
    final image = await picture.toImage(160, 90);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    thumbnailCache[lines] = bytes;
    return bytes;
  }
}
