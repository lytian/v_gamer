import 'package:flutter/material.dart';
import 'package:v_gamer/gamer/gamer.dart';
import 'package:v_gamer/material/briks.dart';
import 'package:v_gamer/material/images.dart';

const _PLAYER_PANEL_PADDING = 6;

Size getBrikSizeForScreenWidth(double width) {
  return Size.square((width - _PLAYER_PANEL_PADDING) / GAME_PAD_MATRIX_W);
}

/// the matrix of player content
class PlayerPanel extends StatelessWidget {
  //the size of player panel
  final Size size;

  PlayerPanel({Key key, @required double width})
      : assert(width != null && width != 0),
        size = Size(width, width * 2),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    debugPrint("size : $size");
    return SizedBox.fromSize(
      size: size,
      child: Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black)
        ),
        child: Stack(
          children: <Widget>[
            _PlayerPad(),
            _GameUninitialized()
          ]
        ),
      )
    );
  }
}

class _PlayerPad extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: GameState.of(context).data.map((list) {
        return Row(
          children: list.map((b) {
            return b == 1
                ? Brik.normal()
                : b == 2 ? Brik.highlight() : Brik.empty();
          }).toList(),
        );
      }).toList(),
    );
  }
}

class _GameUninitialized extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (GameState.of(context).state == GameStates.none) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconDragon(animate: true),
            SizedBox(height: 16),
            Text(
              GameState.of(context).type == GameTypes.teris ? "俄罗斯方块" : "贪吃蛇",
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }
}
