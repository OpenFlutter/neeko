
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'video_controller_wrapper.dart';

class NeekoPlayer extends StatefulWidget {
  final VideoControllerWrapper controllerWrapper;

  const NeekoPlayer({Key key, this.controllerWrapper}) : super(key: key);

  @override
  _NeekoPlayerState createState() => _NeekoPlayerState();
}

class _NeekoPlayerState extends State<NeekoPlayer>
    with WidgetsBindingObserver {

//  set controllerWrapper(VideoControllerWrapper controllerWrapper) =>
//      _controllerWrapper = controllerWrapper;

  bool _pausedByUser = false;

  @override
  Widget build(BuildContext context) {
    return VideoPlayer(widget.controllerWrapper.controller);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


}
