part of 'neeko_player_widget.dart';

class _NeekoPlayer extends StatefulWidget {
  final VideoControllerWrapper controllerWrapper;

  const _NeekoPlayer({Key key, this.controllerWrapper}) : super(key: key);

  @override
  __NeekoPlayerState createState() => __NeekoPlayerState();
}

class __NeekoPlayerState extends State<_NeekoPlayer>
    with WidgetsBindingObserver {
  VideoPlayerController get controller => widget.controllerWrapper.controller;

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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!_pausedByUser) {
          widget.controllerWrapper.controller?.play();
        }

        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.suspending:
        if (widget.controllerWrapper.controller?.value?.isPlaying == false) {
          _pausedByUser = true;
        }
        widget.controllerWrapper.controller?.pause();
        break;
    }
  }
}
