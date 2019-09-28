# Neeko [![pub package](https://img.shields.io/pub/v/neeko.svg)](https://pub.dartlang.org/packages/neeko)


Simple video player widget based on [video_player](https://pub.dev/packages/video_player). Neek supports more actions such as timeline control, toggle fullscreen  and so on.

<img src="https://github.com/OpenFlutter/neeko/blob/master/screenshot/screenshot.gif" width="300" height="480">

Note: This plugin is still under development. [Pull Requests](https://github.com/OpenFlutter/neeko/pulls) are most welcome.


## Installation

First, add `neeko` as a [dependency in your pubspec.yaml file](https://flutter.io/using-packages/).

### iOS

Warning: The video player is not functional on iOS simulators. An iOS device must be used during development/testing.

Add the following entry to your _Info.plist_ file, located in `<project root>/ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

This entry allows your app to access video files by URL.

### Android

Ensure the following permission is present in your Android Manifest file, located in `<project root>/android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

The Flutter project template adds it, so it may already be there.


### Example

```dart

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

//  static const String beeUri = 'https://media.w3.org/2010/05/sintel/trailer.mp4';
  static const String beeUri =
      'http://vfx.mtime.cn/Video/2019/03/09/mp4/190309153658147087.mp4';


  final VideoControllerWrapper videoControllerWrapper = VideoControllerWrapper(
      DataSource.network(
          'http://vfx.mtime.cn/Video/2019/03/09/mp4/190309153658147087.mp4',
          displayName: "displayName"));

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
  }

  @override
  void dispose() {
    SystemChrome.restoreSystemUIOverlays();
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      body: NeekoPlayerWidget(
        onSkipPrevious: () {
          print("skip");
          videoControllerWrapper.prepareDataSource(DataSource.network(
              "http://vfx.mtime.cn/Video/2019/03/12/mp4/190312083533415853.mp4",
              displayName: "This house is not for sale"));
        },
        videoControllerWrapper: videoControllerWrapper,
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.share,
                color: Colors.white,
              ),
              onPressed: () {
                print("share");
              })
        ],
      ),
    );
  }
}


```

### Thanks

- [youtube_player_flutter](https://pub.dev/packages/youtube_player_flutter)


### LICENSE
-------

    Copyright (c) 2019 Neeko Contributors
    
    Neeko is licensed under the Mulan PSL v1.
    
    You can use this software according to the terms and conditions of the Mulan PSL v1.
    You may obtain a copy of Mulan PSL v1 at:
    
      http://license.coscl.org.cn/MulanPSL
      
    THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR
    PURPOSE.
   
    See the Mulan PSL v1 for more details.
