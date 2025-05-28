// ✅ DrawController cho phép vẽ trực tiếp lên layer hiện tại dù ở chế độ Frame hay Layout

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../data/models/DrawnLine_model.dart';
import '../views/sketcher.dart';

class DrawController extends GetxController {
  final repaintKey = GlobalKey();

  final lines = <DrawnLine>[].obs;
  final undoStack = <List<DrawnLine>>[];
  final redoStack = <List<DrawnLine>>[];

  final selectedColor = Colors.black.obs;
  final selectedWidth = 4.0.obs;
  final isEraser = false.obs;

  final frameLayers = <List<List<DrawnLine>>>[].obs;
  final currentFrameIndex = 0.obs;
  final currentLayerIndex = 0.obs;

  final isPlaying = false.obs;
  final isFrameListExpanded = true.obs;
  final isShowingLayout = false.obs;

  final Map<String, Uint8List> thumbnailCache = {};
  Timer? _playbackTimer;
  int _currentIndex = 0;
  final int fps = 6;

  List<DrawnLine>? copiedFrame;
  static const Size canvasSize = Size(1600, 900);

  IconData get currentToolIcon => isEraser.value ? MdiIcons.eraser : Icons.brush;
  String get currentToolTooltip => isEraser.value ? 'Tẩy' : 'Bút';

  @override
  void onInit() {
    super.onInit();
    addFrame();
    selectFrame(0);
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
      saveCurrentFrame();
      lines.refresh();
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
  void toggleFrameList() => isFrameListExpanded.toggle();

  void addFrame() {
    final layers = List.generate(3, (_) => <DrawnLine>[]);
    frameLayers.insert(0, layers);
    currentFrameIndex.value = 0;
    currentLayerIndex.value = 0;
    lines.value = layers[0];
  }

  void selectFrame(int index) {
    saveCurrentFrame();
    currentFrameIndex.value = index;
    currentLayerIndex.value = 0;
    lines.value = frameLayers[index][0];
  }

  void switchLayer(int layerIndex) {
    saveCurrentFrame();
    currentLayerIndex.value = layerIndex;
    lines.value = frameLayers[currentFrameIndex.value][layerIndex];
  }

  void saveCurrentFrame() {
    final fIndex = currentFrameIndex.value;
    final lIndex = currentLayerIndex.value;
    if (fIndex < frameLayers.length) {
      frameLayers[fIndex][lIndex] = lines.map((l) => l.copy()).toList();
      _clearThumbnailCache();
    }
  }

  void removeFrame(int index) {
    if (index >= 0 && index < frameLayers.length) {
      frameLayers.removeAt(index);
      if (frameLayers.isNotEmpty) {
        final newIndex = (index > 0) ? index - 1 : 0;
        selectFrame(newIndex);
      } else {
        lines.clear();
      }
    }
  }

  void copyFrame(int index) {
    final frame = frameLayers[index][currentLayerIndex.value];
    copiedFrame = frame.map((l) => l.copy()).toList();
  }

  void pasteCopiedFrame() {
    if (copiedFrame == null) return;
    final newLayer = copiedFrame!.map((l) => l.copy()).toList();
    final insertIndex = currentFrameIndex.value + 1;
    final newLayers = List.generate(3, (_) => <DrawnLine>[]);
    newLayers[0] = newLayer;
    frameLayers.insert(insertIndex, newLayers);
    selectFrame(insertIndex);
  }

  void togglePlayback() {
    isPlaying.toggle();
    if (isPlaying.value) {
      _currentIndex = 0;
      _playbackTimer = Timer.periodic(Duration(milliseconds: 1000 ~/ fps), (_) {
        if (frameLayers.isEmpty) return;
        _currentIndex = (_currentIndex + 1) % frameLayers.length;
        lines.value = frameLayers[_currentIndex][0];
        currentFrameIndex.value = _currentIndex;
        currentLayerIndex.value = 0;
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

  Future<Uint8List> renderThumbnail(int frameIndex, [int? layerIndex]) async {
    final cacheKey = layerIndex == null ? '$frameIndex' : '$frameIndex-$layerIndex';
    if (thumbnailCache.containsKey(cacheKey)) return thumbnailCache[cacheKey]!;

    const double thumbWidth = 160;
    const double thumbHeight = 90;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, thumbWidth, thumbHeight));
    canvas.scale(thumbWidth / canvasSize.width, thumbHeight / canvasSize.height);

    if (layerIndex == null) {
      for (int i = 0; i < 3; i++) {
        Sketcher(lines: frameLayers[frameIndex][i]).paint(canvas, canvasSize);
      }
    } else {
      Sketcher(lines: frameLayers[frameIndex][layerIndex]).paint(canvas, canvasSize);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(thumbWidth.toInt(), thumbHeight.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    thumbnailCache[cacheKey] = bytes;
    return bytes;
  }

  void _clearThumbnailCache() {
    thumbnailCache.clear();
  }
}
