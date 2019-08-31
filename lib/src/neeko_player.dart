
part of 'neeko_player_widget.dart';


class _NeekoPlayer extends StatefulWidget {

  final NeekoPlayerController controller;

  const _NeekoPlayer({Key key, this.controller}) : super(key: key);

  @override
  __NeekoPlayerState createState() => __NeekoPlayerState();
}

class __NeekoPlayerState extends State<_NeekoPlayer> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return VideoPlayer(widget.controller);
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
        widget.controller?.play();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.suspending:
        widget.controller?.pause();
        break;
    }
  }
}
