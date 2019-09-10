import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:neeko/src/progress_bar.dart';
import 'package:video_player/video_player.dart';

import 'neeko_fullscreen_player.dart';
import 'neeko_player.dart';
import 'neeko_player_controller.dart';
import 'neeko_player_options.dart';
import 'video_controller_widgets.dart';
import 'video_controller_wrapper.dart';

///core video player
class NeekoPlayerWidget extends StatefulWidget {
  final VideoControllerWrapper videoControllerWrapper;

  final NeekoPlayerController videoPlayerController;
  final NeekoPlayerOptions playerOptions;

  /// Defines the width of the player.
  /// Default = Devices's Width
  final double width;

  ///The duration for which controls in the player will be visible.
  ///default 3 seconds
  final Duration controllerTimeout;

  /// Overrides the default buffering indicator for the player.
  final Widget bufferIndicator;

  final Color liveUIColor;

  /// Defines the aspect ratio to be assigned to the player. This property along with [width] calculates the player size.
  /// Default = 16/9
  final double aspectRatio;

  /// Adds custom top bar widgets
  final List<Widget> actions;

  /// Video starts playing from the duration provided.
  final Duration startAt;

  final bool inFullScreen;

  final Function onPortraitBackTap;

  final Color progressBarPlayedColor;
  final Color progressBarBufferedColor;
  final Color progressBarHandleColor;
  final Color progressBarBackgroundColor;

  NeekoPlayerWidget(
      {Key key,
      @required this.videoControllerWrapper,
      @required this.videoPlayerController,
      this.playerOptions = const NeekoPlayerOptions(),
      this.controllerTimeout = const Duration(seconds: 3),
      this.bufferIndicator,
      this.liveUIColor = Colors.red,
      this.aspectRatio = 16 / 9,
      this.width,
      this.actions,
      this.startAt = const Duration(seconds: 0),
      this.inFullScreen = false,
      this.onPortraitBackTap,
      this.progressBarPlayedColor,
      this.progressBarBufferedColor: const Color(0xFF757575),
      this.progressBarHandleColor,
      this.progressBarBackgroundColor: const Color(0xFFF5F5F5)})
      : assert(videoPlayerController != null),
        assert(playerOptions != null),
        super(key: key);

  @override
  _NeekoPlayerWidgetState createState() => _NeekoPlayerWidgetState();
}

class _NeekoPlayerWidgetState extends State<NeekoPlayerWidget> {
  final _showControllers = ValueNotifier<bool>(false);

  Timer _timer;

  VideoPlayerController get controller =>
      widget.videoControllerWrapper.controller;

  VideoControllerWrapper get videoControllerWrapper =>
      widget.videoControllerWrapper;

  bool _inFullScreen = false;

  bool _firstLoad = true;

  @override
  void initState() {
    super.initState();
    _loadController();
    _showControllers.addListener(() {
      _timer?.cancel();
      if (_showControllers.value) {
        _timer = Timer(
          widget.controllerTimeout,
          () => _showControllers.value = false,
        );
      }
    });

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _inFullScreen = widget.inFullScreen;
    });

    _configureVideoPlayer();
  }

  void _loadController() {
//    controller = widget.videoPlayerController;
//    controller.isFullScreen = widget.inFullScreen ?? false;
//    controller.addListener(_listener);
  }

  _configureVideoPlayer() {
    if (widget.playerOptions.autoPlay) {
      _autoPlay();
    }

//    widget.videoPlayerController.setLooping(widget.playerOptions.loop);
  }

  void _listener() async {
//    if(_firstLoad){
//      _firstLoad = false;
//
//    }

//
  }

  _autoPlay() async {
    await controller.initialize();
    if (controller.value.initialized) {
      if (widget.startAt != null) {
        await controller.seekTo(widget.startAt);
      }
      controller.play();
    }
  }

  @override
  void dispose() {
//    if (widget.playerOptions.autoPlay) {
//      controller.dispose();
//    }

//    _showControllers.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildFullScreenVideo() {
    return Scaffold(
      appBar: AppBar(
        title: Text("title full"),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 3 / 2,
          child: Hero(
            tag: controller,
            child: VideoPlayer(controller),
          ),
        ),
      ),
    );
  }

