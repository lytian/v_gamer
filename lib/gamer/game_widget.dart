import 'dart:io';

import 'package:flutter/material.dart';
import 'package:v_gamer/gamer/gamer.dart';
import 'package:v_gamer/gamer/snake/snake.dart';
import 'package:v_gamer/gamer/tetris/tetris.dart';
import 'package:v_gamer/material/audios.dart';
import 'package:v_gamer/panel/page_land.dart';
import 'package:v_gamer/panel/page_portrait.dart';

import 'keyboard.dart';

class GameWidget extends StatefulWidget {
  final Widget child;
  final GameTypes type;

  const GameWidget({Key key, @required this.child, this.type = GameTypes.teris})
      : assert(child != null),
        super(key: key);

  static GameControl of(BuildContext context) {
    final state = context.findRootAncestorStateOfType<GameControl>();
    assert(state != null, "must wrap this context with [GameWidget]");
    return state;
  }

  @override
  GameControl createState() => GameControl();
}


class GameControl extends State<GameWidget> with WidgetsBindingObserver {

  Game game;


  @override
  void initState() {
    super.initState();

    
    switch (widget.type) {
      case GameTypes.teris:
        game = Tetris(context, setState);
        break;
      default:
        game = Snake(context, setState);
        break;
    }
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.inactive:
        print('AppLifecycleState.inactive');
        break;
      case AppLifecycleState.paused:
        game.pause();
        print('AppLifecycleState.paused');
        break;
      case AppLifecycleState.resumed:
        print('AppLifecycleState.resumed');
        break;
      case AppLifecycleState.detached:
        print('AppLifecycleState.suspending');
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();

    game.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    List<List<int>> mixed = game.build();
    if (widget.type != GameTypes.teris) {
      game.next = null;
    }
    
    debugPrint("game states : ${game.states}");
    return GameState(
        mixed, widget.type, game.states, game.level, game.sound.mute, game.points, game.cleared, game.next,
        child: widget.child);
  }
}

const LEVEL_MAX = 6;

const LEVEL_MIN = 1;

const SPEED_LIST = [
  const Duration(milliseconds: 800),
  const Duration(milliseconds: 650),
  const Duration(milliseconds: 500),
  const Duration(milliseconds: 370),
  const Duration(milliseconds: 250),
  const Duration(milliseconds: 160),
];

class GamePage  extends StatelessWidget {
  final GameTypes type;

  GamePage({Key key, this.type }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Sound(child: GameWidget(
        type: type,
        child: KeyboardController(child: _HomePage()))
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //only Android/iOS support land mode
    bool supportLandMode = Platform.isAndroid || Platform.isIOS;
    bool land = supportLandMode &&
        MediaQuery.of(context).orientation == Orientation.landscape;

    return land ? PageLand() : PagePortrait();
  }
}