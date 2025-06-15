import 'dart:async';
import 'dart:typed_data';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../profile/controllers/profile_controller.dart';
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
      backgroundColor: Color(Theme.of(context).colorScheme.surface.value),
      body: Column(
        children: [
          _buildTopToolbar(),
          Expanded(
            child: Row(
              children: [
                Obx(() =>
                controller.isFrameListExpanded.value
                    ? _buildSidebar()
                    : _buildCollapsedSidebar(),
                ),
                // const VerticalDivider(width: 1, thickness: 1), // xóa dòng này để không hiện đường chia
                Expanded(child: CanvasArea()),
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
        color: Color(Theme.of(context).colorScheme.surfaceContainer.value),
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
                  if (controller.showOnionSkin.value) ...[
                    const SizedBox(width: 4),
                    const Text("OnionSkin:", style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: controller.onionSkinCount.value,
                      items: List.generate(5, (index) {
                        final value = index + 1;
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(
                              '$value',
                              style: TextStyle(fontSize: 13, color: Color(Theme.of(context).colorScheme.onSurface.value))
                          ),
                        );
                      }),
                      onChanged: (value) {
                        if (value != null) {
                          controller.onionSkinCount.value = value;
                        }
                      },
                      style: const TextStyle(fontSize: 13, color: Colors.black),
                      underline: Container(
                        height: 1,
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ]

                ]),
                const SizedBox(width: 12),

                _toolbarGroup([
                  Obx(() => _iconButton(
                    Icons.brush,
                    controller.selectBrush,
                    isActive: controller.selectedTool.value == ToolType.brush,
                    tooltip: 'Bút',
                  )),
                  Obx(() => _iconButton(
                    MdiIcons.eraser,
                    controller.selectEraser,
                    isActive: controller.selectedTool.value == ToolType.eraser,
                    tooltip: 'Tẩy',
                  )),
        Obx(() {
          final selectedColor = controller.selectedColor.value;

          final isBright = selectedColor.computeLuminance() > 0.5;
          final bgColor = isBright ? Colors.black : Colors.white;
          final iconColor = selectedColor; // icon mang đúng màu đã chọn

          return GestureDetector(
            onTap: () => _showColorPicker(context),
            child: Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bgColor, // 👈 Nền ngược với màu đang chọn
              ),
              child: Center(
                child: Icon(
                  Icons.color_lens,
                  size: 20,
                  color: iconColor, // 👈 icon luôn mang màu đã chọn
                ),
              ),
            ),
          );
        })




        ]),




                const SizedBox(width: 12),

                DropdownButton<int>(
                  value: controller.selectedWidth.value.toInt(),
                  onChanged: (value) {
                    if (value != null) controller.changeWidth(value.toDouble());
                  },
                  items: List.generate(30, (i) => i + 1)
                      .map((val) => DropdownMenuItem<int>(
                    value: val,
                    child: Text('$val px'),
                  ))
                      .toList(),
                  underline: Container(height: 1, color: Color(Theme.of(context).colorScheme.surfaceContainer.value)),
                  style: TextStyle(fontSize: 16, color: Color(Theme.of(context).colorScheme.onSurface.value)),
                ),

                const SizedBox(width: 8),

                const SizedBox(width: 12),

                _toolbarGroup([
                  _iconButton(
                    Icons.copy,
                    controller.copyFrameCurrent,
                    tooltip: 'Sao chép frame',
                  ),
                  _iconButton(
                    Icons.content_paste,
                    controller.pasteCopiedFrame,
                    tooltip: 'Dán frame',
                  ),
                  _iconButton(
                    Icons.play_circle_fill,
                    _showPreviewDialog,
                    tooltip: 'Xem trước Animation',
                  ),
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
        bool isActive = false, // ✅ Thêm dòng này
        Color? color,
      }) {
    return IconButton(
      icon: Icon(
        icon,
        size: 20,
        color: color ?? (isActive ? Colors.blue : Color(Theme.of(context).colorScheme.onSurface.value)),
      ),
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
        color: Color(Theme.of(context).colorScheme.surfaceContainer.value),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(Theme.of(context).colorScheme.onSurface.value)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onMinus,
            child: CircleAvatar(
              radius: 9,
              backgroundColor: Color(Theme.of(context).colorScheme.surfaceContainer.value),
              child: Icon(Icons.remove, size: 12, color: Color(Theme.of(context).colorScheme.onSurface.value)),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(Theme.of(context).colorScheme.onSurface.value),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onPlus,
            child: CircleAvatar(
              radius: 9,
              backgroundColor: Color(Theme.of(context).colorScheme.surfaceContainer.value),
              child: Icon(Icons.add, size: 12, color: Color(Theme.of(context).colorScheme.onSurface.value)),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildCollapsedSidebar() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, top: 24),
        child: Material(
          color: Color(Theme.of(context).colorScheme.surfaceContainer.value),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 1,
          child: SizedBox(
            width: 30,  // Tăng chiều rộng vùng chứa
            height: 30, // Tăng chiều cao vùng chứa
            child: IconButton(
              padding: EdgeInsets.zero, // bỏ padding mặc định để icon không bị co lại
              icon: Icon(
                Icons.chevron_right,
                size: 20,
                color: Color(Theme.of(context).colorScheme.onSurface.value),
              ),
              onPressed: controller.toggleFrameList,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
      ),
    );
  }




  Widget _buildSidebar() {
    return Container(
      width: 200,
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(Theme.of(context).colorScheme.surfaceContainer.value),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(Theme.of(context).colorScheme.onSurface.value), width: 1.2),
      ),
      child: Column(
        children: [
          _buildSidebarHeader(),
          Obx(
                () =>
            controller.isShowingLayout.value
                ? const SizedBox(height: 8)
                : _buildFrameToggle(), // ✅ Nút + vẫn ở trên
          ),
          const SizedBox(height: 8),

          // ✅ Danh sách Frame hoặc Layout
          Expanded(
            child: Obx(
                  () =>
              controller.isShowingLayout.value
                  ? _buildLayoutList()
                  : Column(
                children: [
                  // 📄 Danh sách frame
                  Expanded(child: _buildFrameList()),

                  // ✅ Nút bật/tắt chế độ reorder ở CUỐI
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildReorderToggleButton(),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        tooltip: 'Xoá frame hiện tại',
                        onPressed: () {
                          if (controller.frames.length <= 1) {
                            Get.snackbar("Thông báo", "Bạn cần ít nhất 1 frame");
                            return;
                          }
                          Get.defaultDialog(
                            title: 'Xác nhận',
                            middleText:
                            'Bạn có chắc muốn xoá frame hiện tại?',
                            textCancel: 'Huỷ',
                            textConfirm: 'Xoá',
                            confirmTextColor: Colors.white,
                            onConfirm: () {
                              Get.back();
                              controller.deleteCurrentFrame();
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReorderToggleButton() {
    return Obx(
          () {
        final isEditing = controller.isReorderMode.value;
        final colorScheme = Theme.of(Get.context!).colorScheme;

        return ElevatedButton.icon(
          onPressed: controller.toggleReorderMode,
          style: ElevatedButton.styleFrom(
            backgroundColor: isEditing
                ? colorScheme.primaryContainer
                : colorScheme.surfaceVariant,
            foregroundColor: isEditing
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          icon: Icon(
            isEditing ? Icons.lock_open : Icons.lock_outline,
            size: 18,
          ),
          label: Text(
            isEditing ? 'Tắt Chỉnh Sửa' : 'Chỉnh Sửa',
            style: const TextStyle(fontSize: 13),
          ),
        );
      },
    );
  }


  Widget _buildSidebarHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 2  ),
      decoration: BoxDecoration(
        color: Color(Theme.of(context).colorScheme.surface.value),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
          Padding(
            padding: const EdgeInsets.only(right: 4), // 👈 hoặc EdgeInsets.zero nếu muốn sát mép
            child: IconButton(
              icon: const Icon(Icons.menu, size: 20),
              tooltip: 'Thu gọn sidebar',
              onPressed: () => controller.isFrameListExpanded.value = false,
              color: Theme.of(context).colorScheme.onSurface,
              visualDensity: VisualDensity.compact, // 👈 gọn hơn
            ),
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
    return Obx(() => ReorderableListView.builder(
      key: ValueKey(controller.isReorderMode.value), // 👈 force rebuild khi toggle
      onReorder: controller.reorderFrame,
      buildDefaultDragHandles: false,
      scrollController: controller.scrollController,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      itemCount: controller.frames.length,
      itemBuilder: (_, index) {
        final frame = controller.frames[index];
        final futureImage = controller.renderThumbnail(index);
        final isSelected = controller.currentFrameIndex.value == index;

        final thumbnail = _thumbnailItem(
          isSelected: isSelected,
          onTap: () => controller.selectFrame(index),
          futureImage: futureImage,
          borderColor: Colors.blue,
          isHidden: frame.isHidden,
          onToggleVisibility: () => controller.toggleFrameVisibility(index),
        );

        if (controller.isReorderMode.value) {
          return KeyedSubtree(
            key: ValueKey('frame_$index'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.drag_indicator, color: Colors.grey, size: 20),
                  const SizedBox(width: 4),
                  Expanded(
                    child: ReorderableDragStartListener(
                      index: index,
                      child: thumbnail,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return KeyedSubtree(
          key: ValueKey('frame_$index'),
          child: thumbnail,
        );
      },
    ));
  }


  Widget _buildLayoutList() {
    final index = controller.currentFrameIndex.value;
    return ListView.builder(
      controller: controller.scrollController,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      itemCount: 3,
      itemBuilder: (_, layerIndex) {
        return Obx(() {
          final isSelected = controller.currentLayerIndex.value == layerIndex;
          return _thumbnailItem(
            isSelected: isSelected,
            onTap: () => controller.switchLayer(layerIndex),
            futureImage: controller.renderThumbnail(index, layerIndex),
            borderColor: Colors.indigo,
          );
        });
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
                            double progress = frames.length <= 1 ? 0 : current / (frames.length - 1);
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

                                final result = await showDialog<String>(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Chọn nơi lưu video"),
                                      content: const Text("Bạn muốn lưu video về máy hay đăng lên hồ sơ cá nhân?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop("local"),
                                          child: const Text("💾 Lưu về máy"),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop("upload"),
                                          child: const Text("📤 Đăng lên profile"),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text("Huỷ"),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (result == null) return;

                                Navigator.of(context).pop(); // đóng dialog preview

                                await controller.renderAllFramesToImages();

                                if (result == "local") {
                                  await controller.exportToVideoWithFFmpeg(localFps);
                                } else if (result == "upload") {
                                  final profileCtrl = Get.find<ProfileController>();
                                  final userIdStr = profileCtrl.currentUser.value?.id;

                                  if (userIdStr == null) {
                                    Get.snackbar("Lỗi", "Không tìm thấy userId hiện tại");
                                    return;
                                  }

                                  final userId = int.tryParse(userIdStr);
                                  if (userId == null) {
                                    Get.snackbar("Lỗi", "ID người dùng không hợp lệ: $userIdStr");
                                    return;
                                  }

                                  await controller.uploadVideoToProfile(localFps, userId);
                                }
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
  final List<Color> recentColors = [];

  void _showColorPicker(BuildContext context) {
    Color selectedColor = controller.selectedColor.value;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chọn màu vẽ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🎨 Giao diện picker chuẩn như hình
              ColorPicker(
                color: selectedColor,
                onColorChanged: (Color color) {
                  controller.changeColor(color);

                  // 🕹️ Cập nhật danh sách màu đã dùng
                  if (!recentColors.contains(color)) {
                    recentColors.insert(0, color);
                    if (recentColors.length > 10) {
                      recentColors.removeLast();
                    }
                  }
                },
                pickersEnabled: const {
                  ColorPickerType.wheel: true,
                },
                enableShadesSelection: true,  // ✅ giữ dải màu gợi ý bên dưới như ảnh
                enableOpacity: false,
                showColorCode: false,
                width: 36,
                height: 36,
                spacing: 8,
                runSpacing: 8,
                borderRadius: 8,
              ),

              const SizedBox(height: 16),

              // ✅ Dòng màu đã dùng
              if (recentColors.isNotEmpty) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text('Màu đã dùng:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: recentColors.map((color) {
                    return GestureDetector(
                      onTap: () {
                        controller.changeColor(color);
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade400, width: 1),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ]
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

}
