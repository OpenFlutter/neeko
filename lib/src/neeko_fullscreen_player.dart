//Copyright (c) 2019 Neeko Contributors
//
//Neeko is licensed under the Mulan PSL v1.
//
//You can use this software according to the terms and conditions of the Mulan PSL v1.
//You may obtain a copy of Mulan PSL v1 at:
//
//http://license.coscl.org.cn/MulanPSL
//
//THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR
//PURPOSE.
//
//See the Mulan PSL v1 for more details.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'neeko_player.dart';
import 'neeko_player_options.dart';
import 'video_controller_widgets.dart';
import 'video_controller_wrapper.dart';


///Build [_FullscreenPlayer]
Widget fullScreenRoutePageBuilder(
    {@required BuildContext context,
    @required VideoControllerWrapper videoControllerWrapper,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    double aspectRatio = 16 / 9,
    double width,
    Duration controllerTimeout,
    Widget bufferIndicator,
    Color liveUIColor,
    List<Widget> actions,
    Duration startAt,
    Function onSkipPrevious,
    Function onSkipNext,
    NeekoPlayerOptions playerOptions}) {
  return _FullscreenPlayer(
    videoControllerWrapper: videoControllerWrapper,
    aspectRatio: aspectRatio,
    width: width,
    controllerTimeout: controllerTimeout,
    bufferIndicator: bufferIndicator,
    liveUIColor: liveUIColor,
    actions: actions,
    startAt: startAt,
    inFullScreen: true,
    playerOptions: playerOptions,
    onSkipPrevious: onSkipPrevious,
    onSkipNext: onSkipNext,
  );
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

  final Function onSkipPrevious;
  final Function onSkipNext;

  final Color progressBarPlayedColor;
  final Color progressBarBufferedColor;
  final Color progressBarHandleColor;
  final Color progressBarBackgroundColor;

  const _FullscreenPlayer(
      {Key key,
      this.videoControllerWrapper,
      this.playerOptions,
      this.width,
      this.controllerTimeout,
      this.bufferIndicator,
      this.liveUIColor,
      this.aspectRatio,
      this.actions,
      this.startAt,
      this.inFullScreen,
      this.onPortraitBackTap,
      this.onSkipPrevious,
      this.onSkipNext,
      this.progressBarPlayedColor,
      this.progressBarBufferedColor,
      this.progressBarHandleColor,
      this.progressBarBackgroundColor})
      : super(key: key);

  @override
  __FullscreenPlayerState createState() => __FullscreenPlayerState();
}

class __FullscreenPlayerState extends State<_FullscreenPlayer> {
  VideoPlayerController get controller =>
      widget.videoControllerWrapper.controller;

  final _showControllers = ValueNotifier<bool>(false);

  Timer _timer;

  VideoControllerWrapper get videoControllerWrapper =>
      widget.videoControllerWrapper;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays(
        widget.playerOptions.enabledSystemUIOverlaysWhenEnterLandscape);
    SystemChrome.setPreferredOrientations(
        widget.playerOptions.preferredOrientationsWhenEnterLandscape);

    _showControllers.addListener(() {
      _timer?.cancel();
      if (_showControllers.value) {
        _timer = Timer(
          widget.controllerTimeout,
          () => _showControllers.value = false,
        );
      }
    });

    controller?.addListener(() {
      if (mounted) {
        setState(() {
//          _autoPlay();
        });
      }
    });

    widget.videoControllerWrapper.addListener(() {
      controller.addListener(() {
        if (mounted) {
          setState(() {
//          _autoPlay();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    SystemChrome.setEnabledSystemUIOverlays(
        widget.playerOptions.enabledSystemUIOverlaysWhenExitLandscape);
    SystemChrome.setPreferredOrientations(
        widget.playerOptions.preferredOrientationsWhenExitLandscape);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: SafeArea(
        child: Center(
          child: Hero(
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
                          onSkipPrevious: widget.onSkipPrevious,
                          onSkipNext: widget.onSkipNext,
                          bufferIndicator: widget.bufferIndicator ??
                              Container(
                                width: 70.0,
                                height: 70.0,
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
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
                            isFullscreen: true,
                            onLandscapeBackTap: _pop,
                          )),
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
                                backgroundColor:
                                    widget.progressBarBackgroundColor,
                                bufferedColor: widget.progressBarBufferedColor,
                                isFullscreen: true,
                                onExitFullscreen: _pop,
                              )
                            : BottomBar(
                                videoControllerWrapper,
                                aspectRatio: widget.aspectRatio,
                                showControllers: _showControllers,
                                playedColor: widget.progressBarPlayedColor,
                                handleColor: widget.progressBarHandleColor,
                                backgroundColor:
                                    widget.progressBarBackgroundColor,
                                bufferedColor: widget.progressBarBufferedColor,
                                isFullscreen: true,
                                onExitFullscreen: _pop,
                              ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _pop() {
    Navigator.of(context).pop();
  }
}
