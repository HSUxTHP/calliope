import 'package:calliope/app/modules/draw/views/DrawingCanvas.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/draw_controller.dart';

class DrawView extends GetView<DrawController> {
  const DrawView({super.key});

  static const toolbarBgColor = Color(0xFFF0F0F0);
  static const sidebarBgColor = Color(0xFFF9FAFB);
  static const sidebarBorderColor = Color(0xFFE0E0E0);
  static const iconColor = Colors.black87;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Toolbar
          Container(
            width: 1200,
            height: 56,
            margin: const EdgeInsets.only(bottom: 20),
            color: toolbarBgColor,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final entry in [
                    {'icon': Icons.arrow_back, 'action': () {}},
                    null,
                    {'icon': Icons.settings, 'action': () {}},
                    {'icon': Icons.save, 'action': () {}},
                    {'icon': Icons.share, 'action': () {}},
                    {'icon': Icons.undo, 'action': controller.undo},
                    {'icon': Icons.redo, 'action': controller.redo},
                    {'icon': Icons.brush, 'action': () {}},
                  ])
                    if (entry != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: IconButton(
                          icon: Icon(entry['icon'] as IconData,
                              color: iconColor, size: 22),
                          onPressed: entry['action'] as VoidCallback,
                          splashRadius: 20,
                          tooltip: (entry['icon'] as IconData)
                              .codePoint
                              .toString(),
                        ),
                      )
                    else
                      Container(
                        height: 28,
                        width: 1.2,
                        color: Colors.grey.shade400,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                ],
              ),
            ),
          ),

          // Nội dung chính
          Expanded(
            child: Row(
              children: [
                // Sidebar trái với border bo tròn
                Container(
                  width: 180,
                  margin: EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: sidebarBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sidebarBorderColor, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Tabs Frame/Layout
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.only(bottom: 6),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom:
                                    BorderSide(color: Colors.black87, width: 1.2),
                                  ),
                                ),
                                child: const Text(
                                  'Frame',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: const Text(
                                'Layout',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Danh sách frame
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: ListView(
                            children: [
                              // Nút +
                              Container(
                                height: 36,
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xff256b8c),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),

                              // Frame mẫu
                              Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: sidebarBorderColor,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 36,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Material(
                                        color: Colors.grey.shade300,
                                        shape: const CircleBorder(),
                                        child: InkWell(
                                          customBorder: const CircleBorder(),
                                          onTap: () {},
                                          child: Padding(
                                            padding: const EdgeInsets.all(6),
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red.shade700,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Canvas bên phải
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DrawingCanvas(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
