import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
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


class DrawController extends GetxController {
  final repaintKey = GlobalKey();
  final scrollController = ScrollController();

  final undoStack = <List<DrawnLine>>[];
  final redoStack = <List<DrawnLine>>[];

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


  void loadFromProjectId(String id) {
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

    final int newestFirstIndex = index;

    // 👉 Frame cũ hơn (quá khứ) – nằm **sau** trong danh sách
    for (int i = 1; i <= onionSkinRangeBefore; i++) {
      final idx = newestFirstIndex + i;
      if (idx >= 0 && idx < frames.length) {
        final lines = frames[idx].layers.expand((layer) => layer.lines).toList();
        double alpha = (1.0 - i / (onionSkinRangeBefore + 1)) * 0.5;
        onionLayers.add(MapEntry(lines, alpha));
      }
    }

    // 👉 Frame mới hơn (tương lai) – nằm **trước** trong danh sách
    for (int i = 1; i <= onionSkinRangeAfter; i++) {
      final idx = newestFirstIndex - i;
      if (idx >= 0 && idx < frames.length) {
        final lines = frames[idx].layers.expand((layer) => layer.lines).toList();
        double alpha = (1.0 - i / (onionSkinRangeAfter + 1)) * 0.3;
        onionLayers.add(MapEntry(lines, alpha));
      }
    }

    return onionLayers;
  }




