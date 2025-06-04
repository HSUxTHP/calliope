import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

import '../controllers/watch_controller.dart';

class WatchView extends GetView<WatchController> {
  final BetterPlayerController? _playerController;

  WatchView({Key? key})
      : _playerController = null,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          final video = controller.post.value!;
          final dataSource = BetterPlayerDataSource(
            BetterPlayerDataSourceType.network,
            video.url,
            useAsmsSubtitles: true,
            useAsmsTracks: true,
            videoFormat: BetterPlayerVideoFormat.hls,
          );
          final _controller = BetterPlayerController(
            const BetterPlayerConfiguration(
              aspectRatio: 16 / 9,
              autoPlay: true,
              looping: true,
              fit: BoxFit.contain,
              controlsConfiguration: BetterPlayerControlsConfiguration(
                enableFullscreen: false,
              ),
            ),
            betterPlayerDataSource: dataSource,
          );
          return SingleChildScrollView(
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: BetterPlayer(controller: _controller),
                ),
                // ListView(
                //   padding: const EdgeInsets.all(12),
                //   children: [
                //     Text(video.name, style: const TextStyle(
                //         fontSize: 18, fontWeight: FontWeight.bold)),
                //     const SizedBox(height: 8),
                //     Text(video.description ?? ''),
                //     const SizedBox(height: 8),
                //     Text("Lượt xem: ${video.views}"),
                //   ],
                // ),
              ],
            ),
          );
        }),
      ),
    );
  }
}