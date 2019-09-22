import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neeko/neeko.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.red,
          accentColor: Colors.redAccent),
      home: MyHomePage(title: 'Neeko Demo'),
    );
  }
}

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
//  final VideoControllerWrapper videoControllerWrapper = VideoControllerWrapper(
//      DataSource.network(
//          'http://vfx.mtime.cn/Video/2019/03/09/mp4/190309153658147087.mp4',
//          displayName: "displayName"));

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
