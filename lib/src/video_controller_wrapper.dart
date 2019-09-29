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
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

class VideoControllerWrapper extends ValueNotifier<DataSource> {
  VideoPlayerController get controller => _videoPlayerController;

  List<VideoPlayerController> _controllerPool = [];

  VideoPlayerController _videoPlayerController;

  DataSource _dataSource;

  VideoControllerWrapper(DataSource value) : super(value) {
    prepareDataSource(value);
  }

  ///Get current [dataSource]
  DataSource get dataSource => _dataSource;

  ///Prepare your [dataSource] and initialize [_videoPlayerController].
  ///Old controllers will be disposed once the one is under buffering or playing.
  Future prepareDataSource(DataSource dataSource) async {
    _dataSource = dataSource;

    await _videoPlayerController?.pause();
//    if (_con`trollerPool.isNotEmpty) {
//      await _controllerPool[0].pause();
//    }

    VideoPlayerController newController;
    switch (dataSource.dataSourceType) {
      case DataSourceType.asset:
        newController = VideoPlayerController.asset(dataSource.dataSource,
            package: dataSource.package);
        break;
      case DataSourceType.network:
        newController = VideoPlayerController.network(dataSource.dataSource);
        break;
      case DataSourceType.file:
        newController = VideoPlayerController.file(File(dataSource.dataSource));
        break;
    }

    newController.addListener(_videoControllerListener);
    await newController.initialize();
    _controllerPool.add(
        _videoPlayerController); // add the old one into pool then dispose it.
//    _controllerPool.add(newController);
    _videoPlayerController = newController;

    notifyListeners();
    //we should dispose the old controller
//    if (_controllerPool.length >= 2) {
//      VideoPlayerController oldController = _controllerPool[0];
//      _controllerPool.remove(oldController);
//      Future.delayed(Duration(seconds: 5), () {
//        oldController.dispose();
//      });
//    }
  }

  _videoControllerListener() {
    if (_videoPlayerController == null ||
        !_videoPlayerController.value.initialized) {
      return;
    }

    if (_videoPlayerController.value.isPlaying) {
      if (_videoPlayerController.value.duration.inSeconds <= 1 ||
          _videoPlayerController.value.position.inSeconds > 1) {
        _videoPlayerController.removeListener(_videoControllerListener);
        _controllerPool.forEach((controller) {
          controller?.dispose();
        });
        _controllerPool.clear();
      }
    }
  }
}

class DataSource {
  final String dataSource;
  final DataSourceType dataSourceType;
  final String package;
  final String displayName;
  final dynamic id;
  final Map extras;

  DataSource.network(this.dataSource, {this.displayName, this.id, this.extras})
      : package = null,
        dataSourceType = DataSourceType.network;

  DataSource.file(File file, {this.displayName, this.id, this.extras})
      : dataSource = '${file.path}',
        package = null,
        dataSourceType = DataSourceType.file;

  DataSource.asset(this.dataSource,
      {this.package, this.displayName, this.id, this.extras})
      : dataSourceType = DataSourceType.network;
}