//  Widget fullScreenRoutePageBuilder(
//      BuildContext context,
//      Animation<double> animation,
//      Animation<double> secondaryAnimation,
//      ) {
//    return _buildFullScreenVideo();
//  }

  void pushFullScreenWidget() {
    final TransitionRoute<void> route = PageRouteBuilder<void>(
      settings: RouteSettings(name: "neeko", isInitialRoute: false),
      pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) =>
          fullScreenRoutePageBuilder(
        context: context,
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        videoControllerWrapper: widget.videoControllerWrapper,
        width: widget.width,
        actions: widget.actions,
        aspectRatio: widget.aspectRatio,
        bufferIndicator: widget.bufferIndicator,
        controllerTimeout: widget.controllerTimeout,
        playerOptions: NeekoPlayerOptions(
            enableDragSeek: widget.playerOptions.enableDragSeek,
            showFullScreenButton: widget.playerOptions.showFullScreenButton,
            autoPlay: true,
            useController: widget.playerOptions.useController,
            isLive: widget.playerOptions.isLive,
            preferredOrientationsWhenEnterLandscape:
                widget.playerOptions.preferredOrientationsWhenEnterLandscape,
            preferredOrientationsWhenExitLandscape:
                widget.playerOptions.preferredOrientationsWhenExitLandscape,
            enabledSystemUIOverlaysWhenEnterLandscape:
                widget.playerOptions.enabledSystemUIOverlaysWhenEnterLandscape,
            enabledSystemUIOverlaysWhenExitLandscape:
                widget.playerOptions.enabledSystemUIOverlaysWhenExitLandscape),
        liveUIColor: widget.liveUIColor,
      ),
    );

    route.completed.then((void value) {
//      controller.setVolume(0.0);
    });

//    controller.setVolume(1.0);
    Navigator.of(context).push(route);
  }

  @override
  Widget build(BuildContext context) {
//    if (controller.isFullScreen == null) {
//      controller.isFullScreen =
//          MediaQuery.of(context).orientation == Orientation.landscape;
//    }

    return Hero(
      tag: "com.jarvanmo.neekoPlayerHeroTag",
      child: Container(
        width: widget.width ?? MediaQuery.of(context).size.width,
        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            overflow: Overflow.visible,
            children: <Widget>[
              NeekoPlayer(controllerWrapper: videoControllerWrapper),
              if (widget.playerOptions.useController)
                TouchShutter(
                  videoControllerWrapper,
                  showControllers: _showControllers,
                  enableDragSeek: widget.playerOptions.enableDragSeek,
                ),
              if (widget.playerOptions.useController)
                Center(
                  child: CenterControllerActionButtons(
                    videoControllerWrapper,
                    showControllers: _showControllers,
                    bufferIndicator: widget.bufferIndicator ??
                        Container(
                          width: 70.0,
                          height: 70.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                  ),
                ),
              if (widget.playerOptions.useController)
                Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: TopBar(
                      videoControllerWrapper,
                      showControllers: _showControllers,
                      options: widget.playerOptions,
                      actions: widget.actions,
                      isFullscreen: false,
                      onPortraitBackTap: widget.onPortraitBackTap,
                    )),
              if (widget.playerOptions.useController)
                (!widget.playerOptions.isLive)
                    ? Positioned(
                        left: 0,
                        right: 0,
                        child: ProgressBar(
                          videoControllerWrapper,
                          showControllers: _showControllers,
                          playedColor: widget.progressBarPlayedColor,
                          handleColor: widget.progressBarHandleColor,
                          backgroundColor: widget.progressBarBackgroundColor,
                          bufferedColor: widget.progressBarBufferedColor,
                        ),
                        bottom: -27.9,
                      )
                    : Container(),
              if (widget.playerOptions.useController)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: widget.playerOptions.isLive
                      ? LiveBottomBar(
                          videoControllerWrapper,
                          aspectRatio: widget.aspectRatio,
                          liveUIColor: widget.liveUIColor,
                          showControllers: _showControllers,
                          playedColor: widget.progressBarPlayedColor,
                          handleColor: widget.progressBarHandleColor,
                          backgroundColor: widget.progressBarBackgroundColor,
                          bufferedColor: widget.progressBarBufferedColor,
                          isFullscreen: false,
                          onEnterFullscreen: pushFullScreenWidget,
                        )
                      : BottomBar(
                          videoControllerWrapper,
                          aspectRatio: widget.aspectRatio,
                          showControllers: _showControllers,
                          playedColor: widget.progressBarPlayedColor,
                          handleColor: widget.progressBarHandleColor,
                          backgroundColor: widget.progressBarBackgroundColor,
                          bufferedColor: widget.progressBarBufferedColor,
                          isFullscreen: false,
                          onEnterFullscreen: pushFullScreenWidget,
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
