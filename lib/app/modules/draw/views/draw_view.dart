import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/draw_controller.dart';

class DrawView extends GetView<DrawController> {
  const DrawView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DrawView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'DrawView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
