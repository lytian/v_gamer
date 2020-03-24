import 'package:flutter/material.dart';
import 'package:v_gamer/gamer/gamer.dart';
import 'package:v_gamer/panel/controller.dart';

import 'screen.dart';

class PagePortrait extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenW = size.width * 0.8;

    return SizedBox.expand(
      child: Container(
        color: BACKGROUND_COLOR,
        child: Padding(
          padding: MediaQuery.of(context).padding,
          child: Column(
            children: <Widget>[
              Spacer(),
              _ScreenDecoration(child: Screen(width: screenW)),
              Spacer(flex: 2),
              GameController(),
              SizedBox(height: 16)
            ],
          )
        )
      )
    );
  }
}

class _ScreenDecoration extends StatelessWidget {
  final child;

  _ScreenDecoration({Key key, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
              color: const Color(0xFF987f0f), width: SCREEN_BORDER_WIDTH),
          left: BorderSide(
              color: const Color(0xFF987f0f), width: SCREEN_BORDER_WIDTH),
          right: BorderSide(
              color: const Color(0xFFfae36c), width: SCREEN_BORDER_WIDTH),
          bottom: BorderSide(
              color: const Color(0xFFfae36c), width: SCREEN_BORDER_WIDTH),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.black54)),
        child: Container(
          padding: const EdgeInsets.all(SCREEN_BORDER_SIZE),
          color: SCREEN_BACKGROUND,
          child: child,
        ),
      ),
    );
  }
}