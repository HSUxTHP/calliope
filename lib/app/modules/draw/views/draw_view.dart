import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/draw_controller.dart';
import 'canvas_area.dart';
import 'package:blur/blur.dart';

class DrawView extends StatefulWidget {
  const DrawView({super.key});

  @override
  State<DrawView> createState() => _DrawViewState();
}

class _DrawViewState extends State<DrawView> {
  final DrawController controller = Get.find();
  late final String projectId;

  @override
  void initState() {
    super.initState();
    projectId = Get.arguments as String;
    controller.loadFromProjectId(projectId); // ✅ Gọi đúng, chỉ 1 lần
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: Column(
        children: [
          _buildTopToolbar(),
          Expanded(
            child: Row(
              children: [
                Obx(
                  () =>
                      controller.isFrameListExpanded.value
                          ? _buildSidebar()
                          : _buildCollapsedSidebar(),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                const Expanded(child: CanvasArea()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopToolbar() {
    return Container(
      height: 58,
      width: double.infinity, // 👈 đảm bảo full width
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Obx(
        () => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 1200,
            ), // 👈 optional: đảm bảo cuộn tốt
            child: Row(
              children: [
                _toolbarGroup([
                  _iconButton(
                    Icons.arrow_back,
                    () => Get.back(),
                    tooltip: 'Quay lại',
                  ),
                ]),

                const SizedBox(width: 12),

                _toolbarGroup([
                  _iconButton(Icons.undo, controller.undo, tooltip: 'Hoàn tác'),
                  _iconButton(Icons.redo, controller.redo, tooltip: 'Làm lại'),
                  _iconButton(
                    Icons.clear,
                    controller.clearCanvas,
                    tooltip: 'Xoá canvas',
                  ),
                ]),

                const SizedBox(width: 12),

                _toolbarGroup([
                  _iconButton(
                    controller.showOnionSkin.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                    controller.toggleOnionSkin,
                    tooltip: "Bật/tắt Onion Skin",
                  ),
                  const SizedBox(width: 4),
                  const Text("Frame trước:", style: TextStyle(fontSize: 12)),
                  Slider(
                    value: controller.onionSkinCount.value.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: "${controller.onionSkinCount.value}",
                    onChanged:
                        (value) =>
                            controller.onionSkinCount.value = value.toInt(),
                  ),
                ]),

                const SizedBox(width: 12),

                _toolbarGroup([
                  _iconButton(
                    controller.currentToolIcon,
                    controller.toggleEraser,
                    tooltip: controller.currentToolTooltip,
                  ),
                  _iconButton(
                    Icons.color_lens,
                    () => _showColorPicker(Get.context!),
                    tooltip: 'Chọn màu',
                    color: controller.selectedColor.value,
                  ),
                ]),

                const SizedBox(width: 12),

                _roundedControl(
                  label: '${controller.selectedWidth.value.toInt()} px',
                  onMinus:
                      () => controller.changeWidth(
                        controller.selectedWidth.value - 1,
                      ),
                  onPlus:
                      () => controller.changeWidth(
                        controller.selectedWidth.value + 1,
                      ),
                ),

                const SizedBox(width: 8),

                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: IconButton(
                    icon: const Icon(
                      Icons.play_circle_fill,
                      size: 30,
                      color: Colors.black,
                    ),
                    onPressed: _showPreviewDialog, // 👈 Xem trước Animation
                    tooltip: 'Xem trước Animation',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),

                const SizedBox(width: 12),

                _toolbarGroup([
                  _iconButton(Icons.save, controller.copyFrameCurrent, tooltip: 'Sao chép frame'),
                  _iconButton(Icons.paste, controller.pasteCopiedFrame, tooltip: 'Dán frame'),
                  _iconButton(Icons.delete, () {
                    // Xác nhận xoá
                    Get.defaultDialog(
                      title: 'Xác nhận',
                      middleText: 'Bạn có chắc muốn xoá frame này?',
                      textCancel: 'Huỷ',
                      textConfirm: 'Xoá',
                      confirmTextColor: Colors.white,
                      onConfirm: () {
                        Get.back();
                        controller.deleteCurrentFrame();
                      },
                    );
                  }, tooltip: 'Xoá frame hiện tại'),
                ]),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconButton(
    IconData icon,
    VoidCallback onPressed, {
    String? tooltip,
    Color? color,
  }) {
    return IconButton(
      icon: Icon(icon, size: 20, color: color ?? Colors.black),
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }

  Widget _toolbarGroup(List<Widget> children) {
    return Row(
      children:
          children
              .map(
                (w) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: w,
                ),
              )
              .toList(),
    );
  }

  Widget _roundedControl({
    required String label,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
    Widget? trailing,
  }) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onMinus,
            child: const CircleAvatar(
              radius: 9,
              backgroundColor: Color(0xFFFFFFFF),
              child: Icon(Icons.remove, size: 12, color: Colors.black),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onPlus,
            child: const CircleAvatar(
              radius: 9,
              backgroundColor: Color(0xFFFFFFFF),
              child: Icon(Icons.add, size: 12, color: Colors.black),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildCollapsedSidebar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 1,
        child: IconButton(
          icon: const Icon(Icons.chevron_right, color: Colors.black),
          onPressed: controller.toggleFrameList,
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 200,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          _buildSidebarHeader(),
          Obx(
            () =>
                controller.isShowingLayout.value
                    ? const SizedBox(height: 8)
                    : _buildFrameToggle(),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(
              () =>
                  controller.isShowingLayout.value
                      ? _buildLayoutList()
                      : _buildFrameList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: const BoxDecoration(
        color: Color(0xFFE2E8F0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                _sidebarTab("Frame", false),
                _sidebarTab("Layout", true),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              controller.scrollToTop();
            },
            child: const Icon(Icons.menu, size: 18, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _sidebarTab(String label, bool layoutTab) {
    return Expanded(
      child: Obx(
        () => GestureDetector(
          onTap: () {
            controller.isShowingLayout.value = layoutTab;
            controller.scrollToTop();
          },
          child: Container(
            height: 36,
            margin: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color:
                  controller.isShowingLayout.value == layoutTab
                      ? Colors.white
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    controller.isShowingLayout.value == layoutTab
                        ? Colors.black
                        : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFrameToggle() {
    return ElevatedButton(
      onPressed: controller.addFrame,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade200,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
        elevation: 1,
      ),
      child: const Icon(Icons.add, size: 18, color: Colors.black),
    );
  }

  Widget _buildFrameList() {
    return ReorderableListView.builder(
      key: const PageStorageKey('frame_list_key'),
      onReorder: controller.reorderFrame,
      buildDefaultDragHandles: false,
      scrollController: controller.scrollController,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      itemCount: controller.frames.length,
      itemBuilder: (_, index) {
        final frame = controller.frames[index];
        final futureImage = controller.renderThumbnail(index);
        final itemKey = controller.frameItemKeys[index] ?? GlobalKey();
        controller.frameItemKeys[index] = itemKey;

        return Dismissible(
          key: ValueKey('frame_$index'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: Colors.red.withOpacity(0.1),
            child: const Icon(Icons.delete, color: Colors.red),
          ),
          confirmDismiss: (_) async {
            if (controller.frames.length <= 1) return false;
            return await Get.dialog<bool>(
                  AlertDialog(
                    title: const Text('Xác nhận xoá'),
                    content: const Text('Bạn có chắc muốn xoá frame này?'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text('Huỷ'),
                      ),
                      TextButton(
                        onPressed: () => Get.back(result: true),
                        child: const Text('Xoá'),
                      ),
                    ],
                  ),
                ) ??
                false;
          },
          onDismissed: (_) {
            Future.microtask(() {
              controller.removeFrame(index);
              if (controller.currentFrameIndex.value >=
                  controller.frames.length) {
                controller.selectFrame(controller.frames.length - 1);
              }
            });
          },
          child: ReorderableDragStartListener(
            index: index,
            child: KeyedSubtree(
              key: itemKey,
              child: Obx(
                () => _thumbnailItem(
                  isSelected: controller.currentFrameIndex.value == index,
                  onTap: () => controller.selectFrame(index),
                  futureImage: futureImage,
                  borderColor: Colors.blue,
                  isHidden: frame.isHidden,
                  onToggleVisibility:
                      () => controller.toggleFrameVisibility(index),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLayoutList() {
    final index = controller.currentFrameIndex.value;
    return ListView.builder(
      controller: controller.scrollController,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      itemCount: 3,
      itemBuilder: (_, layerIndex) {
        final isSelected = controller.currentLayerIndex.value == layerIndex;
        return _thumbnailItem(
          isSelected: isSelected,
          onTap: () => controller.switchLayer(layerIndex),
          futureImage: controller.renderThumbnail(index, layerIndex),
          borderColor: Colors.indigo,
        );
      },
    );
  }

  Widget _thumbnailItem({
    required bool isSelected,
    required VoidCallback onTap,
    required Future<Uint8List> futureImage,
    required Color borderColor,
    bool? isHidden,
    VoidCallback? onToggleVisibility,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? borderColor.withOpacity(0.05) : Colors.white,
              border: Border.all(
                color: isSelected ? borderColor : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: FutureBuilder<Uint8List>(
              future: futureImage,
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Opacity(
                      opacity: isHidden == true ? 0.4 : 1.0,
                      child: Image.memory(snapshot.data!, fit: BoxFit.cover),
                    ),
                  );
                }
                return const SizedBox(
                  height: 80,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 1.2),
                  ),
                );
              },
            ),
          ),
          if (onToggleVisibility != null)
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                onTap: onToggleVisibility,
                child: Icon(
                  isHidden == true ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                  color: Colors.black54,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showPreviewDialog() async {
    final frames = await controller.getAllFrameThumbnails();
    if (frames.isEmpty) {
      Get.snackbar("Lỗi", "Không có frame nào để xem trước");
      return;
    }

    int current = 0;
    int localFps = controller.fps;
    bool isPlaying = true;
    Timer? timer;

    showDialog(
      context: Get.context!,
      barrierDismissible: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            void startTimer() {
              timer?.cancel();
              timer = Timer.periodic(
                Duration(milliseconds: 1000 ~/ localFps),
                (_) => setState(() => current = (current + 1) % frames.length),
              );
              setState(() => isPlaying = true);
            }

            void stopTimer() {
              timer?.cancel();
              timer = null;
              setState(() => isPlaying = false);
            }

            if (timer == null && isPlaying) startTimer();

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: Container(
                width: 1100,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E2E).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 20)],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🖥 Video display
                    Container(
                      width: double.infinity,
                      height: 576,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12, width: 1),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          frames[current],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 🎬 Timeline (YouTube-style)
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Container(
                          height: 6,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade700,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double progress = current / (frames.length - 1);
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              width: constraints.maxWidth * progress,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          },
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 0,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 12,
                            ),
                          ),
                          child: Slider(
                            min: 0,
                            max: (frames.length - 1).toDouble(),
                            value: current.toDouble(),
                            onChanged: (value) {
                              stopTimer();
                              setState(() => current = value.toInt());
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 🔘 Control bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "FPS",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 160,
                              child: Slider(
                                min: 1,
                                max: 24,
                                divisions: 23,
                                value: localFps.toDouble(),
                                label: "$localFps",
                                onChanged: (value) {
                                  setState(() {
                                    localFps = value.toInt();
                                    if (isPlaying) startTimer();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isPlaying
                                    ? Icons.pause_circle
                                    : Icons.play_circle,
                                size: 36,
                                color:
                                    isPlaying
                                        ? Colors.redAccent
                                        : Colors.greenAccent,
                              ),
                              onPressed:
                                  () => isPlaying ? stopTimer() : startTimer(),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.movie_creation_outlined),
                              label: const Text("Xuất video"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                timer?.cancel();
                                Navigator.of(context).pop();
                                await controller.renderAllFramesToImages();
                                await controller.exportToVideoWithFFmpeg(
                                  localFps,
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.close),
                              label: const Text("Đóng"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade700,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                timer?.cancel();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) => timer?.cancel());
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Chọn màu'),
            content: SingleChildScrollView(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    [
                      Colors.black,
                      Colors.red,
                      Colors.green,
                      Colors.blue,
                      Colors.orange,
                      Colors.purple,
                      Colors.brown,
                      Colors.yellow,
                      Colors.pink,
                    ].map((color) {
                      return GestureDetector(
                        onTap: () {
                          controller.changeColor(color);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 1.5,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
    );
  }
}
