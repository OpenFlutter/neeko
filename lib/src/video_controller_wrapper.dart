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

  void prepareDataSource(DataSource dataSource) {
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