  Future<void> loadProjectFromHive(String projectId) async {
    final savedProject = _box.get(projectId);
    if (savedProject != null) {
      frames.assignAll(savedProject.frames);
      currentFrameIndex.value = 0;
      currentLayerIndex.value = 0;
    }
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
  static const Size canvasSize = Size(1600, 900);

  IconData get currentToolIcon => isEraser.value ?  Icons.brush : MdiIcons.eraser ;
  String get currentToolTooltip => isEraser.value ? 'Bút' : 'Tẩy';

  @override
  void onInit() {
    super.onInit();
    addFrame();
    selectFrame(0);
  }

  void startStroke(Offset point) {
    undoStack.add(List.from(currentLines.map((l) => l.copy())));
    redoStack.clear();
    final color = isEraser.value ? Colors.white : selectedColor.value;
    currentLines.add(DrawnLine(points: [point], colorValue: color.value, width: selectedWidth.value));
  }


  void addPoint(Offset point) {
    if (currentLines.isNotEmpty) {
      currentLines.last.points.add(point);
      _clearThumbnailCache(frameIndex: currentFrameIndex.value);

      final index = currentFrameIndex.value;
      frames[index] = frames[index]; // 👈 chỉ cập nhật frame hiện tại
    }
  }


  void endStroke() {
    if (currentLines.isNotEmpty) {
      final index = currentFrameIndex.value;
      frames[index] = frames[index]; // 👈 chỉ update frame hiện tại

      saveCurrentFrame();

      if (currentProjectId != null && currentProjectName != null) {
        saveProjectToHive(currentProjectId!, currentProjectName!);
      }
    }
  }





  void undo() {
    if (undoStack.isNotEmpty) {
      redoStack.add(List.from(currentLines.map((l) => l.copy())));
      currentLines = undoStack.removeLast();
      frames.refresh();
    }
  }
  void redo() {
    if (redoStack.isNotEmpty) {
      undoStack.add(List.from(currentLines.map((l) => l.copy())));
      currentLines = redoStack.removeLast();
      frames.refresh();
    }
  }

  void clearCanvas() {
    undoStack.add(List.from(currentLines.map((l) => l.copy())));
    currentLines.clear();
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


  void selectFrame(int index) {
    if (index == currentFrameIndex.value) return;

    saveCurrentFrame();
    currentFrameIndex.value = index;
    currentLayerIndex.value = 0;

    final context = frameItemKeys[index]?.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
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

    // ✅ Ghi lại vào Hive sau khi paste
    if (currentProjectId != null && currentProjectName != null) {
      saveProjectToHive(currentProjectId!, currentProjectName!);
    }
  }

  void reorderFrame(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;

    final item = frames.removeAt(oldIndex);
    frames.insert(newIndex, item);

    // ✅ Xoá cache thumbnail (QUAN TRỌNG)
    _clearThumbnailCache();
    frames.refresh();

    // ✅ Giữ frame đang chọn đúng vị trí mới
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

    // ✅ Thêm để xóa thumbnail cache và làm mới UI
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

    // ✅ Gọi lại render thumbnail để cập nhật UI
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
    if (frameIndex < 0 || frameIndex >= frames.length) {
      throw ArgumentError('Invalid frameIndex: $frameIndex');
    }

    final cacheKey = layerIndex == null ? '$frameIndex' : '$frameIndex-$layerIndex';
    if (thumbnailCache.containsKey(cacheKey)) return thumbnailCache[cacheKey]!;

    const double thumbWidth = 640;
    const double thumbHeight = 360;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, thumbWidth, thumbHeight));

    // ✅ Tính scale theo cả chiều rộng và chiều cao
    final scaleX = thumbWidth / canvasSize.width;
    final scaleY = thumbHeight / canvasSize.height;
    canvas.scale(scaleX, scaleY);

    // ✅ Vẽ nền trắng
    canvas.drawColor(Colors.white, BlendMode.src);

    try {
      if (layerIndex == null) {
        for (int i = 0; i < 3; i++) {
          Sketcher(lines: frames[frameIndex].layers[i].lines).paint(canvas, canvasSize);
        }
      } else {
        Sketcher(lines: frames[frameIndex].layers[layerIndex].lines).paint(canvas, canvasSize);
      }

      final picture = recorder.endRecording();
      final image = await picture.toImage(thumbWidth.toInt(), thumbHeight.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception("Failed to encode image to byteData");

      final bytes = byteData.buffer.asUint8List();
      thumbnailCache[cacheKey] = bytes;
      return bytes;
    } catch (e) {
      print("❌ Lỗi khi render thumbnail frame $frameIndex: $e");
      return Uint8List(0);
    }
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

      for (int l = 0; l < 3; l++) {
        if (!isLayerHidden(l)) {
          Sketcher(lines: frames[i].layers[l].lines).paint(canvas, canvasSize);
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

  Future<void> exportToVideoWithFFmpeg(int fps) async {
    bool granted = await ensureStoragePermission();
    if (!granted) {
      print("Chưa cấp quyền lưu trữ");
      Get.snackbar("Lỗi", "Chưa cấp quyền lưu trữ", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // 🔹 Chọn thư mục lưu
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) {
      Get.snackbar("Hủy", "Bạn chưa chọn thư mục", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final framesDir = Directory(p.join(selectedDirectory, "frames"));
    if (!await framesDir.exists()) {
      await framesDir.create(recursive: true);
    }

    // 🔹 Render các frame theo thứ tự NGƯỢC LẠI (frame mới nhất → cũ nhất)
    for (int i = frames.length - 1; i >= 0; i--) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));

      canvas.drawColor(Colors.white, BlendMode.src); // nền trắng

      for (int l = 0; l < 3; l++) {
        if (!isLayerHidden(l)) {
          Sketcher(lines: frames[i].layers[l].lines).paint(canvas, canvasSize);
        }
      }

      final picture = recorder.endRecording();
      final image = await picture.toImage(canvasSize.width.toInt(), canvasSize.height.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      // Sắp tên ngược: frame_000.png, frame_001.png,... để FFmpeg nhận đúng thứ tự
      final index = frames.length - 1 - i; // đổi ngược index
      final filePath = p.join(framesDir.path, 'frame_${index.toString().padLeft(3, '0')}.png');
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
  Future<void> uploadVideoToProfile(int fps, int userId) async {
    final tempDir = await getTemporaryDirectory();
    final framesDir = Directory(p.join(tempDir.path, "upload_frames"));
    if (!await framesDir.exists()) {
      await framesDir.create(recursive: true);
    }

    // Bước 1: Render các frame thành ảnh
    for (int i = frames.length - 1; i >= 0; i--) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));
      canvas.drawColor(Colors.white, BlendMode.src);

      for (int l = 0; l < 3; l++) {
        if (!isLayerHidden(l)) {
          Sketcher(lines: frames[i].layers[l].lines).paint(canvas, canvasSize);
        }
      }

      final picture = recorder.endRecording();
      final image = await picture.toImage(canvasSize.width.toInt(), canvasSize.height.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final filePath = p.join(framesDir.path, 'frame_${(frames.length - 1 - i).toString().padLeft(3, '0')}.png');
      await File(filePath).writeAsBytes(bytes);
    }

    // Bước 2: Tạo video từ ảnh
    final outputPath = p.join(tempDir.path, 'upload_video.mp4');
    final cmd =
        "-y -framerate $fps -start_number 0 -i ${framesDir.path}/frame_%03d.png "
        "-vf scale='trunc(iw/2)*2:trunc(ih/2)*2' "
        "-c:v libx264 -pix_fmt yuv420p $outputPath";

    final session = await FFmpegKit.execute(cmd);
    final returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      Get.snackbar("Lỗi", "Không tạo được video để đăng", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Bước 3: Gọi UploadController để upload
    final uploadController = Get.put(UploadController());
    uploadController.videoFile.value = File(outputPath);

    // Option: render thumbnail từ frame đầu
    final thumbPath = p.join(tempDir.path, 'background.png');
    final thumb = await renderThumbnailToFile(0, thumbPath);
    if (thumb != null) uploadController.backgroundFile.value = thumb;

    uploadController.nameController.text = currentProjectName ?? 'Video mới';
    uploadController.descriptionController.text = 'Tạo từ ứng dụng vẽ';
    await uploadController.uploadVideo(userId);
  }
  Future<File?> renderThumbnailToFile(int frameIndex, String path) async {
    try {
      final bytes = await renderThumbnail(frameIndex);
      final file = File(path);
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      print("❌ Lỗi tạo thumbnail: $e");
      return null;
    }
  }
  Future<void> showUploadDialogWithInfo(int fps, int userId) async {
    final nameController = TextEditingController(text: currentProjectName ?? "Video mới");
    File? thumbnailFile;

    int? selectedFrameIndex;

    await Get.dialog(
      AlertDialog(
        title: const Text("Đăng video lên hồ sơ"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Tên video"),
              ),
              const SizedBox(height: 12),
              const Text("Chọn frame làm thumbnail (hoặc bỏ qua để chọn ảnh từ máy):"),
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
                    Get.snackbar("Đã chọn ảnh", "Ảnh từ máy sẽ được dùng làm thumbnail");
                  }
                },
                icon: const Icon(Icons.image),
                label: const Text("Chọn ảnh từ máy"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Huỷ")),
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
              uploadController.descriptionController.text = "Tạo từ ứng dụng vẽ";

              await uploadController.uploadVideo(userId);
            },
            child: const Text("Đăng video"),
          ),
        ],
      ),
    );
  }

  Future<List<Uint8List>> getAllFrameThumbnails() async {
    List<Uint8List> framesData = [];

    for (int i = frames.length - 1; i >= 0; i--) {
      final bytes = await renderThumbnail(i);
      print("📸 Thumbnail $i - size: ${bytes.length} bytes"); // để kiểm tra
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
