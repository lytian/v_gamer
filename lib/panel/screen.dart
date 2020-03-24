import 'dart:math';

import 'package:flutter/material.dart';
import 'package:v_gamer/gamer/gamer.dart';
import 'package:v_gamer/material/briks.dart';
import 'package:v_gamer/material/material.dart';
import 'package:v_gamer/panel/player_panel.dart';
import 'package:v_gamer/panel/status_panel.dart';
import 'package:vector_math/vector_math_64.dart' as v;

const Color SCREEN_BACKGROUND = Color(0xff9ead86);
const double SCREEN_BORDER_SIZE = 3;

class Screen extends StatelessWidget {
  ///the with of screen
  final double width;

  const Screen({Key key, @required this.width}) : super(key: key);

  Screen.fromHeight(double height) : this(width: ((height - SCREEN_BORDER_SIZE * 2) / 2 + SCREEN_BORDER_SIZE * 2) / 0.6);

  @override
  Widget build(BuildContext context) {
    // play panel need 60%
    final playerPanelWidth = width * 0.6;

    return Shake(
      shake: GameState.of(context).state == GameStates.quicken,
      child: SizedBox(
        height: (playerPanelWidth - SCREEN_BORDER_SIZE * 2) * 2 + SCREEN_BORDER_SIZE * 2,
        width: width,
        child: Container(
          color: SCREEN_BACKGROUND,
          child: GameMaterial(
            child: BrikSize(
              size: getBrikSizeForScreenWidth(playerPanelWidth),
              child: Row(
                children: <Widget>[
                  PlayerPanel(width: playerPanelWidth),
                  SizedBox(
                    width: width - playerPanelWidth,
                    child: StatusPanel(),
                  )
                ]
              ),
            )
          )
        ),
      ),
    );
  }
}


///摇晃屏幕
class Shake extends StatefulWidget {
  final Widget child;

  ///true to shake screen vertically
  final bool shake;

  const Shake({Key key, @required this.child, @required this.shake})
      : super(key: key);

  @override
  _ShakeState createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 150))
          ..addListener(() {
            setState(() {});
          });
    super.initState();
  }

  @override
  void didUpdateWidget(Shake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shake) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  v.Vector3 _getTranslation() {
    double progress = _controller.value;
    double offset = sin(progress * pi) * 1.5;

    return v.Vector3(0, offset, 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.translation(_getTranslation()),
      child: widget.child,
    );
  }
}