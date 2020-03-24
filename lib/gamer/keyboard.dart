import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:v_gamer/gamer/game_widget.dart';

import 'gamer.dart';

///keyboard controller to play game
class KeyboardController extends StatefulWidget {
  final Widget child;

  KeyboardController({this.child});

  @override
  _KeyboardControllerState createState() => _KeyboardControllerState();
}

class _KeyboardControllerState extends State<KeyboardController> {
  @override
  void initState() {
    super.initState();
    RawKeyboard.instance.addListener(_onKey);
  }

  void _onKey(RawKeyEvent event) {
    if (event is RawKeyUpEvent) {
      return;
    }

    final key = event.data.physicalKey;

    if (key == PhysicalKeyboardKey.arrowUp) {
      GameWidget.of(context).game.onUpTap();
    } else if (key == PhysicalKeyboardKey.arrowDown) {
      GameWidget.of(context).game.onDownTap();
    } else if (key == PhysicalKeyboardKey.arrowLeft) {
      GameWidget.of(context).game.onLeftTap();
    } else if (key == PhysicalKeyboardKey.arrowRight) {
      GameWidget.of(context).game.onRightTap();
    } else if (key == PhysicalKeyboardKey.space) {
      GameWidget.of(context).game.onQuickTap();
    } else if (key == PhysicalKeyboardKey.keyP) {
      GameWidget.of(context).game.onPauseResumeTap();
    } else if (key == PhysicalKeyboardKey.keyS) {
      GameWidget.of(context).game.onSoundTap();
    } else if (key == PhysicalKeyboardKey.keyR) {
      GameWidget.of(context).game.onResetTap();
    }
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_onKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
