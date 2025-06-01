import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/models/DrawnLine_model.dart';

mixin DrawFrameMixin on GetxController {
  final frameLayers = <List<List<DrawnLine>>>[].obs;
  final currentFrameIndex = 0.obs;
  final currentLayerIndex = 0.obs;
  RxSet<int> hiddenFrames = <int>{}.obs;
  RxSet<int> hiddenLayers = <int>{}.obs;

  final isShowingLayout = true.obs;
  final isFrameListExpanded = true.obs;
  final scrollController = ScrollController();

  List<List<DrawnLine>>? copiedFrame;

  void initializeFrame() {
    addFrame();
    selectFrame(0);
  }

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

  void copyFrameCurrent() => copyFrame(currentFrameIndex.value);

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

  void toggleFrameVisibility(int index) {
    if (hiddenFrames.contains(index)) {
      hiddenFrames.remove(index);
    } else {
      hiddenFrames.add(index);
    }
    hiddenFrames.refresh();
  }

  void toggleLayerVisibility(int index) {
    if (hiddenLayers.contains(index)) {
      hiddenLayers.remove(index);
    } else {
      hiddenLayers.add(index);
    }
    hiddenLayers.refresh();
  }

  bool isFrameHidden(int index) => hiddenFrames.contains(index);
  bool isLayerHidden(int index) => hiddenLayers.contains(index);

  void removeFrame(int index) {
    frameLayers.removeAt(index);
    frameLayers.refresh();
  }

  void toggleFrameList() => isFrameListExpanded.toggle();

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

  // placeholder to use lines and _clearThumbnailCache from controller
  final lines = <DrawnLine>[].obs;
  void _clearThumbnailCache() {}
}
