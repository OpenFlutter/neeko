import 'package:flutter/material.dart';
import 'package:neeko/src/video_controller_wrapper.dart';
import 'package:video_player/video_player.dart';

class ProgressBar extends StatefulWidget {
  final VideoControllerWrapper controllerWrapper;
  final Color playedColor;
  final Color bufferedColor;
  final Color handleColor;
  final Color backgroundColor;

  final Function onDragStart;
  final Function onDragEnd;
  final Function onDragUpdate;

  final ValueNotifier<bool> showControllers;

  ProgressBar(this.controllerWrapper,
      {this.playedColor,
      this.bufferedColor,
      this.handleColor,
      this.backgroundColor,
      this.onDragStart,
      this.onDragEnd,
      this.onDragUpdate,
      this.showControllers});

  @override
  _ProgressBarState createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  VoidCallback listener;

  VideoPlayerController get controller => widget.controllerWrapper.controller;
  bool _controllerWasPlaying = false;

  @override
  void initState() {
    super.initState();
    listener = () {
      if (mounted) {
        setState(() {});
      }
    };
    controller.addListener(listener);
    widget.showControllers?.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void deactivate() {
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    void seekToRelativePosition(Offset globalPosition) {
      final RenderBox box = context.findRenderObject();
      final Offset tapPos = box.globalToLocal(globalPosition);
      final double relative = tapPos.dx / box.size.width;
      final Duration position = controller.value.duration * relative;
      controller.seekTo(position);
    }

    final playedPaint = Paint()
      ..color = widget.playedColor ?? Theme.of(context).primaryColor;
    final bufferedPaint = Paint()
      ..color = widget.bufferedColor ?? Theme.of(context).accentColor;

    final handlePaint = Paint()
      ..color = widget.handleColor ?? Theme.of(context).primaryColor;

    final backgroundPaint = Paint()
      ..color = widget.backgroundColor ?? const Color.fromRGBO(10, 10, 10, 0.5);
    return GestureDetector(
      child: controller.value.hasError
          ? Container()
          : Container(
              height: 60,
              width: MediaQuery.of(context).size.width,
              color: Colors.transparent,
              child: CustomPaint(
                painter: _ProgressBarPainter(
                    value: controller.value,
                    playedPaint: playedPaint,
                    bufferedPaint: bufferedPaint,
                    handlePaint: handlePaint,
                    backgroundPaint: backgroundPaint,
                    drawHandle: widget.showControllers?.value == true),
              ),
            ),
      onHorizontalDragStart: (details) {
        if (!controller.value.initialized) {
          return;
        }
        _controllerWasPlaying = controller.value.isPlaying;
        if (_controllerWasPlaying) {
          controller.pause();
        }

        if (widget.onDragStart != null) {
          widget.onDragStart();
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);

        if (widget.onDragUpdate != null) {
          widget.onDragUpdate();
        }
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (_controllerWasPlaying) {
          controller.play();
        }

        if (widget.onDragEnd != null) {
          widget.onDragEnd();
        }
      },
      onTapDown: (TapDownDetails details) {
        if (!controller.value.initialized) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  final VideoPlayerValue value;

  final bool drawHandle;

  final Paint playedPaint;
  final Paint bufferedPaint;
  final Paint handlePaint;
  final Paint backgroundPaint;

  _ProgressBarPainter(
      {this.playedPaint,
      this.bufferedPaint,
      this.handlePaint,
      this.backgroundPaint,
      this.value,
      this.drawHandle});

  @override
  void paint(Canvas canvas, Size size) {
    final height = 2.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, size.height / 2),
          Offset(size.width, size.height / 2 + height),
        ),
        Radius.circular(0.0),
      ),
      backgroundPaint,
    );
    if (!value.initialized) {
      return;
    }
    double playedPart = 0;
    if (value.duration != null) {
      double playedPartPercent =
          value.position.inMilliseconds / value.duration.inMilliseconds;
      if (playedPartPercent.isNaN) playedPartPercent = 0;
      playedPart =
          playedPartPercent > 1 ? size.width : playedPartPercent * size.width;
    }

    double totalBuffered = 0;
    value.buffered?.forEach((durationRange) {
      totalBuffered = totalBuffered + durationRange.end.inMilliseconds;
    });

    double bufferedPercent = 0;
    if (value.duration != null) {
      bufferedPercent = totalBuffered / value.duration.inMilliseconds;
      if (bufferedPercent.isNaN) bufferedPercent = 0;
    }

    final double end = bufferedPercent * size.width;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0, size.height / 2),
          Offset(end, size.height / 2 + height),
        ),
        Radius.circular(4.0),
      ),
      bufferedPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0.0, size.height / 2),
          Offset(playedPart, size.height / 2 + height),
        ),
        Radius.circular(4.0),
      ),
      playedPaint,
    );
    if (drawHandle) {
      canvas.drawCircle(
        Offset(playedPart, size.height / 2 + height / 2),
        height * 3,
        handlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
