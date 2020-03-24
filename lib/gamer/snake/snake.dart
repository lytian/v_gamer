import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../game_widget.dart';
import '../gamer.dart';

enum MoveDirection {
  up,
  right,
  down,
  left
}

class Snake extends Game {
  
  Snake(BuildContext context, Function setState) : super(context, setState);

  // 食物
  List<int> _food;

  // 蛇体
  List<List<int>> _list;

  MoveDirection _currentDirection = MoveDirection.right;

  Timer _autoMoveTimer;

  List<int> 
  _randomFood({ int rowIndex}) {
    int y;
    if (rowIndex == null) {
      y = Random().nextInt(GAME_PAD_MATRIX_H);
      if (!data[y].contains(0)) {
        return _randomFood();
      }
    } else {
      y = rowIndex;
    }
    int x = Random().nextInt(GAME_PAD_MATRIX_W);
    if (data[y][x] != 0) {
      // 位置已被占用。重新获取
      return _randomFood(rowIndex: y);
    }
    return [x, y];
  }

  bool _isFull({ int rowIndex}) {
    if (rowIndex == null) {
      // 判断整体
      for (var i = 0; i < data.length; i++) {
        if (data[i].contains(0)) {
          return false;
        }
      }
    } else {
      // 判断单行
      if (rowIndex < 0 || rowIndex >= data.length) {
        return true;
      }
      if (data[rowIndex].contains(0)) {
        return false;
      }
    }

    return true;
  }

  void _startGame() {
    if (states == GameStates.running && _autoMoveTimer?.isActive == false) {
      return;
    }
    _food = _randomFood();
    _list = [
      [0, 0],
      [1, 0],
      [2, 0]
    ];
    states = GameStates.running;
    setState(() {});
    _autoMove(true);
  }

  void _autoMove(bool enable) {
    if (!enable && _autoMoveTimer != null) {
      _autoMoveTimer.cancel();
      _autoMoveTimer = null;
    } else if (enable) {
      _autoMoveTimer?.cancel();
      // 若当前没有食物
      _food = _food ?? _randomFood();
      // 定时固定方向移动
      _autoMoveTimer = Timer.periodic(SPEED_LIST[level - 1], (t) {
        _move(enableSounds: false);
      });
    }
  }

  void _move({bool enableSounds = true}) async {
    if (states == GameStates.running) {
      // 增加头
      List<int> head = _list.last;
      List<int> newHead;
      switch (_currentDirection) {
        case MoveDirection.right:
          newHead = [head[0] + 1, head[1]];
          break;
        case MoveDirection.left:
          newHead = [head[0] - 1, head[1]];
          break;
        case MoveDirection.up:
          newHead = [head[0], head[1] - 1];
          break;
        case MoveDirection.down:
          newHead = [head[0], head[1] + 1];
          break;
        default:
          break;
      }
      int status = _getHeadStatus(newHead);
      _list.add(newHead);
      setState(() {});

      switch (status) {
        case -1:
          // 碰壁死亡。闪烁之后重置
          sound.clear();
          // 取消当前下落
          _autoMove(false);
          // 消除效果动画。闪烁5次
          for (int count = 0; count < 5; count++) {
            // 去掉蛇头闪烁
            for (var i = 0; i < _list.length; i++) {
              if (_list[i][0] < 0 || _list[i][1] < 0 || _list[i][0] >= GAME_PAD_MATRIX_W || _list[i][1] >= GAME_PAD_MATRIX_H) {
                continue;
              }
              mask[_list[i][1]][_list[i][0]] = count % 2 == 0 ? -1 : 1;
            }
            setState(() {});
            await Future.delayed(Duration(milliseconds: 100));
          }
          onResetTap();
          break;
        case 1:
          // 吃掉食物
          sound.rotate();
          cleared++;
          points += level * 5;
          if (_isFull()) {
            onResetTap();
            return;
          }
          _food = _randomFood();
          setState(() => {});
          break;
        case 0:
          // 继续前行。 砍掉尾巴
          if (enableSounds) {
            sound.move();
          }
          _list.removeAt(0);
          break;
        default:
      }
    }
    setState(() {});
  }

