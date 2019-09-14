//Copyright (c) [2019] [name of copyright holder]
//[Software Name] is licensed under the Mulan PSL v1.
//You can use this software according to the terms and conditions of the Mulan PSL v1.
//You may obtain a copy of Mulan PSL v1 at:
//http://license.coscl.org.cn/MulanPSL
//THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR
//PURPOSE.
//See the Mulan PSL v1 for more details.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

class VideoControllerWrapper extends ValueNotifier<DataSource> {
  VideoPlayerController _videoPlayerController;

  VideoPlayerController get controller => _videoPlayerController;

  DataSource _dataSource;

  VideoControllerWrapper(DataSource value) : super(value) {
    prepareDataSource(value);
  }

  VideoPlayerController get videoPlayerController => _videoPlayerController;

  DataSource get dataSource => _dataSource;

  void prepareDataSource(DataSource dataSource) async {
    _dataSource = dataSource;

    switch (dataSource.dataSourceType) {
      case DataSourceType.asset:
        _videoPlayerController = VideoPlayerController.asset(
            dataSource.dataSource,
            package: dataSource.package);
        break;
      case DataSourceType.network:
        _videoPlayerController =
            VideoPlayerController.network(dataSource.dataSource);
        break;
      case DataSourceType.file:
        _videoPlayerController =
            VideoPlayerController.file(File(dataSource.dataSource));
        break;
    }

    await _videoPlayerController.initialize();

    notifyListeners();
  }
}

class DataSource {
  final String dataSource;
  final DataSourceType dataSourceType;
  final String package;
  final String displayName;

  DataSource.network(this.dataSource, {this.displayName})
      : package = null,
        dataSourceType = DataSourceType.network;

  DataSource.file(File file, {this.displayName})
      : dataSource = '${file.path}',
        package = null,
        dataSourceType = DataSourceType.file;

  DataSource.asset(this.dataSource, {this.package, this.displayName})
      : dataSourceType = DataSourceType.network;
}
