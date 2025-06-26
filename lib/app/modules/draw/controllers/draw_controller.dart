import 'dart:async';
import 'dart:typed_data';

import 'dart:ui' as ui;
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/models/drawmodels/draw_project_model.dart';
import '../../../data/models/drawmodels/drawn_line_model.dart';
import '../../../data/models/drawmodels/frame_model.dart';
import '../../profile/controllers/upload_controller.dart';
import '../views/sketcher.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
enum ToolType { brush, eraser }
class DrawController extends GetxController {
  final repaintKey = GlobalKey();
  final scrollController = ScrollController();
  final undoStack = <List<List<DrawnLine>>>[].obs;
  final redoStack = <List<List<DrawnLine>>>[].obs;
  final selectedColor = Colors.black.obs;
  final selectedWidth = 4.0.obs;
  final isEraser = false.obs;
  final Map<int, GlobalKey> frameItemKeys = {};
  final isReorderMode = false.obs;
  void toggleReorderMode() => isReorderMode.toggle();
  final showOnionSkin = true.obs;
  final onionSkinEnabled = true.obs;
  final onionSkinRangeBefore = 2;
  final onionSkinRangeAfter = 1;
  final onionSkinCount = 2.obs;
  void toggleOnionSkin() => showOnionSkin.toggle();
  final frames = <FrameModel>[].obs;
  final currentFrameIndex = 0.obs;
  final currentLayerIndex = 0.obs;
  String? currentProjectId;
  String? currentProjectName;
  final isPlaying = false.obs;
  final isFrameListExpanded = true.obs;
  final isShowingLayout = true.obs;
  final playbackSpeed = 6.obs;
  final _box = Hive.box<DrawProjectModel>('draw_project');
  Future<void> saveProjectToHive(String projectId, String name) async {
    final project = DrawProjectModel(
      id: projectId,
      name: name,
      updatedAt: DateTime.now(),
      frames: frames.map((f) => f.copy()).toList(),
    );
    await _box.put(projectId, project);
  }
  void loadProject(String id) {
    final project = _box.get(id);
    if (project != null) {
      frames.assignAll(project.frames.map((f) => f.copy()).toList());
      currentFrameIndex.value = 0;
      currentLayerIndex.value = 0;
      currentProjectId = id;
      currentProjectName = project.name;
    }
  }
  List<MapEntry<List<DrawnLine>, double>> getPreviousFramesLines() {
    final index = currentFrameIndex.value;
    final result = <MapEntry<List<DrawnLine>, double>>[];
    for (int i = 1; i <= onionSkinCount.value; i++) {
      final idx = index + i; // 👉 duyệt frame SAU (cũ hơn)
      if (idx >= 0 && idx < frames.length) {
        final lines = frames[idx].layers.expand((layer) => layer.lines).toList();
        final opacity = (1.0 - i / (onionSkinCount.value + 1)) * 0.4; // ví dụ: 0.4, 0.27, 0.2
        result.add(MapEntry(lines, opacity));
      }
    }
    return result;
  }
  List<DrawnLine>? getPreviousFrameLines() {
    final index = currentFrameIndex.value;
    if (index <= 0 || index >= frames.length) return null;
    final prevFrame = frames[index - 1];
    return prevFrame.layers.expand((layer) => layer.lines).toList();
  }
  List<MapEntry<List<DrawnLine>, double>> getMultiOnionLines() {
    final index = currentFrameIndex.value;
    final List<MapEntry<List<DrawnLine>, double>> onionLayers = [];
    // 👉 Chỉ lấy các frame trước (quá khứ)
    for (int i = 1; i <= onionSkinRangeBefore; i++) {
      final prevIndex = index - i;
      if (prevIndex < 0) break;
      final lines = frames[prevIndex].layers.expand((layer) => layer.lines).toList();
      double alpha = (1.0 - i / (onionSkinRangeBefore + 1)) * 0.5; // giảm dần opacity
      onionLayers.add(MapEntry(lines, alpha));
    }
    return onionLayers;
  }
  List<MapEntry<List<DrawnLine>, double>> getOnionSkinLines() {
    final index = currentFrameIndex.value;
    final List<MapEntry<List<DrawnLine>, double>> onionLayers = [];
    for (int i = 1; i <= onionSkinCount.value; i++) {
      final nextIndex = index + i;
      if (nextIndex >= frames.length) break;
      final lines = frames[nextIndex].layers.expand((layer) => layer.lines).toList();
      final opacity = (1.0 - i / (onionSkinCount.value + 1)) * 0.4; // mờ dần
      onionLayers.add(MapEntry(lines, opacity));
    }
    return onionLayers;
  }
  Widget buildLayoutSelector() {
    final controller = Get.find<DrawController>();
    Widget layoutItem(int index, String label, IconData icon) {
      return Obx(() {
        final isSelected = controller.currentLayerIndex.value == index;
        return GestureDetector(
          onTap: () => controller.switchLayer(index),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade50 : Colors.grey.shade200,
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: isSelected ? Colors.blue : Colors.black54),
                SizedBox(width: 8),
                Text(label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    )),
              ],
            ),
          ),
        );
      });
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        layoutItem(0, 'Layout 1', Icons.layers),
        layoutItem(1, 'Layout 2', Icons.layers_outlined),
        layoutItem(2, 'Layout 3', Icons.layers_clear),
      ],
    );
  }

  final Map<String, Uint8List> thumbnailCache = {};
  Timer? _playbackTimer;
  int _currentIndex = 0;
  int fps = 6;
  List<DrawnLine> get currentLines =>
      frames[currentFrameIndex.value].layers[currentLayerIndex.value].lines;
  set currentLines(List<DrawnLine> newLines) =>
      frames[currentFrameIndex.value].layers[currentLayerIndex.value].lines = newLines;
  List<List<DrawnLine>>? copiedFrame;
  static const Size canvasSize = Size(1050, 590.625);
  final IconData brushIcon = Icons.brush;
  final IconData eraserIcon = MdiIcons.eraser;
  final String brushTooltip = 'Bút';
  final String eraserTooltip = 'Tẩy';
  final Rx<ToolType> selectedTool = ToolType.brush.obs;
  IconData get currentToolIcon =>
  selectedTool.value == ToolType.brush ? brushIcon : eraserIcon;
  String get currentToolTooltip =>
  selectedTool.value == ToolType.brush ? brushTooltip : eraserTooltip;
  void selectBrush() => selectedTool.value = ToolType.brush;
  void selectEraser() => selectedTool.value = ToolType.eraser;
  @override
  void onInit() {
    super.onInit();
    addFrame();
    selectFrame(0);
  }
  void startStroke(Offset point) {
    // Lưu cả 3 layer của frame hiện tại vào undoStack
    undoStack.add(
      frames[currentFrameIndex.value]
          .layers
          .map((layer) => layer.lines.map((line) => line.copy()).toList())
          .toList(),
    );
    redoStack.clear();
    final color = selectedTool.value == ToolType.eraser ? Colors.white : selectedColor.value;
    currentLines.add(DrawnLine(points: [point], colorValue: color.value, width: selectedWidth.value));
  }
  final Map<int, RxInt> frameVersions = {};
  final currentTempLine = Rx<DrawnLine?>(null); // chỉ 1 dòng đang vẽ

  void addPoint(Offset point) {
    if (currentLines.isNotEmpty) {
      currentLines.last.points.add(point);
      final index = currentFrameIndex.value;
      frames.refresh(); // 👈 chỉ cập nhật frame hiện tại
    }
  }
  void endStroke() {
    if (currentLines.isNotEmpty) {
      final index = currentFrameIndex.value;
      frames.refresh(); // 👈 chỉ update frame hiện tại
      saveCurrentFrame();
      if (currentProjectId != null && currentProjectName != null) {
        saveProjectToHive(currentProjectId!, currentProjectName!);
      }
    }
  }
  void undo() {
    if (undoStack.isNotEmpty) {
      // Lưu lại trạng thái hiện tại trước khi undo
      redoStack.add(
        frames[currentFrameIndex.value]
            .layers
            .map((layer) => layer.lines.map((line) => line.copy()).toList())
            .toList(),
      );
      final previous = undoStack.removeLast();
      // Gán lại cho 3 layer
      for (int i = 0; i < 3; i++) {
        frames[currentFrameIndex.value].layers[i].lines = previous[i];
      }
      frames.refresh();
    }
  }
  void redo() {
    if (redoStack.isNotEmpty) {
      // Lưu trạng thái hiện tại trước khi redo
      undoStack.add(
        frames[currentFrameIndex.value]
            .layers
            .map((layer) => layer.lines.map((line) => line.copy()).toList())
            .toList(),
      );
      final next = redoStack.removeLast();
      // Gán lại cho 3 layer
      for (int i = 0; i < 3; i++) {
        frames[currentFrameIndex.value].layers[i].lines = next[i];
      }
      frames.refresh();
    }
  }
  void clearCanvas() {
    undoStack.add(
      frames[currentFrameIndex.value]
          .layers
          .map((layer) => layer.lines.map((line) => line.copy()).toList())
          .toList(),
    );
    for (int i = 0; i < 3; i++) {
      frames[currentFrameIndex.value].layers[i].lines.clear();
    }
    frames.refresh();
  }
  void toggleEraser() => isEraser.toggle();
  void changeColor(Color color) => selectedColor.value = color;
  void changeWidth(double width) => selectedWidth.value = width.clamp(1.0, 30.0);
  void toggleFrameList() => isFrameListExpanded.toggle();
  void addFrame() {
    final newFrame = FrameModel(); // tự khởi tạo 3 layer rỗng
    frames.insert(0, newFrame);
    currentFrameIndex.value = 0;
    currentLayerIndex.value = 0;
    _clearThumbnailCache();
    frames.refresh();
  }
  void resetLayerIndex() {
    if (currentLayerIndex.value == 0) {
      currentLayerIndex.value = -1;
    }
    currentLayerIndex.value = 0;
  }

  void selectFrame(int index) {
    if (index == currentFrameIndex.value) return;
    final copied = currentLines.map((l) => l.copy()).toList();
    currentLines = copied;
    currentFrameIndex.value = index;
    if (currentProjectId != null && currentProjectName != null) {
      saveProjectToHive(currentProjectId!, currentProjectName!);
    }
    final context = frameItemKeys[index]?.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
      );
    }
  }
  void switchLayer(int layerIndex) {
    saveCurrentFrame();
    currentLayerIndex.value = layerIndex;
  }
  void saveCurrentFrame() {
    final copied = currentLines.map((l) => l.copy()).toList();
    currentLines = copied;
    _clearThumbnailCache();
    if (currentProjectId != null && currentProjectName != null) {
      saveProjectToHive(currentProjectId!, currentProjectName!);
    }
  }
  void copyFrame(int index) {
    if (index >= 0 && index < frames.length) {
      copiedFrame = frames[index]
          .layers
          .map((layer) => layer.lines.map((line) => line.copy()).toList())
          .toList();
    }
  }


  void copyFrameCurrent() {
    final index = currentFrameIndex.value;
    copyFrame(index);
  }
  void pasteCopiedFrame() {
    if (copiedFrame == null) return;

    final newFrame = FrameModel();
    for (int i = 0; i < 3; i++) {
      newFrame.layers[i].lines = copiedFrame![i].map((line) => line.copy()).toList();
    }

    final insertIndex = currentFrameIndex.value + 1;
    frames.insert(insertIndex, newFrame);
    selectFrame(insertIndex);

    // Ghi lại vào Hive sau khi paste
    if (currentProjectId != null && currentProjectName != null) {
      saveProjectToHive(currentProjectId!, currentProjectName!);
    }
  }

  void reorderFrame(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;

    final item = frames.removeAt(oldIndex);
    frames.insert(newIndex, item);

    // Xoá cache thumbnail (QUAN TRỌNG)
    _clearThumbnailCache();
    frames.refresh();

    // Giữ frame đang chọn đúng vị trí mới
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
    frames.removeAt(index);
    frames.refresh();

    // 🔥 Thêm dòng này để lưu lại thay đổi vào Hive
    if (currentProjectId != null && currentProjectName != null) {
      saveProjectToHive(currentProjectId!, currentProjectName!);
    }

    // Thêm để xóa thumbnail cache và làm mới UI
    _clearThumbnailCache();
    frames.refresh();
  }


  Future<void> deleteCurrentFrame() async {
    if (frames.length <= 1) return;

    final index = currentFrameIndex.value;
    removeFrame(index);

    if (index >= frames.length) {
      currentFrameIndex.value = frames.length - 1;
    }

    // Gọi lại render thumbnail để cập nhật UI
    await renderThumbnail(currentFrameIndex.value);
  }



  void togglePlayback() {
    isPlaying.toggle();
    _playbackTimer?.cancel();

    if (isPlaying.value) {
      _currentIndex = frames.length - 1; // 👉 Bắt đầu từ frame cuối
      _playbackTimer = Timer.periodic(Duration(milliseconds: 1000 ~/ fps), (_) {
        if (frames.isEmpty) return;

        currentFrameIndex.value = _currentIndex;
        _currentIndex = (_currentIndex - 1) % frames.length;
        if (_currentIndex < 0) _currentIndex = frames.length - 1; // 👉 reset về cuối nếu < 0
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

  Future<Uint8List?> captureImageSmooth() async {
    try {
      await Future.delayed(Duration(milliseconds: 50)); // chờ layout ổn định
      await WidgetsBinding.instance.endOfFrame;

      final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 1.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        return byteData?.buffer.asUint8List();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error capture smooth: $e');
      }
    }
    return null;
  }


  Future<Uint8List> renderThumbnail(int frameIndex, [int? layerIndex]) async {
    if (frameIndex < 0 || frameIndex >= frames.length) {
      throw ArgumentError('Invalid frameIndex: $frameIndex');
    }

    final cacheKey = layerIndex == null ? '$frameIndex' : '$frameIndex-$layerIndex';
    if (thumbnailCache.containsKey(cacheKey)) return thumbnailCache[cacheKey]!;

    const double thumbWidth = 1050;
    const double thumbHeight = 590.625;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, thumbWidth, thumbHeight));

    final scaleX = thumbWidth / canvasSize.width;
    final scaleY = thumbHeight / canvasSize.height;
    canvas.scale(scaleX, scaleY);

    canvas.drawColor(Colors.white, BlendMode.src);

    try {
      if (layerIndex == null) {
        final allLines = <DrawnLine>[];
        for (int i = 0; i < 3; i++) {
          if (!isLayerHidden(i)) {
            allLines.addAll(frames[frameIndex].layers[i].lines);
          }
        }

        SketcherFull(
          mainLines: allLines,
          onionSkinLines: null, // KHÔNG render onionSkin trong thumbnail
        ).paint(canvas, canvasSize);
      } else {
        SketcherFull(
          mainLines: frames[frameIndex].layers[layerIndex].lines,
          onionSkinLines: null,
        ).paint(canvas, canvasSize);
      }

      final picture = recorder.endRecording();
      final image = await picture.toImage(thumbWidth.toInt(), thumbHeight.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception("Failed to encode image to byteData");

      final bytes = byteData.buffer.asUint8List();
      thumbnailCache[cacheKey] = bytes;
      return bytes;
    } catch (e) {
      if (kDebugMode) {
        print("Error Render thumbnail frame $frameIndex: $e");
      }
      return Uint8List(0);
    }
  }



  Future<void> exportFrameAsImage(int frameIndex) async {
    if (frameIndex < 0 || frameIndex >= frames.length) {
      Get.snackbar("Lỗi", "Chỉ số frame không hợp lệ.");
      return;
    }

    bool granted = await ensureStoragePermission();
    if (!granted) {
      Get.snackbar("Lỗi", "Không có quyền lưu trữ.");
      return;
    }

    final dir = await FilePicker.platform.getDirectoryPath();
    if (dir == null) {
      Get.snackbar("Đã huỷ", "Bạn chưa chọn thư mục.");
      return;
    }

    final bytes = await renderThumbnail(frameIndex );
    final filePath = "$dir/frame_${frameIndex.toString().padLeft(3, '0')}.png";
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    Get.snackbar(
      "Export Successful",
      "The exported image has been saved as PNG.",
      snackPosition: SnackPosition.BOTTOM,
    );
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

    for (int i = 0; i < frames.length; i++) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));
      canvas.drawColor(Colors.white, BlendMode.src);

      final allLines = <DrawnLine>[];
      for (int l = 0; l < 3; l++) {
        if (!isLayerHidden(l)) {
          allLines.addAll(frames[i].layers[l].lines);
        }
      }

      SketcherFull(
        mainLines: allLines,
      ).paint(canvas, canvasSize);

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

  Future<void> exportToVideoWithFFmpeg(int fps) async {
    bool granted = await ensureStoragePermission();
    if (!granted) {
      if (kDebugMode) {
        print("Storage permission not granted.");
      }
      Get.snackbar("Error", "Storage permission not granted.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // 🔹 Let user pick output directory
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) {
      Get.snackbar("Cancelled", "No folder was selected.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // 🔹 Ask user for project name
    String? projectName = await _getProjectNameFromUser();
    if (projectName == null || projectName.trim().isEmpty) {
      Get.snackbar("Cancelled", "No project name was provided.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // 🔹 Create frames folder
    final framesDir = Directory(p.join(selectedDirectory, "${projectName}_frames"));
    if (!await framesDir.exists()) {
      await framesDir.create(recursive: true);
    }

    // 🔹 Render frames in reverse order (latest to earliest)
    for (int i = frames.length - 1; i >= 0; i--) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));
      canvas.drawColor(Colors.white, BlendMode.src);

      final allLines = <DrawnLine>[];
      for (int l = 0; l < 3; l++) {
        if (!isLayerHidden(l)) {
          allLines.addAll(frames[i].layers[l].lines);
        }
      }

      SketcherFull(
        mainLines: allLines,
        onionSkinLines: null,
      ).paint(canvas, canvasSize);


      final picture = recorder.endRecording();
      final image = await picture.toImage(canvasSize.width.toInt(), canvasSize.height.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final index = frames.length - 1 - i;
      final filePath = p.join(framesDir.path, 'frame_${index.toString().padLeft(3, '0')}.png');
      await File(filePath).writeAsBytes(bytes);
    }

    final outputPath = p.join(selectedDirectory, '${projectName}.mp4');

    // 🔹 FFmpeg command
    final cmd =
        "-y -framerate $fps -start_number 0 -i ${framesDir.path}/frame_%03d.png "
        "-vf scale='trunc(iw/2)*2:trunc(ih/2)*2' "
        "-c:v libx264 -pix_fmt yuv420p $outputPath";

    if (kDebugMode) {
      print("Running FFmpeg command: $cmd");
    }
    final session = await FFmpegKit.execute(cmd);

    final logs = await session.getAllLogs();
    for (final log in logs) {
      if (kDebugMode) {
        print(log.getMessage());
      }
    }

    final returnCode = await session.getReturnCode();
    if (ReturnCode.isSuccess(returnCode)) {
      if (kDebugMode) {
        print("Video exported successfully: $outputPath");
      }
      await framesDir.delete(recursive: true);
      Get.snackbar("Success", "Video exported successfully:\n$outputPath", snackPosition: SnackPosition.BOTTOM);
    } else {
      if (kDebugMode) {
        print("Export failed: $returnCode");
      }
      Get.snackbar("Error", "Video export failed with code: $returnCode", snackPosition: SnackPosition.BOTTOM);
    }
  }



  Future<void> uploadVideoToProfile(int fps, int userId, {int? selectedFrameIndex}) async {
    final tempDir = await getTemporaryDirectory();
    final framesDir = Directory(p.join(tempDir.path, "upload_frames"));

    if (!await framesDir.exists()) {
      await framesDir.create(recursive: true);
    }

    // Step 1: Render frames into images
    for (int i = frames.length - 1; i >= 0; i--) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));
      canvas.drawColor(Colors.white, BlendMode.src);

      final allLines = <DrawnLine>[];
      for (int l = 0; l < 3; l++) {
        if (!isLayerHidden(l)) {
          allLines.addAll(frames[i].layers[l].lines);
        }
      }

      SketcherFull(
        mainLines: allLines,
        onionSkinLines: null,
      ).paint(canvas, canvasSize);

      final picture = recorder.endRecording();
      final image = await picture.toImage(canvasSize.width.toInt(), canvasSize.height.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final framePath = p.join(framesDir.path, 'frame_${(frames.length - 1 - i).toString().padLeft(3, '0')}.png');
      await File(framePath).writeAsBytes(bytes);
    }

    // Step 2: Generate video from images
    final outputVideoPath = p.join(tempDir.path, 'upload_video.mp4');
    final ffmpegCommand =
        "-y -framerate $fps -start_number 0 -i ${framesDir.path}/frame_%03d.png "
        "-vf scale='trunc(iw/2)*2:trunc(ih/2)*2' "
        "-c:v libx264 -pix_fmt yuv420p $outputVideoPath";

    final session = await FFmpegKit.execute(ffmpegCommand);
    final returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      Get.snackbar("Error", "Failed to generate video for upload.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Step 3: Prepare Upload
    final uploadController = Get.put(UploadController());
    uploadController.videoFile.value = File(outputVideoPath);

    // Use selected frame as thumbnail (default = frame 0)
    final frameIndex = selectedFrameIndex ?? 0;
    final thumbPath = p.join(tempDir.path, 'thumbnail.png');
    final thumb = await renderThumbnailToFile(frameIndex, thumbPath);
    if (thumb != null) {
      uploadController.backgroundFile.value = thumb;
    }

    // Default values
    uploadController.nameController.text = currentProjectName ?? 'New Video';
    uploadController.descriptionController.text = 'Created using Calliope drawing app';

    // Step 4: Let user customize post info
    final confirmed = await _showPostCustomizationDialog(uploadController);
    if (!confirmed) {
      Get.snackbar("Cancelled", "Upload cancelled by user.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Step 5: Upload
    await uploadController.uploadVideo(userId);

    // Step 6: Clean up
    if (await framesDir.exists()) {
      await framesDir.delete(recursive: true);
      await File(outputVideoPath).delete();
    }
  }
  Future<void> generateTween(int fromIndex, int toIndex, int steps) async {
    if (fromIndex < 0 || toIndex >= frames.length || fromIndex >= toIndex || steps < 1) {
      Get.snackbar("Lỗi", "Tham số không hợp lệ");
      return;
    }

    final layerIndex = currentLayerIndex.value;
    final fromLines = frames[fromIndex].layers[layerIndex].lines;
    final toLines = frames[toIndex].layers[layerIndex].lines;

    final maxLines = fromLines.length > toLines.length ? fromLines.length : toLines.length;
    final generatedFrames = <FrameModel>[];

    for (int s = 1; s <= steps; s++) {
      final t = s / (steps + 1);
      final tweenLines = <DrawnLine>[];

      for (int i = 0; i < maxLines; i++) {
        final a = i < fromLines.length ? fromLines[i] : DrawnLine(points: [], colorValue: Colors.black.value, width: 1);
        final b = i < toLines.length ? toLines[i] : DrawnLine(points: [], colorValue: Colors.black.value, width: 1);

        final minLen = a.points.length < b.points.length ? a.points.length : b.points.length;
        final points = <Offset>[];

        for (int j = 0; j < minLen; j++) {
          final p = Offset.lerp(a.points[j], b.points[j], t);
          points.add(p ?? a.points[j]);
        }

        // Nếu số điểm khác nhau → thêm các điểm dư từ frame dài hơn
        if (a.points.length > b.points.length) {
          points.addAll(a.points.sublist(minLen));
        } else if (b.points.length > a.points.length) {
          points.addAll(b.points.sublist(minLen));
        }

        tweenLines.add(
          DrawnLine(
            points: points,
            colorValue: Color.lerp(Color(a.colorValue), Color(b.colorValue), t)?.value ?? a.colorValue,
            width: a.width + (b.width - a.width) * t,
          ),
        );
      }

      final tweenFrame = FrameModel();
      tweenFrame.layers[layerIndex].lines = tweenLines;
      generatedFrames.add(tweenFrame);
    }

    frames.insertAll(fromIndex + 1, generatedFrames);
    _clearThumbnailCache();
    frames.refresh();
    Get.snackbar("Tween thành công", "Đã chèn $steps frame trung gian giữa $fromIndex và $toIndex");
  }



  Future<File?> renderThumbnailToFile(int frameIndex, String path) async {
    try {
      final bytes = await renderThumbnail(frameIndex);
      final file = File(path);
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      if (kDebugMode) {
        print("Error create thumbnail: $e");
      }
      return null;
    }
  }
  Future<void> showUploadDialogWithInfo(int fps, int userId) async {
    final nameController = TextEditingController(text: currentProjectName ?? "Video mới");
    File? thumbnailFile;

    int? selectedFrameIndex;

    await Get.dialog(
      AlertDialog(
        title: Text("Upload Video"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Video Name"),
              ),
              const SizedBox(height: 12),
              const Text("Select a frame to use as thumbnail (or skip to choose an image from device):"),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: frames.length,
                  itemBuilder: (_, index) {
                    return FutureBuilder<Uint8List>(
                      future: renderThumbnail(index),
                      builder: (_, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done || !snapshot.hasData) {
                          return const SizedBox(width: 80, child: Center(child: CircularProgressIndicator()));
                        }
                        return GestureDetector(
                          onTap: () => selectedFrameIndex = index,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedFrameIndex == index ? Colors.blue : Colors.grey,
                                width: 2,
                              ),
                            ),
                            child: Image.memory(snapshot.data!, width: 80),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(type: FileType.image);
                  if (result != null && result.files.single.path != null) {
                    thumbnailFile = File(result.files.single.path!);
                    Get.snackbar("Image selected", "The chosen image will be used as the thumbnail");
                  }
                },
                icon: const Icon(Icons.image),
                label: const Text("Choose image from device"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // đóng dialog

              final tempDir = await getTemporaryDirectory();
              final outputPath = p.join(tempDir.path, 'upload_video.mp4');
              final thumbPath = p.join(tempDir.path, 'background.png');

              // Tạo thumbnail từ frame nếu chọn
              if (selectedFrameIndex != null) {
                final bytes = await renderThumbnail(selectedFrameIndex!);
                thumbnailFile = await File(thumbPath).writeAsBytes(bytes);
              }

              // Tạo video
              await renderAllFramesToImages();
              await exportToVideoWithFFmpeg(fps);

              // Gọi UploadController
              final uploadController = Get.put(UploadController());
              uploadController.videoFile.value = File(outputPath);
              uploadController.backgroundFile.value = thumbnailFile;
              uploadController.nameController.text = nameController.text;
              uploadController.descriptionController.text = "Created from drawing app";

              await uploadController.uploadVideo(userId);
            },
            child: const Text("Upload video"),
          ),
        ],
      ),
    );
  }

  Future<List<Uint8List>> getAllFrameThumbnails() async {
    List<Uint8List> framesData = [];

    for (int i = frames.length - 1; i >= 0; i--) {
      final bytes = await renderThumbnail(i);
      if (kDebugMode) {
        print(" Thumbnail $i - size: ${bytes.length} bytes");
      } // để kiểm tra
      framesData.add(bytes);
    }

    return framesData;
  }



  void _clearThumbnailCache({int? frameIndex, int? layerIndex}) {
    if (frameIndex == null) {
      thumbnailCache.clear();
    } else {
      final key = layerIndex == null ? '$frameIndex' : '$frameIndex-$layerIndex';
      thumbnailCache.remove(key);
    }
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

Future<String?> _getProjectNameFromUser() async {
  TextEditingController controller = TextEditingController();

  return await Get.dialog<String>(
    AlertDialog(
      title: const Text("Enter Project Name"),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          hintText: "e.g., my_animation",
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: null),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Get.back(result: controller.text.trim()),
          child: const Text("Confirm"),
        ),
      ],
    ),
  );
}


Future<bool> _showPostCustomizationDialog(UploadController controller) async {
  return await Get.dialog<bool>(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Customize Your Post",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),

                // Title input
                TextField(
                  controller: controller.nameController,
                  decoration: InputDecoration(
                    labelText: "Video Title",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                SizedBox(height: 15),

                // Description input
                TextField(
                  controller: controller.descriptionController,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 25),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text("Cancel"),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => Get.back(result: true),
                      icon: Icon(Icons.upload),
                      label: Text("Upload"),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ) ?? false;
}



