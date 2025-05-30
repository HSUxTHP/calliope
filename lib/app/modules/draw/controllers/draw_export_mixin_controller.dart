import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import '../views/sketcher.dart';
import '../../../data/models/DrawnLine_model.dart';

mixin DrawExportMixin on GetxController {
  final repaintKey = GlobalKey();
  final Map<String, Uint8List> thumbnailCache = {};

  static const Size canvasSize = Size(1600, 900);

  final frameLayers = <List<List<DrawnLine>>>[].obs;

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
    final scale = thumbWidth / canvasSize.width;
    canvas.scale(scale, scale);

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

  bool isInsideCanvas(Offset point) {
    final box = repaintKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return false;
    final size = box.size;
    return point.dx >= 0 &&
        point.dy >= 0 &&
        point.dx <= size.width &&
        point.dy <= size.height;
  }
}
