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
          // Thanh công cụ trên cùng, full width
          Container(
            height: 56,
            color: toolbarBgColor,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final iconData in [
                    Icons.arrow_back,
                    Icons.settings,
                    Icons.save,
                    Icons.share,
                    null,
                    Icons.undo,
                    Icons.redo,
                    null,
                    Icons.crop_square_outlined,
                    Icons.show_chart,
                    Icons.change_circle_outlined,
                    null,
                    Icons.brush,
                    Icons.format_color_fill,
                    Icons.text_fields,
                    Icons.edit,
                    Icons.crop_square,
                    Icons.circle_outlined,
                    Icons.change_history_outlined,
                  ])
                    if (iconData != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: IconButton(
                          icon: Icon(iconData, color: iconColor, size: 22),
                          onPressed: () {},
                          splashRadius: 20,
                          tooltip: iconData.codePoint.toString(),
                        ),
                      )
                    else
                      Container(
                        height: 28,
                        width: 1.2,
                        color: Colors.grey.shade400,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                      ),

                  // Nút hình tròn đỏ
                  Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.shade300.withOpacity(0.6),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: IconButton(
                      icon: Icon(Icons.mic, color: iconColor, size: 22),
                      onPressed: () {},
                      splashRadius: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Phần nội dung bên dưới: sidebar trái và canvas bên phải
          Expanded(
            child: Row(
              children: [
                // Sidebar trái
                Container(
                  width: 180,
                  decoration: BoxDecoration(
                    color: sidebarBgColor,
                    border: Border(
                      right: BorderSide(color: sidebarBorderColor, width: 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Tabs Frame & Layout (nằm dưới thanh công cụ)
                      Container(
                        color: Colors.white,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.black87, width: 1.2),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Frame',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                child: const Center(
                                  child: Text(
                                    'Layout',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // List các frame
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(12),
                          children: [
                            // Nút thêm Frame +
                            Container(
                              height: 72,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xff256b8c),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
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

                            // Frame đã thêm
                            Container(
                              height: 72,
                              decoration: BoxDecoration(
                                border: Border.all(color: sidebarBorderColor, width: 1),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  )
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
                    ],
                  ),
                ),

                // Canvas bên phải
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
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
