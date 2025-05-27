import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../views/sketcher.dart';
import '../../../data/models/DrawnLine_model.dart';

class DrawController extends GetxController {
  final repaintKey = GlobalKey();

  final lines = <DrawnLine>[].obs;
  final undoStack = <List<DrawnLine>>[];
  final redoStack = <List<DrawnLine>>[];

  final selectedColor = Colors.black.obs;
  final selectedWidth = 4.0.obs;
  final isEraser = false.obs;

  final frames = <List<DrawnLine>>[].obs;
  final currentFrame = Rxn<List<DrawnLine>>();
  final currentFrameIndex = 0.obs;
  final Map<List<DrawnLine>, Uint8List> thumbnailCache = {};

  final isPlaying = false.obs;
  final isFrameListExpanded = true.obs;

  Timer? _playbackTimer;
  int _currentIndex = 0;
  final int fps = 6;

  List<DrawnLine>? copiedFrame;

  static const Size canvasSize = Size(1600, 900); // Kích thước canvas

  IconData get currentToolIcon => isEraser.value ? MdiIcons.eraser : Icons.brush;
  String get currentToolTooltip => isEraser.value ? 'Tẩy' : 'Bút';

  @override
  void onInit() {
    super.onInit();
    addFrame();
  }

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
      lines.refresh();
      thumbnailCache.remove(currentFrame.value);
    }
  }

  void undo() {
    if (undoStack.isNotEmpty) {
      redoStack.add(List.from(lines.map((l) => l.copy())));
      lines.value = undoStack.removeLast();
      thumbnailCache.remove(currentFrame.value);
    }
  }

  void redo() {
    if (redoStack.isNotEmpty) {
      undoStack.add(List.from(lines.map((l) => l.copy())));
      lines.value = redoStack.removeLast();
      thumbnailCache.remove(currentFrame.value);
    }
  }

  void clearCanvas() {
    undoStack.add(List.from(lines.map((l) => l.copy())));
    lines.clear();
    thumbnailCache.remove(currentFrame.value);
  }

  void toggleEraser() => isEraser.toggle();
  void changeColor(Color color) => selectedColor.value = color;
  void changeWidth(double width) => selectedWidth.value = width.clamp(1.0, 30.0);
  void toggleFrameList() => isFrameListExpanded.toggle();

  void addFrame() {
    final empty = <DrawnLine>[];
    frames.insert(0, empty);
    lines.value = empty;
    currentFrame.value = empty;
    currentFrameIndex.value = 0;
  }

  void saveCurrentFrame() {
    final index = frames.indexOf(currentFrame.value!);
    if (index != -1) {
      final copied = lines.map((l) => l.copy()).toList();
      frames[index] = copied;
      currentFrame.value = copied;
      thumbnailCache.remove(currentFrame.value);
    }
  }

  void selectFrame(List<DrawnLine> frame) {
    saveCurrentFrame();
    final index = frames.indexOf(frame);
    if (index != -1) {
      final copied = frame.map((l) => l.copy()).toList();
      currentFrameIndex.value = index;
      currentFrame.value = frame;
      lines.value = copied;
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

  void copyFrame(List<DrawnLine> frame) {
    copiedFrame = frame.map((l) => l.copy()).toList();
  }

  void pasteCopiedFrame() {
    if (copiedFrame == null) return;

    final newFrame = copiedFrame!.map((l) => l.copy()).toList();
    final insertIndex = currentFrameIndex.value + 1;

    frames.insert(insertIndex, newFrame);
    currentFrameIndex.value = insertIndex;
    lines.value = newFrame;
    currentFrame.value = newFrame;
  }

  void togglePlayback() {
    isPlaying.toggle();
    if (isPlaying.value) {
      _currentIndex = 0;
      _playbackTimer = Timer.periodic(Duration(milliseconds: 1000 ~/ fps), (_) {
        if (frames.isEmpty) return;
        _currentIndex = (_currentIndex + 1) % frames.length;
        final copied = frames[_currentIndex].map((l) => l.copy()).toList();
        lines.value = copied;
        currentFrameIndex.value = _currentIndex;
      });
    } else {
      _playbackTimer?.cancel();
    }
  }

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

    const double thumbWidth = 160;
    const double thumbHeight = 90;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, thumbWidth, thumbHeight));
    canvas.scale(thumbWidth / canvasSize.width, thumbHeight / canvasSize.height);

    final painter = Sketcher(lines: lines);
    painter.paint(canvas, canvasSize);

    final picture = recorder.endRecording();
    final image = await picture.toImage(thumbWidth.toInt(), thumbHeight.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    thumbnailCache[lines] = bytes;
    return bytes;
  }
}
