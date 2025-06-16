import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/draw_controller.dart';

void showColorPicker(BuildContext context, DrawController controller) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Color Picker'),
      content: SingleChildScrollView(
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            Colors.black,
            Colors.red,
            Colors.green,
            Colors.blue,
            Colors.orange,
            Colors.purple,
            Colors.brown,
            Colors.yellow,
            Colors.pink
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
                  border: Border.all(width: 1.5, color: Colors.grey.shade300),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ),
  );
}
