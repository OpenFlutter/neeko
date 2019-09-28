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

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'video_controller_wrapper.dart';

class NeekoPlayer extends StatefulWidget {
  final VideoControllerWrapper controllerWrapper;

  const NeekoPlayer({Key key, this.controllerWrapper}) : super(key: key);

  @override
  _NeekoPlayerState createState() => _NeekoPlayerState();
}

class _NeekoPlayerState extends State<NeekoPlayer> with WidgetsBindingObserver {
//  set controllerWrapper(VideoControllerWrapper controllerWrapper) =>
//      _controllerWrapper = controllerWrapper;

//  bool _pausedByUser = false;

  @override
  Widget build(BuildContext context) {
    return widget.controllerWrapper.controller == null
        ? Container()
        : VideoPlayer(widget.controllerWrapper.controller);
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
