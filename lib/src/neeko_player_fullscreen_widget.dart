import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'neeko_player_controller.dart';
import 'neeko_player_options.dart';
import 'neeko_player_widget.dart';

Future<Duration> showFullScreenNeekoPlayer(
    {@required BuildContext context,
    double aspectRatio = 16 / 9,
    double width,
    Duration controllerTimeout,
    Widget bufferIndicator,
    Color liveUIColor,
    List<Widget> actions,
    Duration startAt,
    String displayName,
    String dataSource,
    DataSourceType dataSourceType,
    String package,
    NeekoPlayerOptions playerOptions}) {
  return Navigator.push<Duration>(
      context,
      MaterialPageRoute(
          builder: (context) => _FullScreenNeekoPlayer(
                aspectRatio: aspectRatio,
                width: width,
                controllerTimeout: controllerTimeout,
                bufferIndicator: bufferIndicator,
                liveUIColor: liveUIColor,
                actions: actions,
                startAt: startAt,
                inFullScreen: true,
                displayName: displayName,
                dataSource: dataSource,
                dataSourceType: dataSourceType,
                package: package,
                playerOptions: playerOptions,
              )));
}

class _FullScreenNeekoPlayer extends StatefulWidget {
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

  final String displayName;

  final String dataSource;

  final DataSourceType dataSourceType;

  final String package;

  const _FullScreenNeekoPlayer(
      {Key key,
      this.width,
      this.controllerTimeout,
      this.bufferIndicator,
      this.liveUIColor,
      this.aspectRatio,
      this.actions,
      this.startAt,
      this.inFullScreen,
      this.displayName,
      this.dataSource,
      this.dataSourceType,
      this.package,
      this.playerOptions})
      : super(key: key);

  @override
  __FullScreenNeekoPlayerState createState() => __FullScreenNeekoPlayerState();
}

class __FullScreenNeekoPlayerState extends State<_FullScreenNeekoPlayer> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: SafeArea(
        child: Center(
          child: NeekoPlayerWidget(
            videoPlayerController: _buildNewController()
              ..displayName = widget.displayName,
            aspectRatio: widget.aspectRatio,
            actions: widget.actions,
            playerOptions: widget.playerOptions,
            bufferIndicator: widget.bufferIndicator,
            controllerTimeout: widget.controllerTimeout,
            liveUIColor: widget.liveUIColor,
            startAt: widget.startAt,
            inFullScreen: widget.inFullScreen,
          ),
        ),
      ),
    );
  }

  NeekoPlayerController _buildNewController() {
    if (widget.dataSourceType == DataSourceType.asset) {
      return NeekoPlayerController.asset(widget.dataSource,
          package: widget.package);
    } else if (widget.dataSourceType == DataSourceType.file) {
      return NeekoPlayerController.file(
          File(widget.dataSource.replaceFirst("file://", "")));
    } else {
      return NeekoPlayerController.network(widget.dataSource);
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays(
        widget.playerOptions.enabledSystemUIOverlaysWhenEnterLandscape);
    SystemChrome.setPreferredOrientations(
        widget.playerOptions.preferredOrientationsWhenEnterLandscape);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(
        widget.playerOptions.enabledSystemUIOverlaysWhenExitLandscape);
    SystemChrome.setPreferredOrientations(
        widget.playerOptions.preferredOrientationsWhenExitLandscape);
    super.dispose();
  }
}
