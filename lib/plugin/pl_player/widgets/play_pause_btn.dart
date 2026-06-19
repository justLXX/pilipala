import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pilipala/plugin/pl_player/index.dart';

class PlayOrPauseButton extends StatefulWidget {
  final double? iconSize;
  final Color? iconColor;
  final PlPlayerController? controller;

  const PlayOrPauseButton({
    super.key,
    this.iconSize,
    this.iconColor,
    this.controller,
  });

  @override
  PlayOrPauseButtonState createState() => PlayOrPauseButtonState();
}

class PlayOrPauseButtonState extends State<PlayOrPauseButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController animation;

  StreamSubscription<PlayerStatus>? subscription;
  bool isOpacity = false;

  @override
  void initState() {
    super.initState();
    animation = AnimationController(
      vsync: this,
      value: widget.controller!.playerStatus.playing ? 1 : 0,
      duration: const Duration(milliseconds: 200),
    );
    _subscribeStatus();
  }

  @override
  void didUpdateWidget(covariant PlayOrPauseButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      subscription?.cancel();
      subscription = null;
      animation.value = widget.controller!.playerStatus.playing ? 1 : 0;
      _subscribeStatus();
    }
  }

  void _subscribeStatus() {
    subscription ??= widget.controller!.onPlayerStatusChanged.listen((status) {
      if (status == PlayerStatus.playing) {
        animation.forward().then((value) => {
              isOpacity = true,
            });
      } else {
        animation.reverse().then((value) => {isOpacity = false});
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    animation.dispose();
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 34,
      child: IconButton(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
        ),
        onPressed: widget.controller!.togglePlay,
        color: Colors.white,
        iconSize: 20,
        // iconSize: widget.iconSize ?? _theme(context).buttonBarButtonSize,
        // color: widget.iconColor ?? _theme(context).buttonBarButtonColor,
        icon: AnimatedIcon(
          progress: animation,
          icon: AnimatedIcons.play_pause,
          color: Colors.white,
          size: 20,
          // size: widget.iconSize ?? _theme(context).buttonBarButtonSize,
          // color: widget.iconColor ?? _theme(context).buttonBarButtonColor,
        ),
      ),
    );
  }
}
