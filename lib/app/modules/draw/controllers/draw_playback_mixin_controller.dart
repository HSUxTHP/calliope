import 'dart:async';
import 'package:get/get.dart';
import '../../../data/models/DrawnLine_model.dart';

mixin DrawPlaybackMixin on GetxController {
  final isPlaying = false.obs;
  final playbackSpeed = 6.obs;
  Timer? _playbackTimer;
  int _currentIndex = 0;
  int fps = 6;

  final lines = <DrawnLine>[].obs;
  final frameLayers = <List<List<DrawnLine>>>[].obs;
  final currentFrameIndex = 0.obs;
  final currentLayerIndex = 0.obs;

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

  void disposePlayback() {
    _playbackTimer?.cancel();
  }
}
