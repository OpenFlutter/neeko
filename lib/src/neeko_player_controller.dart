import 'dart:io';

import 'package:video_player/video_player.dart';

class NeekoVideoPlayerValue extends VideoPlayerValue {}

class NeekoPlayerController extends VideoPlayerController {
  NeekoPlayerController.asset(String dataSource,{String package}) : super.asset(dataSource,package:package);

  NeekoPlayerController.network(String dataSource) : super.network(dataSource);

  NeekoPlayerController.file(File file) : super.file(file);

  String displayName;

  bool isFullScreen;

  /// Forces to enter fullScreen.
  void enterFullScreen() {
    isFullScreen = true;
  }

  /// Forces to exit fullScreen.
  void exitFullScreen() {
    isFullScreen = false;
  }
}
