import 'package:flutter/material.dart';
import 'package:v_gamer/gamer/tetris/block.dart';
import 'package:v_gamer/material/audios.dart';

/// 游戏区域的高
const GAME_PAD_MATRIX_H = 20;

/// 游戏区域的宽
const GAME_PAD_MATRIX_W = 10;

/// 游戏边框宽度
const SCREEN_BORDER_WIDTH = 3.0;

/// 游戏背景色
const BACKGROUND_COLOR = const Color(0xffefcc19);

/// 重置新行的持续时间
const REST_LINE_DURATION = const Duration(milliseconds: 50);

/// 游戏类型
enum GameTypes {
  /// 俄罗斯方块游戏
  teris,

  /// 贪吃蛇游戏
  snake,
}

/// state of [GameControl]
enum GameStates {
  /// 随时可以开启一把游戏 
  none,

  /// 游戏暂停中
  paused,

  /// 游戏正在进行中
  /// 按键可交互
  running,

  /// 游戏正在重置
  /// 重置完成之后，[GameController]状态将会迁移为[none]
  reset,

  /// 下落方块已经到达底部，此时正在将方块固定在游戏矩阵中
  /// 固定完成之后，将会立即开始下一个方块的下落任务
  mixing,

  /// 正在消除行
  /// 消除完成之后，将会立刻开始下一个方块的下落任务
  clear,

  /// 方块快速下坠到底部
  quicken,
}

/// 全局的游戏状态
class GameState extends InheritedWidget {
  GameState(this.data, this.type, this.state, this.level, this.muted, this.points,
      this.cleared, this.next,
      {Key key, this.child})
      : super(key: key, child: child);

  final Widget child;

  ///屏幕展示数据
  ///0: 空砖块
  ///1: 普通砖块
  ///2: 高亮砖块
  final List<List<int>> data;

  final GameTypes type;

  final GameStates state;

  final int level;

  final bool muted;

  final int points;

  final int cleared;

  final Block next;

  static GameState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GameState>();
  }

  @override
  bool updateShouldNotify(GameState oldWidget) {
    return true;
  }
}


abstract class Game {
  final BuildContext context;

  final Function setState;

  ///the gamer data
  final List<List<int>> data = [];

  ///在 [build] 方法中于 [_data]混合，形成一个新的矩阵。 需要高亮的蒙层
  ///[_mask]矩阵的宽高与 [_data] 一致
  ///对于任意的 _mask[x,y] ：
  /// 如果值为 0,则对 [_data]没有任何影响
  /// 如果值为 -1,则表示 [_data] 中该行不显示
  /// 如果值为 1，则表示 [_data] 中该行高亮
  final List<List<int>> mask = [];

  ///from 1-6
  int level = 1;

  int points = 0;

  int cleared = 0;

  Block next;

  GameStates states = GameStates.none;
  
  SoundState get sound => Sound.of(context);

  Game(this.context, this.setState) {
    //inflate game pad data
    for (int i = 0; i < GAME_PAD_MATRIX_H; i++) {
      data.add(List.filled(GAME_PAD_MATRIX_W, 0));
      mask.add(List.filled(GAME_PAD_MATRIX_W, 0));
    }
  }

  pause() {
    if (states == GameStates.running) {
      states = GameStates.paused;
    }
    setState(() {});
  }

  /// 点击方向按钮方法
  onUpTap();

  onRightTap();

  onDownTap();

  onLeftTap();

  onQuickTap();

  /// 点击系统按钮方法
  onSoundTap() {
    setState(() {
      sound.mute = !sound.mute;
    });
  }

  onPauseResumeTap();

  onResetTap();

  onBackTap() {
    Navigator.pop(context);
  }

  /// 构建方法
  List<List<int>> build();

  /// 销毁方法
  dispose();
}