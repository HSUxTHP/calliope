import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/models/DrawnLine_model.dart';
import '../views/sketcher.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';


class DrawController extends GetxController {
  final repaintKey = GlobalKey();
  final scrollController = ScrollController();

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
  final isShowingLayout = true.obs;

  final playbackSpeed = 6.obs; // Mặc định 6 FPS

  final Map<String, Uint8List> thumbnailCache = {};
  Timer? _playbackTimer;
  int _currentIndex = 0;
  int fps = 6;

  List<List<DrawnLine>>? copiedFrame;
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
      lines.refresh();        // Cập nhật UI
      saveCurrentFrame();     // Lưu vào layer tương ứng
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

  void copyFrame(int index) {
    if (index >= 0 && index < frameLayers.length) {
      copiedFrame = frameLayers[index]
          .map((layer) => layer.map((line) => line.copy()).toList())
          .toList();
    }
  }

  void copyFrameCurrent() {
    final index = currentFrameIndex.value;
    copyFrame(index);
  }

  void pasteCopiedFrame() {
    if (copiedFrame == null) return;
    final newFrame = copiedFrame!
        .map((layer) => layer.map((line) => line.copy()).toList())
        .toList();
    final insertIndex = currentFrameIndex.value + 1;
    frameLayers.insert(insertIndex, newFrame);
    selectFrame(insertIndex);
  }
  void reorderFrame(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;

    final item = frameLayers.removeAt(oldIndex);
    frameLayers.insert(newIndex, item);

    if (currentFrameIndex.value == oldIndex) {
      currentFrameIndex.value = newIndex;
    } else if (currentFrameIndex.value == newIndex) {
      currentFrameIndex.value = oldIndex;
    } else if (oldIndex < currentFrameIndex.value && currentFrameIndex.value <= newIndex) {
      currentFrameIndex.value -= 1;
    } else if (newIndex <= currentFrameIndex.value && currentFrameIndex.value < oldIndex) {
      currentFrameIndex.value += 1;
    }
  }
  RxSet<int> hiddenFrames = <int>{}.obs;
  RxSet<int> hiddenLayers = <int>{}.obs;

  bool isFrameHidden(int index) => hiddenFrames.contains(index);
  bool isLayerHidden(int index) => hiddenLayers.contains(index);

  void toggleFrameVisibility(int index) {
    if (hiddenFrames.contains(index)) {
      hiddenFrames.remove(index);
    } else {
      hiddenFrames.add(index);
    }
  }

  void toggleLayerVisibility(int index) {
    if (hiddenLayers.contains(index)) {
      hiddenLayers.remove(index);
    } else {
      hiddenLayers.add(index);
    }
  }

  void removeFrame(int index) {
    frameLayers.removeAt(index);
    frameLayers.refresh(); // BẮT BUỘC để cập nhật .obs
  }


  void togglePlayback() {
    isPlaying.toggle();
    _playbackTimer?.cancel();

    if (isPlaying.value) {
      _currentIndex = 0;
      _playbackTimer = Timer.periodic(Duration(milliseconds: 1000 ~/ fps), (_) {
        if (frameLayers.isEmpty) return;
        _currentIndex = (_currentIndex + 1) % frameLayers.length;
        lines.value = frameLayers[_currentIndex][0];
        currentFrameIndex.value = _currentIndex;
        currentLayerIndex.value = 0;
      });
    }
  }

  void setFps(int value) {
    fps = value;
    playbackSpeed.value = value;

    if (isPlaying.value) {
      togglePlayback();
      togglePlayback();
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

  bool isInsideCanvas(Offset point) {
    final box = repaintKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return false;
    final size = box.size;
    return point.dx >= 0 &&
        point.dy >= 0 &&
        point.dx <= size.width &&
        point.dy <= size.height;
  }
  Future<void> renderAllFramesToImages() async {
    final dir = await getApplicationDocumentsDirectory();
    final outputDir = Directory("${dir.path}/frames");
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    for (int i = 0; i < frameLayers.length; i++) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));

      for (int l = 0; l < 3; l++) {
        if (!isLayerHidden(l)) {
          Sketcher(lines: frameLayers[i][l]).paint(canvas, canvasSize);
        }
      }

      final picture = recorder.endRecording();
      final image = await picture.toImage(canvasSize.width.toInt(), canvasSize.height.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final filePath = "${outputDir.path}/frame_${i.toString().padLeft(3, '0')}.png";
      await File(filePath).writeAsBytes(bytes);
    }
  }

  Future<bool> ensureStoragePermission() async {
    if (Platform.isAndroid) {
      // Android 11 trở lên cần quyền đặc biệt
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      } else {
        final status = await Permission.manageExternalStorage.request();
        return status.isGranted;
      }
    } else {
      // iOS hoặc Android thấp hơn
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      return true;
    }
  }

  Future<void> exportToVideoWithFFmpeg() async {
    bool granted = await ensureStoragePermission();
    if (!granted) {
      print("Chưa cấp quyền lưu trữ");
      Get.snackbar("Lỗi", "Chưa cấp quyền lưu trữ", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // 🔹 Cho phép người dùng chọn thư mục lưu
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) {
      Get.snackbar("Hủy", "Bạn chưa chọn thư mục", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final framesDir = Directory(p.join(selectedDirectory, "frames"));
    if (!await framesDir.exists()) {
      await framesDir.create(recursive: true);
    }

    // Render các frame thành ảnh PNG
    for (int i = 0; i < frameLayers.length; i++) {
      currentFrameIndex.value = i;
      currentLayerIndex.value = 0;
      lines.value = frameLayers[i][0];

      await Future.delayed(const Duration(milliseconds: 50));
      final bytes = await captureImage();
      if (bytes == null) continue;

      final filePath = p.join(framesDir.path, 'frame_${i.toString().padLeft(3, '0')}.png');
      await File(filePath).writeAsBytes(bytes);
    }

    final outputPath = p.join(selectedDirectory, 'output_video.mp4');

    // 🛠 FFmpeg command
    final cmd =
        "-y -framerate $fps -start_number 0 -i ${framesDir.path}/frame_%03d.png "
        "-vf scale='trunc(iw/2)*2:trunc(ih/2)*2' "
        "-c:v libx264 -pix_fmt yuv420p $outputPath";

    print("Running FFmpeg command: $cmd");
    final session = await FFmpegKit.execute(cmd);

    final logs = await session.getAllLogs();
    for (final log in logs) {
      print(log.getMessage());
    }

    final returnCode = await session.getReturnCode();
    if (ReturnCode.isSuccess(returnCode)) {
      print("✅ Xuất video thành công: $outputPath");
      await framesDir.delete(recursive: true);
      Get.snackbar("Thành công", "Xuất video thành công:\n$outputPath", snackPosition: SnackPosition.BOTTOM);
    } else {
      print("❌ Xuất video thất bại với mã: $returnCode");
      Get.snackbar("Lỗi", "Xuất video thất bại với mã: $returnCode", snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _clearThumbnailCache() {
    thumbnailCache.clear();
  }

  void scrollToTop() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
