import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'video_controller_wrapper.dart';

Widget fullScreenRoutePageBuilder(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    VideoControllerWrapper videoControllerWrapper) {
  return _FullscreenPlayer(videoControllerWrapper: videoControllerWrapper,);
}
//
//void pushFullScreenWidget() {
//  final TransitionRoute<void> route = PageRouteBuilder<void>(
//    settings: RouteSettings(name: "neeko", isInitialRoute: false),
//    pageBuilder: fullScreenRoutePageBuilder,
//  );
//
//  route.completed.then((void value) {
////      controller.setVolume(0.0);
//  });
//
////    controller.setVolume(1.0);
//  Navigator.of(context).push(route);
//}

class _FullscreenPlayer extends StatefulWidget {
  final VideoControllerWrapper videoControllerWrapper;

  const _FullscreenPlayer({Key key, this.videoControllerWrapper})
      : super(key: key);

  @override
  __FullscreenPlayerState createState() => __FullscreenPlayerState();
}

class __FullscreenPlayerState extends State<_FullscreenPlayer> {
  VideoPlayerController get controller =>
      widget.videoControllerWrapper.controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 3 / 2,
        child: Hero(
          tag: "neekoPlayerHeroTag",
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}
