import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'duration_formatter.dart';
import 'neeko_player_options.dart';
import 'progress_bar.dart';
import 'video_controller_wrapper.dart';

class CenterControllerActionButtons extends StatefulWidget {
  final VideoControllerWrapper controllerWrapper;
  final ValueNotifier<bool> showControllers;
  final Widget bufferIndicator;
  final bool isLive;
  final Function onSkipPrevious;
  final Function onSkipNext;

  const CenterControllerActionButtons(this.controllerWrapper,
      {Key key,
      this.showControllers,
      this.bufferIndicator,
      this.onSkipPrevious,
      this.onSkipNext,
      this.isLive = false})
      : super(key: key);

  @override
  _CenterControllerActionButtonsState createState() =>
      _CenterControllerActionButtonsState();
}

class _CenterControllerActionButtonsState
    extends State<CenterControllerActionButtons>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;

  VideoControllerWrapper _controllerWrapper;

  VideoPlayerController get controller => _controllerWrapper.controller;

  set controllerWrapper(VideoControllerWrapper controllerWrapper) =>
      _controllerWrapper = controllerWrapper;

  AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _controllerWrapper = widget.controllerWrapper;
    _animController = AnimationController(
      vsync: this,
      value: 0,
      duration: Duration(milliseconds: 300),
    );
    _attachListenerToController();
    widget.showControllers.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  dispose() {
    _animController.dispose();
    super.dispose();
  }

  _attachListenerToController() {
    controller.addListener(
      () {
        if (!mounted) {
          return;
        }

        setState(() {
          _isPlaying = controller.value.isPlaying;
        });

        if (controller.value.isPlaying) {
          _animController.forward();
        } else {
          _animController.reverse();
        }
      },
    );
  }

  _animate() {}

  @override
  Widget build(BuildContext context) {
    final iconSize = 60.0;

    if (_controllerWrapper.hashCode != widget.controllerWrapper.hashCode) {
      _controllerWrapper = widget.controllerWrapper;
      _attachListenerToController();
    }
    if (controller.value.isBuffering) {
      return widget.bufferIndicator;
    } else {
      return Visibility(
        visible: widget.showControllers.value || !controller.value.isPlaying,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(150),
          ),
          height: double.infinity,
          child: Material(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (!widget.isLive)
                  IconButton(
                    icon: Icon(
                      Icons.skip_previous,
                      color: Colors.white,
                    ),
                    onPressed: widget.onSkipPrevious,
                    iconSize: iconSize,
                  ),
                InkWell(
                  borderRadius: BorderRadius.circular(50.0),
                  onTap: _play,
                  child: AnimatedIcon(
                    icon: AnimatedIcons.play_pause,
                    progress: _animController.view,
                    color: Colors.white,
                    size: iconSize * 1.5,
                  ),
                ),
                if (!widget.isLive)
                  IconButton(
                    icon: Icon(
                      Icons.skip_next,
                      color: Colors.white,
                    ),
                    onPressed: widget.onSkipNext,
                    iconSize: iconSize,
                  ),
              ],
            ),
          ),
        ),
      );
    }
  }

  _play() {
    if (_isPlaying) {
      controller.pause();
    } else {
      if (controller.value.position == null) {
        controller.play();
      } else if (controller.value.position.inMilliseconds >=
          controller.value.duration.inMilliseconds) {
        controller.seekTo(Duration(seconds: 0));
      } else {
        controller.play();
      }
    }

    _animate();
  }
}

class TouchShutter extends StatefulWidget {
  final VideoControllerWrapper controllerWrapper;
  final ValueNotifier<bool> showControllers;
  final bool enableDragSeek;

  const TouchShutter(this.controllerWrapper,
      {Key key, this.showControllers, this.enableDragSeek})
      : super(key: key);

  @override
  _TouchShutterState createState() => _TouchShutterState();
}

class _TouchShutterState extends State<TouchShutter> {
  double dragStartPos = 0.0;
  double delta = 0.0;
  int seekToPosition = 0;
  String seekDuration = "";
  String seekPosition = "";

  bool _dragging = false;

  VideoControllerWrapper _controllerWrapper;

  VideoPlayerController get controller => _controllerWrapper.controller;

  set controllerWrapper(VideoControllerWrapper controllerWrapper) =>
      _controllerWrapper = controllerWrapper;