  /// 获取蛇头的情况
  ///   -1 碰壁死亡
  ///    0 继续往前
  ///    1 吃掉食物 
  int _getHeadStatus(List<int> point) {
    if (point.isEmpty || point.length < 2) {
      return -1;
    }
    // 越界
    if (point[0] < 0 || point[0] >= GAME_PAD_MATRIX_W
      || point[1] < 0 || point[1] >= GAME_PAD_MATRIX_H) {
        return -1;
      }
    // 碰到食物
    if (point.toString() == _food.toString()) {
      return 1;
    }
    // 吃掉自己
    for (List<int> item in _list) {
      if (point.toString() == item.toString()) {
        return -1;
      }
    }
    return 0;
  }

  @override
  List<List<int>> build() {
    List<List<int>> mixed = [];
    // 动态计算混合后的显示
    for (var i = 0; i < GAME_PAD_MATRIX_H; i++) {
      mixed.add(List.filled(GAME_PAD_MATRIX_W, 0));
      for (var j = 0; j < GAME_PAD_MATRIX_W; j++) {
        int value = data[i][j];
        if (_food != null && _food.isNotEmpty && _food[0] == j && _food[1] == i) {
          value = 2;
        }
        if (_list != null && _list.isNotEmpty) {
          for (var k = 0; k < _list.length; k++) {
            if (_list[k][0] == j && _list[k][1] == i) {
              if (k == _list.length - 1) {
                // 蛇头
                value = 2;
              } else {
                // 蛇身
                value = 1;
              }
              continue;
            }
          }
        }
        if (mask[i][j] == -1) {
          value = 0;
        } else if (mask[i][j] == 1) {
          value = 2;
        }
        mixed[i][j] = value;
      }
    }
    return mixed;
  }

  @override
  dispose() {
    _autoMoveTimer?.cancel();
    _autoMoveTimer = null;
  }

  @override
  onDownTap() {
    if (_currentDirection == MoveDirection.up) return;

    if (states == GameStates.running) {
      _currentDirection = MoveDirection.down;
      _move();
    }
  }

  @override
  onLeftTap() {
    if (_currentDirection == MoveDirection.right) return;

    if (states == GameStates.none && level > LEVEL_MIN) {
      // 如果游戏未开始，降低游戏难度级别
      level--;
    } else if (states == GameStates.running) {
      _currentDirection = MoveDirection.left;
      _move();
    }
    setState(() {});
  }

  @override
  onRightTap() {
    if (_currentDirection == MoveDirection.left) return;

    if (states == GameStates.none && level < LEVEL_MAX) {
      // 如果游戏未开始，增加游戏难度级别
      level++;
    } else if (states == GameStates.running) {
      _currentDirection = MoveDirection.right;
      _move();
    }
    setState(() {});
  }

  @override
  onUpTap() {
    if (_currentDirection == MoveDirection.down) return;

    if (states == GameStates.running) {
      _currentDirection = MoveDirection.up;
      _move();
    }
  }

  @override
  onPauseResumeTap() {
    if (states == GameStates.running) {
      pause();
    } else if (states == GameStates.paused || states == GameStates.none) {
      _startGame();
    }
  }

  @override
  onQuickTap() {
    onPauseResumeTap();
  }

  @override
  onResetTap() {
    if (states == GameStates.none) {
      //可以开始游戏
      _startGame();
      return;
    }
    if (states == GameStates.reset) {
      return;
    }
    sound.start();
    states = GameStates.reset;
    // 清空mask
    for (int i = 0; i < GAME_PAD_MATRIX_H; i++) {
      mask[i] = List.filled(GAME_PAD_MATRIX_W, 0);
    }
    // 清空数据
    _food = null;
    _list = null;
    _currentDirection = MoveDirection.right;
    // 重置动画
    () async {
      int line = GAME_PAD_MATRIX_H;
      // 从上至下逐行显示
      await Future.doWhile(() async {
        line--;
        for (int i = 0; i < GAME_PAD_MATRIX_W; i++) {
          data[line][i] = 1;
        }
        setState(() {});
        await Future.delayed(REST_LINE_DURATION);
        return line != 0;
      });
      points = 0;
      cleared = 0;
      // 然后逐行清空
      await Future.doWhile(() async {
        for (int i = 0; i < GAME_PAD_MATRIX_W; i++) {
          data[line][i] = 0;
        }
        setState(() {});
        line++;
        await Future.delayed(REST_LINE_DURATION);
        return line != GAME_PAD_MATRIX_H;
      });
      // 动画结束后重置状态
      setState(() {
        states = GameStates.none;
      });
    }();
  }
  
}