  @override
  void initState() {
    super.initState();
    widget.showControllers.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.enableDragSeek
        ? GestureDetector(
            onTap: () =>
                widget.showControllers.value = !widget.showControllers.value,
            onHorizontalDragStart: (details) {
              setState(() {
                _dragging = true;
              });
              dragStartPos = details.globalPosition.dx;
            },
            onHorizontalDragUpdate: (details) {
              delta = details.globalPosition.dx - dragStartPos;
              seekToPosition =
                  (controller.value.position.inMilliseconds + delta * 1000)
                      .round();
              setState(() {
                seekDuration = (delta < 0 ? "- " : "+ ") +
                    durationFormatter(
                        (delta < 0 ? -1 : 1) * (delta * 1000).round());
                if (seekToPosition < 0) seekToPosition = 0;
                seekPosition = durationFormatter(seekToPosition);
              });
            },
            onHorizontalDragEnd: (_) {
              controller.seekTo(Duration(milliseconds: seekToPosition));
              setState(() {
                _dragging = false;
              });
            },
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: _dragging
                  ? Center(
                      child: Container(
                        padding: EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          color: Colors.black.withAlpha(150),
                        ),
                        child: Text(
                          "$seekDuration ($seekPosition)",
                          style: TextStyle(
                            fontSize: 26.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ),
          )
        : GestureDetector(
            onTap: () =>
                widget.showControllers.value = !widget.showControllers.value,
          );
  }
}

class TopBar extends StatefulWidget {
  final VideoControllerWrapper controllerWrapper;
  final List<Widget> actions;
  final ValueNotifier<bool> showControllers;
  final Widget leading;
  final NeekoPlayerOptions options;
  final Function onPortraitBackTap;
  final Function onLandscapeBackTap;

  final bool isFullscreen;

  const TopBar(this.controllerWrapper,
      {Key key,
      this.showControllers,
      this.actions,
      this.leading,
      this.options,
      this.onPortraitBackTap,
      this.onLandscapeBackTap,
      this.isFullscreen = false})
      : super(key: key);

  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  VideoControllerWrapper _controllerWrapper;

  VideoPlayerController get controller => _controllerWrapper.controller;

  set controllerWrapper(VideoControllerWrapper controllerWrapper) =>
      _controllerWrapper = controllerWrapper;

  @override
  void initState() {
    super.initState();
    widget.showControllers.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.showControllers.value,
      child: Padding(
        padding: EdgeInsets.only(
            left: 2.0, right: 2.0, top: MediaQuery.of(context).padding.top),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Expanded(
              child: widget.leading != null
                  ? widget.leading
                  : _buildLeading(context),
              flex: 7,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: widget.actions ?? [Container()],
              ),
              flex: 3,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLeading(BuildContext context) {
    final IconData back =
        Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back;

    return Align(
      alignment: Alignment.centerLeft,
      child: FlatButton.icon(
          onPressed: () {
            if (widget.isFullscreen && widget.onLandscapeBackTap != null) {
              widget.onLandscapeBackTap();
            } else if (!widget.isFullscreen &&
                widget.onPortraitBackTap != null) {
              widget.onPortraitBackTap();
            }
          },
          icon: Icon(
            widget.isFullscreen ? Icons.keyboard_arrow_down : back,
            color: Colors.white,
            size: widget.isFullscreen ? 32 : 24,
          ),
          label: Text(
            widget.controllerWrapper.dataSource?.displayName == null
                ? ""
                : widget.controllerWrapper.dataSource.displayName,
            style: TextStyle(
                color: Colors.white, fontSize: widget.isFullscreen ? 16 : 14),
          )),
    );
  }
}

class BottomBar extends StatefulWidget {
  final VideoControllerWrapper controllerWrapper;
  final Color playedColor;
  final Color bufferedColor;
  final Color handleColor;
  final Color backgroundColor;
  final double aspectRatio;
  final ValueNotifier<bool> showControllers;

  final bool isFullscreen;

  final Function onEnterFullscreen;
  final Function onExitFullscreen;

  const BottomBar(this.controllerWrapper,
      {Key key,
      this.playedColor,
      this.bufferedColor,
      this.handleColor,
      this.backgroundColor,
      this.aspectRatio,
      this.showControllers,
      this.isFullscreen = false,
      this.onEnterFullscreen,
      this.onExitFullscreen})
      : super(key: key);

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _currentPosition = 0;
  int _duration = 0;

  VideoControllerWrapper _controllerWrapper;

  VideoPlayerController get controller => _controllerWrapper.controller;

  set controllerWrapper(VideoControllerWrapper controllerWrapper) =>
      _controllerWrapper = controllerWrapper;

  @override
  void initState() {
    super.initState();
    _controllerWrapper = widget.controllerWrapper;
    _attachListenerToController();
    widget.showControllers.addListener(
      () {
        if (mounted) setState(() {});
      },
    );
  }

  _attachListenerToController() {
    controller.addListener(
      () {
        if (controller.value.duration == null ||
            controller.value.position == null) {
          return;
        }

        if (mounted) {
          setState(() {
            _currentPosition = controller.value.duration.inMilliseconds == 0
                ? 0
                : controller.value.position.inMilliseconds;
            _duration = controller.value.duration.inMilliseconds;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controllerWrapper.hashCode != widget.controllerWrapper.hashCode) {
      controllerWrapper = widget.controllerWrapper;
      _attachListenerToController();
    }

    return Visibility(
      visible: widget.showControllers.value,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 14.0,
          ),
          Text(
            durationFormatter(_currentPosition),
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
          ),
          Expanded(
            child: Padding(
              child: Visibility(
                visible: widget.isFullscreen,
                child: ProgressBar(
                  _controllerWrapper,
                  showControllers: widget.showControllers,
                  backgroundColor: widget.backgroundColor,
                  bufferedColor: widget.bufferedColor,
                  handleColor: widget.handleColor,
                  playedColor: widget.playedColor,
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
            ),
          ),
          Text(
            "${durationFormatter(_duration)}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
          ),
          IconButton(
            icon: Icon(
              widget.isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
              color: Colors.white,
            ),
            onPressed: () {
              if (widget.isFullscreen && widget.onExitFullscreen != null) {
                widget.onExitFullscreen();
              } else if (!widget.isFullscreen &&
                  widget.onEnterFullscreen != null) {
                widget.onEnterFullscreen();
              }
            },
          ),
        ],
      ),
    );
  }
}

class LiveBottomBar extends StatefulWidget {
  final VideoControllerWrapper controllerWrapper;

  final Color playedColor;
  final Color bufferedColor;
  final Color handleColor;
  final Color backgroundColor;
  final double aspectRatio;
  final ValueNotifier<bool> showControllers;

  final Color liveUIColor;

  final bool isFullscreen;

  final Function onEnterFullscreen;
  final Function onExitFullscreen;

  const LiveBottomBar(this.controllerWrapper,
      {Key key,
      this.playedColor,
      this.bufferedColor,
      this.handleColor,
      this.backgroundColor,
      this.aspectRatio,
      this.showControllers,
      this.liveUIColor,
      this.isFullscreen = false,
      this.onEnterFullscreen,
      this.onExitFullscreen})
      : super(key: key);

  @override
  _LiveBottomBarState createState() => _LiveBottomBarState();
}

class _LiveBottomBarState extends State<LiveBottomBar> {
  int _currentPosition = 0;
  double _currentSliderPosition = 0.0;

  VideoControllerWrapper _controllerWrapper;

  VideoPlayerController get controller => _controllerWrapper.controller;

  set controllerWrapper(VideoControllerWrapper controllerWrapper) =>
      _controllerWrapper = controllerWrapper;

  @override
  void initState() {
    super.initState();
    controllerWrapper = widget.controllerWrapper;
    _attachListenerToController();
    widget.showControllers.addListener(
      () {
        if (mounted) setState(() {});
      },
    );
  }

  _attachListenerToController() {
    controller.addListener(
      () {
        if (controller.value.duration == null ||
            controller.value.position == null) {
          return;
        }
        if (mounted) {
          setState(() {
            _currentPosition = controller.value.position.inMilliseconds;
            _currentSliderPosition = controller.value.position.inMilliseconds /
                controller.value.duration.inMilliseconds;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controllerWrapper.hashCode != widget.controllerWrapper.hashCode) {
      controllerWrapper = widget.controllerWrapper;
      _attachListenerToController();
    }
    return Visibility(
      visible: widget.showControllers.value,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 14.0,
          ),
          Text(
            durationFormatter(_currentPosition),
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.0,
            ),
          ),
          Expanded(
            child: Padding(
              child: Slider(
                value: _currentSliderPosition,
                onChanged: (value) {
                  controller.seekTo(
                    Duration(
                      milliseconds:
                          (controller.value.duration.inMilliseconds * value)
                              .round(),
                    ),
                  );
                },
                activeColor: widget.liveUIColor,
                inactiveColor: Colors.transparent,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 8.0,
              ),
            ),
          ),
          InkWell(
            onTap: () => controller.seekTo(controller.value.duration),
            child: Material(
              color: widget.liveUIColor,
              child: Text(
                "LIVE ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              widget.isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
              color: Colors.white,
            ),
            onPressed: () {
              if (widget.isFullscreen && widget.onExitFullscreen != null) {
                widget.onExitFullscreen();
              } else if (!widget.isFullscreen &&
                  widget.onEnterFullscreen != null) {
                widget.onEnterFullscreen();
              }
            },
          ),
        ],
      ),
    );
  }
}
